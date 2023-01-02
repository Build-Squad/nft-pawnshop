import NFTStorefrontV2 from "../contracts/NFTStorefrontV2.cdc"

transaction {
    prepare(acct: AuthAccount) {
        if acct.borrow<&NFTStorefrontV2.Storefront>(from: NFTStorefrontV2.StorefrontStoragePath) == nil {
            let storefront <- NFTStorefrontV2.createStorefront()

            acct.save(<-storefront, to: NFTStorefrontV2.StorefrontStoragePath)

            acct.link<&NFTStorefrontV2.Storefront{NFTStorefrontV2.StorefrontPublic}>(
                NFTStorefrontV2.StorefrontPublicPath,
                target: NFTStorefrontV2.StorefrontStoragePath
            )
        }
    }
}
