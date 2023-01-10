import NFTCatalog from 0xNFTCatalog

pub fun main(): [String] {
    let catalog: {String : NFTCatalog.NFTCatalogMetadata} = NFTCatalog.getCatalog()

    return catalog.keys
}
