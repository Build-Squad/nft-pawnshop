import NFTPawnshop from "../contracts/NFTPawnshop.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import MetadataViews from "../contracts/MetadataViews.cdc"
import ExampleNFT from 0xf8d6e0586b0a20c7

transaction(collectionIdentifier: String, storagePath: StoragePath, privatePath: PrivatePath, publicPath: PublicPath) {
    let admin: &NFTPawnshop.Admin

    prepare(account: AuthAccount) {
        self.admin = account.getCapability(
            NFTPawnshop.AdminPrivatePath
        ).borrow<&NFTPawnshop.Admin>()
        ?? panic("Could not borrow NFTPawnshop.Admin reference.")

        if account.borrow<&NonFungibleToken.Collection>(from: storagePath) == nil {
            // Create a new empty collection
            let collection <- ExampleNFT.createEmptyCollection()

            // save it to the account
            account.save(<-collection, to: storagePath)

            // create a public capability for the collection
            account.link<&ExampleNFT.Collection{ExampleNFT.ExampleNFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
                publicPath,
                target: storagePath
            )

            // create a private capability for the collection
            account.link<&ExampleNFT.Collection{ExampleNFT.ExampleNFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Provider,MetadataViews.ResolverCollection}>(
                privatePath,
                target: storagePath
            )
        }
    }

    execute {
        let collection <- ExampleNFT.createEmptyCollection()
        self.admin.addCollection(
            identifier: collectionIdentifier,
            storagePath: storagePath,
            privatePath: privatePath,
            publicPath: publicPath,
            collection: <- collection
        )
    }
}
