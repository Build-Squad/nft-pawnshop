import Domains from "../contracts/Domains.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import MetadataViews from "../contracts/MetadataViews.cdc"

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
