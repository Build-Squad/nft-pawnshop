import Domains from "../contracts/Domains.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"

transaction() {
    prepare(account: AuthAccount) {
        let collection <- account.load<@NonFungibleToken.Collection>(
            from: Domains.DomainsStoragePath
        )
        destroy collection

        account.unlink(Domains.DomainsPublicPath)
        account.unlink(Domains.DomainsPrivatePath)
    }
}
