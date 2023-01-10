import MetadataViews from 0x631e88ae7f1d7c20
import NFTCatalog from 0x324c34e1c517e4db
import NFTRetrieval from 0x324c34e1c517e4db

pub fun main(ownerAddress: Address): {String: Number} {
    let catalog = NFTCatalog.getCatalog()
    let account = getAuthAccount(ownerAddress)
    let items: {String: Number} = {}

    for key in catalog.keys {
        let value = catalog[key]!
        let keyHash = String.encodeHex(HashAlgorithm.SHA3_256.hash(key.utf8))
        let tempPathStr = "catalog".concat(keyHash)
        let tempPublicPath = PublicPath(identifier: tempPathStr)!

        account.link<&{MetadataViews.ResolverCollection}>(
            tempPublicPath,
            target: value.collectionData.storagePath
        )

        let collectionCap = account.getCapability<&AnyResource{MetadataViews.ResolverCollection}>(
            tempPublicPath
        )

        if !collectionCap.check() {
            continue
        }

        let count = NFTRetrieval.getNFTCountFromCap(
            collectionIdentifier: key,
            collectionCap: collectionCap
        )

        if count > 0 {
            items[key] = count
        }
    }

    return items
}
