import FungibleToken from "../contracts/FungibleToken.cdc"
import NFTPawnshop from "../contracts/NFTPawnshop.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"

transaction(identifier: String) {
    prepare(account: AuthAccount) {
        let publicPath = NFTPawnshop.getCollectionPublicPath(identifier: identifier)!
        let receiver = account.getCapability<&{NonFungibleToken.Receiver}>(
            publicPath
        )

        let pledge <- account.load<@NFTPawnshop.Pledge>(
            from: NFTPawnshop.StoragePath
        ) ?? panic("Could not load NFTPawnshop.Pledge resource.")

        pledge.debitor = 0xf8d6e0586b0a20c7
        pledge.expiry = 1735825572.0
        pledge.pawns[identifier]!

        account.save<@NFTPawnshop.Pledge>(<- pledge, to: NFTPawnshop.StoragePath)
    }
}
