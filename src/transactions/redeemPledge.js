export const redeemPledge = `
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import NFTPawnshop from 0xNFTPawnshop
import NonFungibleToken from 0xNonFungibleToken
import Domains from 0xDomains

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
`;
