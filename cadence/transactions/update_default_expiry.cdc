import NFTPawnshop from "../contracts/NFTPawnshop.cdc"

transaction(expiry: UFix64) {
    prepare(account: AuthAccount) {
        let admin = account.getCapability(
            NFTPawnshop.AdminPrivatePath
        ).borrow<&NFTPawnshop.Admin>()
        ?? panic("Could not borrow NFTPawnshop.Admin reference.")

        admin.updateExpiry(expiry: expiry)
    }
}
