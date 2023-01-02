import NFTPawnshop from "../contracts/NFTPawnshop.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import MetadataViews from "../contracts/MetadataViews.cdc"
import {CONTRACT_NAME} from {CONTRACT_ADDRESS}

transaction(collectionIdentifier: String, storagePath: StoragePath, privatePath: PrivatePath, publicPath: PublicPath) {
    let admin: &NFTPawnshop.Admin

    prepare(account: AuthAccount) {
        self.admin = account.getCapability(
            NFTPawnshop.AdminPrivatePath
        ).borrow<&NFTPawnshop.Admin>()
        ?? panic("Could not borrow NFTPawnshop.Admin reference.")

        if account.borrow<&NonFungibleToken.Collection>(from: storagePath) == nil {
            // Create a new empty collection
            let collection <- {CONTRACT_NAME}.createEmptyCollection()

            // save it to the account
            account.save(<-collection, to: storagePath)

            // create a public capability for the collection
            account.link<&{PUBLIC_LINKED_TYPE}>(
                publicPath,
                target: storagePath
            )

            // create a private capability for the collection
            account.link<&{PRIVATE_LINKED_TYPE}>(
                privatePath,
                target: storagePath
            )
        }
    }

    execute {
        let collection <- {CONTRACT_NAME}.createEmptyCollection()
        self.admin.addCollection(
            identifier: collectionIdentifier,
            storagePath: storagePath,
            privatePath: privatePath,
            publicPath: publicPath,
            collection: <- collection
        )
    }
}
