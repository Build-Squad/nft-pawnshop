import FungibleToken from "../contracts/FungibleToken.cdc"
import FlowToken from "../contracts/FlowToken.cdc"
import NFTPawnshop from "../contracts/NFTPawnshop.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import MetadataViews from "../contracts/MetadataViews.cdc"
import Domains from "../contracts/Domains.cdc"

transaction() {
    let admin: &NFTPawnshop.Admin
    let collectionCap: Capability<&NonFungibleToken.Collection>

    prepare(account: AuthAccount) {
        self.admin = account.getCapability(
            NFTPawnshop.AdminPrivatePath
        ).borrow<&NFTPawnshop.Admin>()
        ?? panic("Could not borrow NFTPawnshop.Admin reference.")

        let vault = account.borrow<&FungibleToken.Vault>(
            from: /storage/flowTokenVault
        ) ?? panic("Could not borrow FungibleToken.Vault reference.")

        let feeTokens = self.admin.deposit(
            salePrice: <- vault.withdraw(amount: 500.0)
        )

        account.link<&NonFungibleToken.Collection>(
            /private/flowNameServiceDomains,
            target: /storage/flowNameServiceDomains
        )
        self.collectionCap = account.getCapability<&NonFungibleToken.Collection>(
            /private/flowNameServiceDomains
        )
    }

    execute {
        let identifier = Type<Domains>().identifier
        var nonFungibleTokenInfo = NFTPawnshop.NonFungibleTokenInfo(
            name: "Domains",
            publicPath: /public/flowNameServiceDomains,
            privatePath: /private/flowNameServiceDomains,
            storagePath: /storage/flowNameServiceDomains,
            publicType: Type<&Domains.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, Domains.CollectionPublic, MetadataViews.ResolverCollection}>(),
            privateType: Type<&Domains.Collection>()
        )
        self.admin.addNonFungibleTokenInfo(identifier: identifier, tokenInfo: nonFungibleTokenInfo)
        self.admin.addCollectionCap(identifier: identifier, collectionCap: self.collectionCap)
    }
}
