import FungibleToken from "FungibleToken"
import NFTPawnshop from "NFTPawnshop"
import NonFungibleToken from "NonFungibleToken"

transaction(identifier: String, pledgeID: UInt64, receiver: Address, amount: UFix64) {
    prepare(account: AuthAccount) {
        let tempPublicPath = PublicPath(identifier: "nftPawnshopRedeem")!
        let storagePath = NFTPawnshop.getCollectionStoragePath(identifier: identifier)!

        account.link<&{NonFungibleToken.Receiver}>(
            tempPublicPath,
            target: storagePath
        )

        let receiver = getAccount(receiver).getCapability<&{NonFungibleToken.Receiver}>(
            tempPublicPath
        )

        let pledgeCollection = account.getCapability(NFTPawnshop.PrivatePath)
            .borrow<&NFTPawnshop.PledgeCollection{NFTPawnshop.PledgeCollectionPrivate}>()
            ?? panic("Could not borrow NFTPawnshop.PledgeCollectionPrivate reference!")
        let pledge = pledgeCollection.borrowPledgePrivate(id: pledgeID)

        let vault = account.borrow<&FungibleToken.Vault>(
            from: /storage/flowTokenVault
        ) ?? panic("Could not borrow FungibleToken.Vault reference.")

        let feeTokens <- vault.withdraw(
            amount: amount
        )

        pledge.redeemNFT(
            identifier: identifier,
            receiver: receiver,
            feeTokens: <- feeTokens
        )

        account.unlink(tempPublicPath)

        destroy <- pledgeCollection.withdraw(id: pledgeID)
    }
}
