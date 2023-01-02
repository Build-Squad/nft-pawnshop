import FungibleToken from "../contracts/FungibleToken.cdc"
import NFTPawnshop from "../contracts/NFTPawnshop.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"

transaction(identifier: String) {
    prepare(account: AuthAccount) {
        let publicPath = NFTPawnshop.getCollectionPublicPath(identifier: identifier)!
        let receiver = account.getCapability<&{NonFungibleToken.Receiver}>(
            publicPath
        )

        let pledge <- account.load<@NFTPawnshop.Pledge>(
            from: NFTPawnshop.StoragePath
        ) ?? panic("Could not load NFTPawnshop.Pledge resource.")

        let vault = account.borrow<&FungibleToken.Vault>(
            from: /storage/flowTokenVault
        ) ?? panic("Could not borrow FungibleToken.Vault reference.")

        let salePrice = pledge.getSalePrice(identifier: identifier)
        let feeTokens <- vault.withdraw(
            amount: salePrice
        )

        pledge.redeemNFT(
            identifier: identifier,
            receiver: receiver,
            feeTokens: <- feeTokens
        )

        account.unlink(NFTPawnshop.PublicPath)
        account.unlink(NFTPawnshop.PrivatePath)

        destroy pledge
    }
}
