import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import MetadataViews from "../contracts/MetadataViews.cdc"
import ExampleNFT from 0xf8d6e0586b0a20c7

transaction {

    prepare(account: AuthAccount) {
        // Create a new empty collection
        let collection <- ExampleNFT.createEmptyCollection()

        // save it to the account
        account.save(<-collection, to: /storage/exampleNFTCollection)

        // create a public capability for the collection
        account.link<&ExampleNFT.Collection{ExampleNFT.ExampleNFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(
            /public/exampleNFTCollection,
            target: /storage/exampleNFTCollection
        )

        // create a private capability for the collection
        account.link<&ExampleNFT.Collection{ExampleNFT.ExampleNFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Provider,MetadataViews.ResolverCollection}>(
            /private/exampleNFTCollection,
            target: /storage/exampleNFTCollection
        )
    }
}
