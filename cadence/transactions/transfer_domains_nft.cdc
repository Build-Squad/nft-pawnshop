import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import Domains from "../contracts/Domains.cdc"

transaction(recipient: Address, nftID: UInt64) {
    prepare(account: AuthAccount) {
        let collectionProvider = account.getCapability<&Domains.Collection>(
            /private/flowNameServiceDomains
        ).borrow()
        ?? panic("Could not borrow NonFungibleToken.Provider!")

        let collectionReceiver = getAccount(recipient)
            .getCapability(/public/flowNameServiceDomains)
            .borrow<&Domains.Collection{NonFungibleToken.Receiver}>()
            ?? panic("Could not borrow NonFungibleToken.Receiver!")

        let nft <- collectionProvider.withdraw(withdrawID: nftID)
        collectionReceiver.deposit(token: <- nft)
    }
}
