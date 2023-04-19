import NFTPawnshop from "../contracts/NFTPawnshop.cdc"

transaction(salePrice: UFix64) {
    prepare(account: AuthAccount) {
        let admin = account.getCapability(
            NFTPawnshop.AdminPrivatePath
        ).borrow<&NFTPawnshop.Admin>()
        ?? panic("Could not borrow NFTPawnshop.Admin reference.")

        admin.updateSalePrice(salePrice: salePrice)
    }
}
