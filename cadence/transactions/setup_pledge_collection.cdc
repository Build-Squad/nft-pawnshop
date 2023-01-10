import NFTPawnshop from "../contracts/NFTPawnshop.cdc"

transaction {
    prepare(account: AuthAccount) {
        if (account.borrow<&NFTPawnshop.PledgeCollection>(from: NFTPawnshop.StoragePath) != nil) {
            return
        }

        let pledgeCollection <- NFTPawnshop.createEmptyPledgeCollection()

        account.save<@NFTPawnshop.PledgeCollection>(
            <- pledgeCollection,
            to: NFTPawnshop.StoragePath
        )

        account.link<&NFTPawnshop.PledgeCollection{NFTPawnshop.PledgeCollectionPublic}>(
            NFTPawnshop.PublicPath,
            target: NFTPawnshop.StoragePath
        )
        account.link<&NFTPawnshop.PledgeCollection{NFTPawnshop.PledgeCollectionPrivate}>(
            NFTPawnshop.PrivatePath,
            target: NFTPawnshop.StoragePath
        )
    }
}
