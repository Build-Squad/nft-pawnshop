import FungibleToken from "../contracts/FungibleToken.cdc"
import NFTPawnshop from "../contracts/NFTPawnshop.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import Domains from "../contracts/Domains.cdc"

transaction {
    prepare(account: AuthAccount) {
        let receiver = account.getCapability<&{NonFungibleToken.Receiver}>(
            Domains.DomainsPublicPath
        )

        let pledge <- account.load<@NFTPawnshop.Pledge>(
            from: /storage/nftPawnshop
        ) ?? panic("Could not load NFTPawnshop.Pledge resource.")

        let identifier = Domains.getType().identifier
        pledge.nftPawns[identifier]!

        account.save<@NFTPawnshop.Pledge>(<- pledge, to: /storage/nftPawnshop)
    }
}
