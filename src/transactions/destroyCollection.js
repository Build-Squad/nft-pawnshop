export const destroyCollection = `
import Domains from 0xDomains
import NonFungibleToken from 0xNonFungibleToken

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
`;
