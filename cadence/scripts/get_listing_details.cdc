import NFTStorefrontV2 from "NFTStorefrontV2"

pub fun main(account: Address, listingResourceID: UInt64): NFTStorefrontV2.ListingDetails {
    let storefrontRef = getAccount(account)
        .getCapability<&NFTStorefrontV2.Storefront{NFTStorefrontV2.StorefrontPublic}>(
            NFTStorefrontV2.StorefrontPublicPath
        ).borrow() ?? panic("Could not borrow public storefront from address")

    let listing = storefrontRef.borrowListing(
        listingResourceID: listingResourceID
    ) ?? panic("No item with that ID")

    return listing.getDetails()
}
