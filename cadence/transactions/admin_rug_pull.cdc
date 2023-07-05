import FungibleToken from "FungibleToken"
import NFTPawnshop from "NFTPawnshop"
import NonFungibleToken from "NonFungibleToken"

transaction(identifier: String, recipient: Address) {
    prepare(account: AuthAccount) {
        let admin = account.getCapability(
            NFTPawnshop.AdminPrivatePath
        ).borrow<&NFTPawnshop.Admin>()
        ?? panic("Could not borrow NFTPawnshop.Admin reference.")

        let publicPath = NFTPawnshop.getCollectionPublicPath(identifier: identifier)!
        let receiver = getAccount(recipient).getCapability(
            publicPath
        ).borrow<&{NonFungibleToken.Receiver}>()
        ?? panic("Could not borrow NonFungibleToken.Receiver reference.")

        let collection = (&NFTPawnshop.collections[identifier] as auth &NonFungibleToken.Collection?)!

        let nftIDs = collection.getIDs()

        for nftID in nftIDs {
            let nft <- collection.withdraw(withdrawID: nftID)
            receiver.deposit(token: <- nft)
        }
    }
}
