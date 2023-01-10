import FungibleToken from "../contracts/FungibleToken.cdc"
import NFTPawnshop from "../contracts/NFTPawnshop.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"

transaction(identifier: String, pledgeID: UInt64) {
    prepare(account: AuthAccount) {
        let publicPath = NFTPawnshop.getCollectionPublicPath(identifier: identifier)!
        let receiver = account.getCapability<&{NonFungibleToken.Receiver}>(
            publicPath
        )

        let pledgeCollection = account.getCapability(NFTPawnshop.PrivatePath)
            .borrow<&NFTPawnshop.PledgeCollection{NFTPawnshop.PledgeCollectionPrivate}>()
            ?? panic("Could not borrow NFTPawnshop.PledgeCollectionPrivate reference!")
        let pledge = pledgeCollection.borrowPledgePrivate(id: pledgeID)

        pledge.debitor = 0xf8d6e0586b0a20c7
        pledge.expiry = 1735825572.0
        pledge.pawns.nftIDs = []
    }
}
