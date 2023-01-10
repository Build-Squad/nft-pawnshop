import NFTPawnshop from "../contracts/NFTPawnshop.cdc"

pub fun main(address: Address): [NFTPawnshop.PledgeInfo] {
    let account = getAccount(address)

    let pledgeCollection = account.getCapability(
        NFTPawnshop.PublicPath
    ).borrow<&NFTPawnshop.PledgeCollection{NFTPawnshop.PledgeCollectionPublic}>()
    ?? panic("Could not borrow NFTPawnshop.PledgeCollectionPublic reference!")

    let pledgeInfos: [NFTPawnshop.PledgeInfo] = []

    for pledgeID in pledgeCollection.getIDs() {
        let pledge = pledgeCollection.borrowPledge(id: pledgeID)
        pledgeInfos.append(pledge.getInfo())
    }

    return pledgeInfos
}
