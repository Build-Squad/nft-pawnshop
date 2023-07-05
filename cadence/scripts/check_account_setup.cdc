import NFTPawnshop from "NFTPawnshop"

pub fun main(address: Address): Bool {
    let account = getAccount(address)

    let pledgeCollection = account.getCapability(
        NFTPawnshop.PublicPath
    ).borrow<&NFTPawnshop.PledgeCollection{NFTPawnshop.PledgeCollectionPublic}>()

    if pledgeCollection == nil {
        return false
    }

    return true
}
