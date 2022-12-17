import FungibleToken from "../contracts/FungibleToken.cdc"
import FlowToken from "../contracts/FlowToken.cdc"
import NFTPawnshop from "../contracts/NFTPawnshop.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import Domains from "../contracts/Domains.cdc"

transaction(nftID: UInt64) {
    prepare(account: AuthAccount) {
        let tokenReceiver = account.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(
            /public/flowTokenReceiver
        )

        let collectionProvider = account.getCapability<&NonFungibleToken.Collection>(
            Domains.DomainsPrivatePath
        )

        let identifier = Domains.getType().identifier
        let nftIDs = [nftID]

        let pledge <- NFTPawnshop.pawnNFT(
            identifier: identifier,
            collectionProvider: collectionProvider,
            nftIDs: nftIDs,
            tokenReceiver: tokenReceiver
        )

        account.save<@NFTPawnshop.Pledge>(<- pledge, to: /storage/nftPawnshop)
        account.link<&NFTPawnshop.Pledge{NFTPawnshop.PledgePublic}>(
            /public/nftPawnshop,
            target: /storage/nftPawnshop
        )
        account.link<&NFTPawnshop.Pledge{NFTPawnshop.PledgePrivate}>(
            /private/nftPawnshop,
            target: /storage/nftPawnshop
        )
    }
}