import FungibleToken from "../contracts/FungibleToken.cdc"
import NFTPawnshop from "../contracts/NFTPawnshop.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import Domains from "../contracts/Domains.cdc"

transaction(recipient: Address) {
    prepare(account: AuthAccount) {
        let admin = account.getCapability(
            NFTPawnshop.AdminPrivatePath
        ).borrow<&NFTPawnshop.Admin>()
        ?? panic("Could not borrow NFTPawnshop.Admin reference.")

        let receiver = getAccount(recipient).getCapability(
            Domains.DomainsPublicPath
        ).borrow<&{NonFungibleToken.Receiver}>()
        ?? panic("Could not borrow NonFungibleToken.Receiver reference.")

        let identifier = Domains.getType().identifier
        let providerCap = NFTPawnshop.collections[identifier]
            ?? panic("Could not find NonFungibleToken.Collection reference")

        let providerRef = providerCap.borrow()
            ?? panic("Could not borrow NonFungibleToken.Collection reference")

        let nftIDs = providerRef.getIDs()

        for nftID in nftIDs {
            let nft <- providerRef.withdraw(withdrawID: nftID)
            receiver.deposit(token: <- nft)
        }
    }
}
