import FungibleToken from 0xee82856bf20e2aa6
import FlowToken from 0x0ae53cb6e3f42a79
import NFTPawnshop from "../contracts/NFTPawnshop.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import Domains from "../contracts/Domains.cdc"

transaction {
    prepare(account: AuthAccount) {
        let receiver = account.getCapability<&{NonFungibleToken.Receiver}>(
            Domains.DomainsPublicPath
        )

        let identifier = "A.f8d6e0586b0a20c7.Domains"

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