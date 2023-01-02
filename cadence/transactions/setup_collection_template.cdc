import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import MetadataViews from "../contracts/MetadataViews.cdc"
import {CONTRACT_NAME} from {CONTRACT_ADDRESS}

transaction {

    prepare(account: AuthAccount) {
        // Create a new empty collection
        let collection <- {CONTRACT_NAME}.createEmptyCollection()

        // save it to the account
        account.save(<-collection, to: {STORAGE_PATH})

        // create a public capability for the collection
        account.link<&{PUBLIC_LINKED_TYPE}>(
            {PUBLIC_PATH},
            target: {STORAGE_PATH}
        )

        // create a private capability for the collection
        account.link<&{PRIVATE_LINKED_TYPE}>(
            {PRIVATE_PATH},
            target: {STORAGE_PATH}
        )
    }
}
