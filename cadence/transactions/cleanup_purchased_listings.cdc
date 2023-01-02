import NFTStorefrontV2 from "../contracts/NFTStorefrontV2.cdc"

transaction(storefrontAddress: Address, listingResourceID: UInt64) {
    let storefront: &NFTStorefrontV2.Storefront{NFTStorefrontV2.StorefrontPublic}

    prepare(acct: AuthAccount) {
        self.storefront = getAccount(storefrontAddress)
            .getCapability<&NFTStorefrontV2.Storefront{NFTStorefrontV2.StorefrontPublic}>(
                NFTStorefrontV2.StorefrontPublicPath
            )
            .borrow()
            ?? panic("Could not borrow Storefront from provided address")
    }

    execute {
        self.storefront.cleanupPurchasedListings(listingResourceID: listingResourceID)
    }
}
