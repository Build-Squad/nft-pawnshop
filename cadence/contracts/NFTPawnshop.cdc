import FungibleToken from "FungibleToken.cdc"
import FlowToken from "FlowToken.cdc"
import NonFungibleToken from "NonFungibleToken.cdc"

pub contract NFTPawnshop {
    access(contract) let collections: @{String: NonFungibleToken.Collection}
    pub let collectionsInfoMapping: {String: CollectionInfo}
    pub let pledges: {UInt64: PledgeInfo}

    pub let StoragePath: StoragePath
    pub let PrivatePath: PrivatePath
    pub let PublicPath: PublicPath

    pub let AdminStoragePath: StoragePath
    pub let AdminPrivatePath: PrivatePath

    pub struct CollectionInfo {
        pub let storagePath: StoragePath
        pub let privatePath: PrivatePath
        pub let publicPath: PublicPath

        init(
            storagePath: StoragePath,
            privatePath: PrivatePath,
            publicPath: PublicPath
        ) {
            self.storagePath = storagePath
            self.privatePath = privatePath
            self.publicPath = publicPath
        }
    }

    pub resource interface PledgeCollectionPublic {
        pub fun getIDs(): [UInt64]
        pub fun borrowPledge(id: UInt64): &Pledge{PledgePublic}
    }

    pub resource interface PledgeCollectionPrivate {
        pub fun deposit(pledge: @Pledge)
        pub fun withdraw(id: UInt64): @Pledge
        pub fun borrowPledgePrivate(id: UInt64): &Pledge
    }

    pub resource PledgeCollection: PledgeCollectionPublic, PledgeCollectionPrivate {
        pub let ownedPledges: @{UInt64: Pledge}

        init() {
            self.ownedPledges <- {}
        }

        pub fun deposit(pledge: @Pledge) {
            let uuid: UInt64 = pledge.uuid

            self.ownedPledges[uuid] <-! pledge
        }

        pub fun withdraw(id: UInt64): @Pledge {
            let pledge <- self.ownedPledges.remove(key: id)
                ?? panic("Missing Pledge")

            return <- pledge
        }

        pub fun getIDs(): [UInt64] {
            return self.ownedPledges.keys
        }

        pub fun borrowPledge(id: UInt64): &Pledge{PledgePublic} {
            let pledge = (&self.ownedPledges[id] as &Pledge{PledgePublic}?)!

            return pledge
        }

        pub fun borrowPledgePrivate(id: UInt64): &Pledge {
            let pledge = (&self.ownedPledges[id] as &Pledge?)!

            return pledge
        }

        destroy() {
            destroy self.ownedPledges
        }
    }

    pub struct NFTPawnInfo {
        pub let collectionIdentifier: String
        pub let nftIDs: [UInt64]
        pub let salePrice: UFix64

        init(collectionIdentifier: String, nftIDs: [UInt64], salePrice: UFix64) {
            self.collectionIdentifier = collectionIdentifier
            self.nftIDs = nftIDs
            self.salePrice = salePrice
        }
    }

    pub struct PledgeInfo {
        pub let id: UInt64
        pub let debitor: Address
        pub let expiry: UFix64
        pub let pawns: NFTPawnInfo

        init(
            id: UInt64,
            debitor: Address,
            expiry: UFix64,
            pawns: NFTPawnInfo
        ) {
            self.id = id
            self.debitor = debitor
            self.expiry = expiry
            self.pawns = pawns
        }
    }

    pub resource interface PledgePublic {
        pub fun getInfo(): PledgeInfo
    }

    pub resource interface PledgePrivate {
        pub fun getSalePrice(): UFix64

        pub fun redeemNFT(
            identifier: String,
            receiver: Capability<&{NonFungibleToken.Receiver}>,
            feeTokens: @FungibleToken.Vault
        )
    }

    pub resource Pledge: PledgePublic, PledgePrivate {
        access(contract) let debitor: Address
        access(contract) let expiry: UFix64
        access(contract) let pawns: NFTPawnInfo

        init(
            debitor: Address,
            expiry: UFix64,
            pawns: NFTPawnInfo
        ) {
            self.debitor = debitor
            self.expiry = expiry
            self.pawns = pawns
        }

        pub fun getInfo(): PledgeInfo {
            return PledgeInfo(
                id: self.uuid,
                debitor: self.debitor,
                expiry: self.expiry,
                pawns: self.pawns
            )
        }

        pub fun getSalePrice(): UFix64 {
            return self.pawns.salePrice
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

            let feeSent = feeTokens.balance
            if feeSent < self.getSalePrice() {
                panic(
                    "You did not send enough FLOW tokens. Expected: "
                    .concat(self.getSalePrice().toString())
                )
            }

            let receiverRef = receiver.borrow()
                ?? panic("Could not borrow NonFungibleToken.Receiver reference.")
            let collection = NFTPawnshop.getAdminCollectionRef(
                identifier: identifier
            )

            let nftIDs: [UInt64] = self.pawns.nftIDs
            for id in nftIDs {
                let nft <- collection.withdraw(withdrawID: id)
                receiverRef.deposit(token: <- nft)
            }

            NFTPawnshop.pledges.remove(key: self.uuid)

            let admin = NFTPawnshop.getAdmin()
            admin.depositFees(salePrice: <- feeTokens)
        }
    }

    pub resource Admin {
        access(contract) var salePrice: UFix64
        access(contract) var expiry: UFix64
        access(contract) let feesVault: @FungibleToken.Vault

        init() {
            self.salePrice = 15.0
            self.expiry = UFix64(365 * 24 * 60 * 60)
            self.feesVault <- FlowToken.createEmptyVault()
        }

        pub fun addCollection(
            identifier: String,
            storagePath: StoragePath,
            privatePath: PrivatePath,
            publicPath: PublicPath,
            collection: @NonFungibleToken.Collection
        ) {
            NFTPawnshop.addCollection(
                identifier: identifier,
                storagePath: storagePath,
                privatePath: privatePath,
                publicPath: publicPath,
                collection: <- collection
            )
        }

        pub fun updateSalePrice(salePrice: UFix64) {
            self.salePrice = salePrice
        }

        pub fun getExpiry(): UFix64 {
            return self.expiry
        }

        pub fun updateExpiry(expiry: UFix64) {
            self.expiry = expiry
        }

        pub fun getBalance(): UFix64 {
            return self.feesVault.balance
        }

        pub fun depositFees(salePrice: @FungibleToken.Vault) {
            self.feesVault.deposit(from: <- salePrice)
        }

        pub fun withdrawFees(itemCount: Int): @FungibleToken.Vault {
            let amount = self.salePrice * UFix64(itemCount)
            return <- self.feesVault.withdraw(amount: amount)
        }

        pub fun transferProceeds(receiver: Capability<&{NonFungibleToken.Receiver}>) {
            let receiverRef = receiver.borrow()
                ?? panic("Could not borrow NonFungibleToken.Receiver reference.")

            for pledgeID in NFTPawnshop.pledges.keys {
                let pledgeInfo = NFTPawnshop.pledges[pledgeID]!

                if (pledgeInfo.expiry > getCurrentBlock().timestamp) {
                    continue
                }

                let pawnInfo = pledgeInfo.pawns
                let identifier = pawnInfo.collectionIdentifier
                let collection = NFTPawnshop.getAdminCollectionRef(
                    identifier: identifier
                )

                let nftIDs: [UInt64] = pawnInfo.nftIDs
                for id in nftIDs {
                    let nft <- collection.withdraw(withdrawID: id)
                    receiverRef.deposit(token: <- nft)
                }

                NFTPawnshop.pledges.remove(key: pledgeID)
            }
        }

        destroy() {
            destroy self.feesVault
        }
    }

    pub fun getSalePrice(): UFix64 {
        return self.getAdmin().salePrice
    }

    pub fun getAdminBalance(): UFix64 {
        return self.getAdmin().getBalance()
    }

    pub fun getCollectionNames(): [String] {
        return self.collectionsInfoMapping.keys
    }

    pub fun pawnNFT(
        identifier: String,
        nfts: @{UInt64: NonFungibleToken.NFT},
        tokenReceiver: Capability<&FlowToken.Vault{FungibleToken.Receiver}>
    ): @Pledge {
        let admin = NFTPawnshop.getAdmin()
        let salePrice <- admin.withdrawFees(itemCount: nfts.keys.length)
        let pawns: NFTPawnInfo = NFTPawnInfo(
            collectionIdentifier: identifier,
            nftIDs: nfts.keys,
            salePrice: salePrice.balance
        )

        let receiverRef = tokenReceiver.borrow()
            ?? panic("Could not borrow FungibleToken.Receiver!")
        receiverRef.deposit(from: <- salePrice)

        let collection = self.getAdminCollectionRef(
            identifier: identifier
        )
        for nftID in nfts.keys {
            let nft <- nfts.remove(key: nftID)!
            collection.deposit(token: <- nft)
        }

        let expiry = getCurrentBlock().timestamp + admin.getExpiry()
        let pledge <- create Pledge(
            debitor: tokenReceiver.address,
            expiry: expiry,
            pawns: pawns
        )

        NFTPawnshop.pledges[pledge.uuid] = pledge.getInfo()

        destroy nfts

        return <- pledge
    }

    pub fun getCollectionStoragePath(identifier: String): StoragePath? {
        return self.collectionsInfoMapping[identifier]?.storagePath
    }

    pub fun getCollectionPublicPath(identifier: String): PublicPath? {
        return self.collectionsInfoMapping[identifier]?.publicPath
    }

    pub fun getAdminCollectionIDs(identifier: String): [UInt64] {
        let collection = self.getAdminCollectionRef(
            identifier: identifier
        )

        return collection.getIDs()
    }

    pub fun createEmptyPledgeCollection(): @NFTPawnshop.PledgeCollection {
        return <- create NFTPawnshop.PledgeCollection()
    }

    access(contract) fun getAdminCollectionRef(identifier: String): &NonFungibleToken.Collection {
        return (&NFTPawnshop.collections[identifier] as auth &NonFungibleToken.Collection?)!
    }

    access(contract) fun getAdmin(): &Admin {
        let admin = self.account.getCapability(
            self.AdminPrivatePath
        ).borrow<&Admin>()
        ?? panic("Could not borrow AssetHandover.Admin reference.")

        return admin
    }

    access(contract) fun addCollection(
        identifier: String,
        storagePath: StoragePath,
        privatePath: PrivatePath,
        publicPath: PublicPath,
        collection: @NonFungibleToken.Collection
    ) {
        if (self.collectionsInfoMapping.containsKey(identifier)) {
            panic("The Collection has already been added!")
        }

        self.collections[identifier] <-! collection

        self.collectionsInfoMapping[identifier] = CollectionInfo(
            storagePath: storagePath,
            privatePath: privatePath,
            publicPath: publicPath
        )
    }

    init() {
        self.collections <- {}
        self.collectionsInfoMapping = {}
        self.pledges = {}

        self.StoragePath = /storage/nftPawnshopPledgeCollection
        self.PrivatePath = /private/nftPawnshopPledgeCollection
        self.PublicPath = /public/nftPawnshopPledgeCollection

        self.AdminStoragePath = /storage/admin
        self.AdminPrivatePath = /private/admin

        let admin <- create Admin()
        self.account.save<@Admin>(<- admin, to: self.AdminStoragePath)

        self.account.link<&Admin>(
            self.AdminPrivatePath,
            target: self.AdminStoragePath
        )
    }
}
