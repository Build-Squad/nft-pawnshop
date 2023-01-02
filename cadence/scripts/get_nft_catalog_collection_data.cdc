import NonFungibleToken from 0xNonFungibleToken
import MetadataViews from 0xMetadataViews
import NFTCatalog from 0xNFTCatalog

pub struct NFTCollection {
    pub let contractName: String
    pub let contractAddress: String
    pub let storagePath: StoragePath
    pub let publicPath: PublicPath
    pub let privatePath: PrivatePath
    pub let publicLinkedType: Type
    pub let privateLinkedType: Type
    pub let collectionName: String
    pub let collectionDescription: String
    pub let collectionSquareImage: String
    pub let collectionBannerImage: String

    init(
        contractName: String,
        contractAddress: String,
        storagePath: StoragePath,
        publicPath: PublicPath,
        privatePath: PrivatePath,
        publicLinkedType: Type,
        privateLinkedType: Type,
        collectionName: String,
        collectionDescription: String,
        collectionSquareImage: String,
        collectionBannerImage: String
    ) {
        self.contractName = contractName
        self.contractAddress = contractAddress
        self.storagePath = storagePath
        self.publicPath = publicPath
        self.privatePath = privatePath
        self.publicLinkedType = publicLinkedType
        self.privateLinkedType = privateLinkedType
        self.collectionName = collectionName
        self.collectionDescription = collectionDescription
        self.collectionSquareImage = collectionSquareImage
        self.collectionBannerImage = collectionBannerImage
    }
}

pub fun main(collectionIdentifier: String) : NFTCollection {
    let catalog = NFTCatalog.getCatalog()

    assert(
        catalog.containsKey(collectionIdentifier),
        message: "Provided collection is not in the NFT Catalog."
    )

    let contractView = catalog[collectionIdentifier]!
    let collectionDataView = catalog[collectionIdentifier]!.collectionData
    let collectionDisplayView = catalog[collectionIdentifier]!.collectionDisplay

    return NFTCollection(
        contractName: contractView.contractName,
        contractAddress: contractView.contractAddress.toString(),
        storagePath: collectionDataView!.storagePath,
        publicPath: collectionDataView!.publicPath,
        privatePath: collectionDataView!.privatePath,
        publicLinkedType: collectionDataView!.publicLinkedType,
        privateLinkedType: collectionDataView!.privateLinkedType,
        collectionName: collectionDisplayView!.name,
        collectionDescription: collectionDisplayView!.description,
        collectionSquareImage: collectionDisplayView!.squareImage.file.uri(),
        collectionBannerImage: collectionDisplayView!.bannerImage.file.uri()
    )
}
