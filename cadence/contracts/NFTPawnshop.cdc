import FungibleToken from "FungibleToken.cdc"
import FlowToken from "FlowToken.cdc"
import NonFungibleToken from "NonFungibleToken.cdc"

pub contract NFTPawnshop {
    pub let collections: {String: Capability<&NonFungibleToken.Collection>}
    pub let AdminStoragePath: StoragePath
    pub let AdminPrivatePath: PrivatePath

    init() {
        self.collections = {}
        self.AdminStoragePath = /storage/admin
        self.AdminPrivatePath = /private/admin

        let admin <- create Admin()
        self.account.save<@Admin>(<- admin, to: self.AdminStoragePath)

        self.account.link<&Admin>(
            self.AdminPrivatePath,
            target: self.AdminStoragePath
        )
    }

    pub struct NonFungibleTokenInfo {
        pub let name: String
        pub let publicPath: PublicPath
        pub let privatePath: PrivatePath
        pub let storagePath: StoragePath
        pub let publicType: Type
        pub let privateType: Type

        init(
            name: String,
            publicPath: PublicPath,
            privatePath: PrivatePath,
            storagePath: StoragePath,
            publicType: Type,
            privateType: Type
        ) {
            self.name = name
            self.publicPath = publicPath
            self.privatePath = privatePath
            self.storagePath = storagePath
            self.publicType = publicType
            self.privateType = privateType
        }
    }

    pub struct CollectionInfo {
        pub let identifier: String
        pub let nftIDs: [UInt64]

        init(identifier: String, nftIDs: [UInt64]) {
            self.identifier = identifier
            self.nftIDs = nftIDs
        }
    }

    pub struct PledgeInfo {
        pub let debitor: Address
        pub let expiry: UFix64
        pub let collections: [CollectionInfo]

        init(
            debitor: Address,
            expiry: UFix64,
            collections: [CollectionInfo]
        ) {
            self.debitor = debitor
            self.expiry = expiry
            self.collections = collections
        }
    }

    pub resource interface PledgePublic {
        pub fun getInfo(): PledgeInfo
    }

    pub resource interface PledgePrivate {
        // E.g Type<Domains>().identifier => A.9a0766d93b6608b7.Domains
        pub fun redeemNFT(
            identifier: String,
            receiver: Capability<&{NonFungibleToken.Receiver}>,
            feeTokens: @FungibleToken.Vault
        )
    }

    pub struct NFTPawn {
        pub let collection: Capability<&NonFungibleToken.Collection>
        pub var nftIDs: [UInt64]

        init(
            collection: Capability<&NonFungibleToken.Collection>,
            nftIDs: [UInt64]
        ) {
            self.collection = collection
            self.nftIDs = nftIDs
        }
    }

    pub resource Pledge: PledgePublic, PledgePrivate {
        access(self) let debitor: Address
        access(self) var expiry: UFix64
        access(self) let nftPawns: {String: NFTPawn}

        init(
            debitor: Address,
            expiry: UFix64,
            nftPawns: {String: NFTPawn}
        ) {
            self.debitor = debitor
            self.expiry = expiry
            self.nftPawns = nftPawns
        }

        pub fun getInfo(): PledgeInfo {
            let collections: [CollectionInfo] = []

            for key in self.nftPawns.keys {
                let nftLockUpInfo = CollectionInfo(
                    identifier: key,
                    nftIDs: self.nftPawns[key]!.nftIDs
                )
                collections.append(nftLockUpInfo)
            }

            return PledgeInfo(
                debitor: self.debitor,
                expiry: self.expiry,
                collections: collections
            )
        }

        pub fun redeemNFT(
            identifier: String,
            receiver: Capability<&{NonFungibleToken.Receiver}>,
            feeTokens: @FungibleToken.Vault
        ) {
            let currentTime = getCurrentBlock().timestamp
            if currentTime > self.expiry {
                panic("The reedem period has expired!")
            }

            if self.debitor != receiver.address {
                panic("Non authorized recipient!")
            }

            let nftLockUp = self.nftPawns[identifier]
                ?? panic("Non-supported NonFungibleToken.")

            let receiverRef = receiver.borrow()
                ?? panic("Could not borrow NonFungibleToken.Receiver reference.")
            let collectionRef = nftLockUp.collection.borrow()
                ?? panic("Could not borrow NonFungibleToken.Collection reference.")

            let admin = NFTPawnshop.getAdmin()
            let feeSent = feeTokens.balance

            if feeSent < admin.salePrice {
                panic(
                    "You did not send enough FLOW tokens. Expected: "
                    .concat(admin.salePrice.toString())
                )
            }

            var nftIDs: [UInt64] = nftLockUp.nftIDs

            for id in nftIDs {
                let nft <- collectionRef.withdraw(withdrawID: id)
                receiverRef.deposit(token: <- nft)
            }

            admin.deposit(salePrice: <- feeTokens)
        }
    }

    pub resource Admin {
        access(contract) var salePrice: UFix64
        access(contract) let feesVault: @FungibleToken.Vault
        access(contract) let nonFungibleTokenInfoMapping: {String: NonFungibleTokenInfo}

        init() {
            self.salePrice = 15.0
            self.feesVault <- FlowToken.createEmptyVault()
            self.nonFungibleTokenInfoMapping = {}
        }

        pub fun addNonFungibleTokenInfo(identifier: String, tokenInfo: NonFungibleTokenInfo) {
            self.nonFungibleTokenInfoMapping[identifier] = tokenInfo
        }

        pub fun updateSalePrice(salePrice: UFix64) {
            self.salePrice = salePrice
        }

        pub fun deposit(salePrice: @FungibleToken.Vault) {
            self.feesVault.deposit(from: <- salePrice)
        }

        pub fun withdraw(): @FungibleToken.Vault {
            return <- self.feesVault.withdraw(amount: self.salePrice)
        }

        pub fun addCollectionCap(
            identifier: String,
            collectionCap: Capability<&NonFungibleToken.Collection>
        ) {
            NFTPawnshop.collections[identifier] = collectionCap
        }

        destroy() {
            destroy self.feesVault
        }
    }

    pub fun getSalePrice(): UFix64 {
        let admin = self.getAdmin()

        return admin.salePrice
    }

    access(contract) fun getAdmin(): &Admin {
        let admin = self.account.getCapability(
            self.AdminPrivatePath
        ).borrow<&Admin>()
        ?? panic("Could not borrow AssetHandover.Admin reference.")

        return admin
    }

    pub fun pawnNFT(
        identifier: String,
        collectionProvider: Capability<&NonFungibleToken.Collection>,
        nftIDs: [UInt64],
        tokenReceiver: Capability<&FlowToken.Vault{FungibleToken.Receiver}>
    ): @Pledge {
        let collectionCap = self.collections[identifier]!
        let collectionReceiver = collectionCap.borrow()
            ?? panic("Could not borrow NonFungibleToken.Collection!")

        let collectionRef = collectionProvider.borrow()
            ?? panic("Could not borrow NonFungibleToken.Collection!")

        for nftID in nftIDs {
            let nft <- collectionRef.withdraw(withdrawID: nftID)
            collectionReceiver.deposit(token: <- nft)
        }

        let nftPawns: {String: NFTPawn} = {}
        nftPawns[identifier] = NFTPawn(
            collection: collectionCap,
            nftIDs: nftIDs
        )

        let admin = NFTPawnshop.getAdmin()

        let salePrice <- admin.withdraw()
        let receiverRef = tokenReceiver.borrow()
            ?? panic("Could not borrow FungibleToken.Receiver!")

        receiverRef.deposit(from: <- salePrice)
        let expiry = getCurrentBlock().timestamp + UFix64(365 * 24 * 60 * 60)

        return <- create Pledge(
            debitor: collectionRef.owner!.address,
            expiry: expiry,
            nftPawns: nftPawns
        )
    }
}
