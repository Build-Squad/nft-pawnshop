import NFTPawnshop from "NFTPawnshop"

transaction {
    prepare(account: AuthAccount) {
        let admin <- account.load<@NFTPawnshop.Admin>(
            from: NFTPawnshop.AdminStoragePath
        )
        destroy <- admin
    }
}
