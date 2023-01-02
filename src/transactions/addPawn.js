export const addPawn = `
import FungibleToken from 0xFungibleToken
import FlowToken from 0xFlowToken
import NFTPawnshop from 0xNFTPawnshop
import NonFungibleToken from 0xNonFungibleToken
import Domains from 0xDomains

transaction(nftIDs: [UInt64]) {
    prepare(account: AuthAccount) {
        let tokenReceiver = account.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(
            /public/flowTokenReceiver
        )

        let collectionProvider = account.getCapability<&NonFungibleToken.Collection>(
            Domains.DomainsPrivatePath
        )

        let identifier = Domains.getType().identifier
        let nftIDs = nftIDs

        let pledge <- NFTPawnshop.pawnNFT(
            identifier: identifier,
            collectionProvider: collectionProvider,
            nftIDs: nftIDs,
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
`;
