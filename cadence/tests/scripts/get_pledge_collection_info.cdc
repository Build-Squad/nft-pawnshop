import NFTPawnshop from "NFTPawnshop"

pub fun main(address: Address): Bool {
    let account = getAccount(address)

    let pledgeCollection = account.getCapability(
        NFTPawnshop.PublicPath
    ).borrow<&NFTPawnshop.PledgeCollection{NFTPawnshop.PledgeCollectionPublic}>()

    if pledgeCollection == nil {
        return false
    }

    let pledgeInfos: [NFTPawnshop.PledgeInfo] = []

    for pledgeID in pledgeCollection!.getIDs() {
        let pledge = pledgeCollection!.borrowPledge(id: pledgeID)
        pledgeInfos.append(pledge.getInfo())
    }

    return pledgeInfos.length == 2
}
