import FungibleToken from "../contracts/FungibleToken.cdc"
import NFTPawnshop from "../contracts/NFTPawnshop.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"

transaction(identifier: String, pledgeID: UInt64) {
    prepare(account: AuthAccount) {
        let tempPublicPath = PublicPath(identifier: "nftPawnshopRedeem")!
        let storagePath = NFTPawnshop.getCollectionStoragePath(identifier: identifier)!

        account.link<&{NonFungibleToken.Receiver}>(
            tempPublicPath,
            target: storagePath
        )

        let receiver = account.getCapability<&{NonFungibleToken.Receiver}>(
            tempPublicPath
        )

        let pledgeCollection = account.getCapability(NFTPawnshop.PrivatePath)
            .borrow<&NFTPawnshop.PledgeCollection{NFTPawnshop.PledgeCollectionPrivate}>()
            ?? panic("Could not borrow NFTPawnshop.PledgeCollectionPrivate reference!")
        let pledge <- pledgeCollection.withdraw(id: pledgeID)

        let vault = account.borrow<&FungibleToken.Vault>(
            from: /storage/flowTokenVault
        ) ?? panic("Could not borrow FungibleToken.Vault reference.")

        let feeTokens <- vault.withdraw(
            amount: pledge.getSalePrice()
        )

        pledge.redeemNFT(
            identifier: identifier,
            receiver: receiver,
            feeTokens: <- feeTokens
        )

        account.unlink(tempPublicPath)

        destroy pledge
    }
}
