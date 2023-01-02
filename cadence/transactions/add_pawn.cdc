import FungibleToken from "../contracts/FungibleToken.cdc"
import FlowToken from "../contracts/FlowToken.cdc"
import NFTPawnshop from "../contracts/NFTPawnshop.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"

transaction(identifier: String, nftIDs: [UInt64]) {
    prepare(account: AuthAccount) {
        if (account.borrow<&NFTPawnshop.Pledge>(from: NFTPawnshop.StoragePath) != nil) {
            let pledge <- account.load<@NFTPawnshop.Pledge>(
                from: NFTPawnshop.StoragePath
            )

            destroy pledge
        }

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

        account.save<@NFTPawnshop.Pledge>(<- pledge, to: NFTPawnshop.StoragePath)
        account.link<&NFTPawnshop.Pledge{NFTPawnshop.PledgePublic}>(
            NFTPawnshop.PublicPath,
            target: NFTPawnshop.StoragePath
        )
        account.link<&NFTPawnshop.Pledge{NFTPawnshop.PledgePrivate}>(
            NFTPawnshop.PrivatePath,
            target: NFTPawnshop.StoragePath
        )
    }
}
