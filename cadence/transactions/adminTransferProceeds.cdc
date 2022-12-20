import NFTPawnshop from "../contracts/NFTPawnshop.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import Domains from "../contracts/Domains.cdc"

transaction(recipient: Address) {
    prepare(account: AuthAccount) {
        let admin = account.getCapability(
            NFTPawnshop.AdminPrivatePath
        ).borrow<&NFTPawnshop.Admin>()
        ?? panic("Could not borrow NFTPawnshop.Admin reference.")

        let receiver = getAccount(recipient).getCapability<&{NonFungibleToken.Receiver}>(
            Domains.DomainsPublicPath
        )

        admin.transferProceeds(receiver: receiver)
    }
}
