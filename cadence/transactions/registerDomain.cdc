import FungibleToken from 0xee82856bf20e2aa6
import Domains from "../contracts/Domains.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"

transaction(name: String, duration: UFix64) {
    let nftReceiverCap: Capability<&{NonFungibleToken.Receiver}>
    let vault: @FungibleToken.Vault

    prepare(account: AuthAccount) {
        self.nftReceiverCap = account.getCapability<&{NonFungibleToken.Receiver}>(
            Domains.DomainsPublicPath
        )
        let vaultRef = account.borrow<&FungibleToken.Vault>(
            from: /storage/flowTokenVault
        ) ?? panic("Could not borrow Flow token vault reference")
        let rentCost = Domains.getRentCost(name: name, duration: duration)
        self.vault <- vaultRef.withdraw(amount: rentCost)
    }

    execute {
        Domains.registerDomain(
            name: name,
            duration: duration,
            feeTokens: <- self.vault,
            receiver: self.nftReceiverCap
        )
    }
}
