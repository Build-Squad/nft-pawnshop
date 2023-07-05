import NFTPawnshop from "NFTPawnshop"

transaction {
    prepare(account: AuthAccount) {
        let pledgeCollection <- account.load<@NFTPawnshop.PledgeCollection>(
            from: NFTPawnshop.StoragePath
        )
        destroy <- pledgeCollection
    }
}
