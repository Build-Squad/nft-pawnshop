import NonFungibleToken from "NonFungibleToken"
import MetadataViews from "MetadataViews"
import NFTCatalog from "NFTCatalog"
import ExampleNFT from "ExampleNFT"

transaction {
    prepare(signer: AuthAccount) {
        NFTCatalog.addCatalogEntry(
            collectionIdentifier: "ExampleNFT",
            metadata: NFTCatalog.NFTCatalogMetadata(
                contractName: "ExampleNFT",
                contractAddress: 0xf8d6e0586b0a20c7,
                nftType: Type<@ExampleNFT.NFT>(),
                collectionData: NFTCatalog.NFTCollectionData(
                    storagePath: ExampleNFT.CollectionStoragePath,
                    publicPath: ExampleNFT.CollectionPublicPath,
                    privatePath: /private/exampleNFTCollection,
                    publicLinkedType: Type<&ExampleNFT.Collection{ExampleNFT.ExampleNFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(),
                    privateLinkedType: Type<&ExampleNFT.Collection{ExampleNFT.ExampleNFTCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Provider,MetadataViews.ResolverCollection}>()
                ),
                collectionDisplay: MetadataViews.NFTCollectionDisplay(
                    name: "The Example Collection",
                    description: "This collection is used as an example to help you develop your next Flow NFT.",
                    externalURL: MetadataViews.ExternalURL("https://example-nft.onflow.org"),
                    squareImage: MetadataViews.Media(
                        file: MetadataViews.HTTPFile(
                            url: "https://assets.website-files.com/5f6294c0c7a8cdd643b1c820/5f6294c0c7a8cda55cb1c936_Flow_Wordmark.svg"
                        ),
                        mediaType: "image/svg+xml"
                    ),
                    bannerImage: MetadataViews.Media(
                        file: MetadataViews.HTTPFile(
                            url: "https://assets.website-files.com/5f6294c0c7a8cdd643b1c820/5f6294c0c7a8cda55cb1c936_Flow_Wordmark.svg"
                        ),
                        mediaType: "image/svg+xml"
                    ),
                    socials: {
                        "twitter": MetadataViews.ExternalURL("https://twitter.com/flow_blockchain")
                    }
                )
            )
        )
    }
}
