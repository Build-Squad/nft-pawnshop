import FungibleToken from "../contracts/FungibleToken.cdc"
import NFTPawnshop from "../contracts/NFTPawnshop.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import Domains from "../contracts/Domains.cdc"

transaction {
    prepare(account: AuthAccount) {
        let receiver = account.getCapability<&{NonFungibleToken.Receiver}>(
            Domains.DomainsPublicPath
        )

        let identifier = Domains.getType().identifier

        let vault = account.borrow<&FungibleToken.Vault>(
            from: /storage/flowTokenVault
        ) ?? panic("Could not borrow FungibleToken.Vault reference.")

        let feeTokens <- vault.withdraw(
            amount: NFTPawnshop.getSalePrice()
        )

        let pledge <- account.load<@NFTPawnshop.Pledge>(
            from: /storage/nftPawnshop
        ) ?? panic("Could not load NFTPawnshop.Pledge resource.")

        pledge.redeemNFT(
            identifier: identifier,
            receiver: receiver,
            feeTokens: <- feeTokens
        )

        account.unlink(/public/nftPawnshop)
        account.unlink(/private/nftPawnshop)

        destroy pledge
    }
}
