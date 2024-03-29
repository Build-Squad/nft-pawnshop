import FungibleToken from "FungibleToken"
import FlowToken from "FlowToken"
import NFTPawnshop from "NFTPawnshop"
import NonFungibleToken from "NonFungibleToken"

transaction(identifier: String, nftIDs: [UInt64]) {
    prepare(account: AuthAccount) {
        let tokenReceiver = account.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(
            /public/flowTokenReceiver
        )

        let storagePath = NFTPawnshop.getCollectionStoragePath(identifier: identifier)!

        let collectionRef = account.borrow<&NonFungibleToken.Collection>(
            from: storagePath
        ) ?? panic("Could not borrow NonFungibleToken.Collection in selling NFT.cdc!")

        let nfts: @{UInt64: NonFungibleToken.NFT} <- {}

        for nftID in nftIDs {
            let nft <- collectionRef.withdraw(withdrawID: nftID)
            nfts[nft.id] <-! nft
        }

        let pledge <- NFTPawnshop.pawnNFT(
            identifier: identifier,
            nfts: <- nfts,
            tokenReceiver: tokenReceiver
        )

        let pledgeCollection = account.getCapability(NFTPawnshop.PrivatePath)
            .borrow<&NFTPawnshop.PledgeCollection{NFTPawnshop.PledgeCollectionPrivate}>()
            ?? panic("Could not borrow NFTPawnshop.PledgeCollectionPrivate reference!")

        pledgeCollection.deposit(pledge: <- pledge)
    }
}
