export const setupAccount = `
import Domains from 0xDomains
import NonFungibleToken from 0xNonFungibleToken
import MetadataViews from 0xMetadataViews

transaction() {
    prepare(account: AuthAccount) {
        account.save<@NonFungibleToken.Collection>(
            <- Domains.createEmptyCollection(),
            to: Domains.DomainsStoragePath
        )

        account.link<&Domains.Collection{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, Domains.CollectionPublic, MetadataViews.ResolverCollection}>(
            Domains.DomainsPublicPath,
            target: Domains.DomainsStoragePath
        )
        account.link<&Domains.Collection>(
            Domains.DomainsPrivatePath,
            target: Domains.DomainsStoragePath
        )
    }
}
`;
