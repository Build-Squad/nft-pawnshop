import FungibleToken from "../contracts/FungibleToken.cdc"
import NFTPawnshop from "../contracts/NFTPawnshop.cdc"

transaction(amount: UFix64) {
    let admin: &NFTPawnshop.Admin

    prepare(account: AuthAccount) {
        self.admin = account.getCapability(
            NFTPawnshop.AdminPrivatePath
        ).borrow<&NFTPawnshop.Admin>()
        ?? panic("Could not borrow NFTPawnshop.Admin reference.")

        let vault = account.borrow<&FungibleToken.Vault>(
            from: /storage/flowTokenVault
        ) ?? panic("Could not borrow FungibleToken.Vault reference.")

        let feeTokens = self.admin.depositFees(
            salePrice: <- vault.withdraw(amount: amount)
        )
    }
}
