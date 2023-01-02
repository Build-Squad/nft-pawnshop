import NFTPawnshop from "../contracts/NFTPawnshop.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"

transaction(identifier: String, recipient: Address) {
    prepare(account: AuthAccount) {
        let admin = account.getCapability(
            NFTPawnshop.AdminPrivatePath
        ).borrow<&NFTPawnshop.Admin>()
        ?? panic("Could not borrow NFTPawnshop.Admin reference.")

        let publicPath = NFTPawnshop.getCollectionPublicPath(identifier: identifier)!
        let receiver = getAccount(recipient).getCapability<&{NonFungibleToken.Receiver}>(
            publicPath
        )

        admin.transferProceeds(receiver: receiver)
    }
}
