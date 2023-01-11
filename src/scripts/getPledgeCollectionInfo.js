export const getPledgeCollectionInfo = `
import NFTPawnshop from 0xNFTPawnshop

pub fun main(address: Address): [NFTPawnshop.PledgeInfo] {
    let account = getAccount(address)

    let pledgeCollection = account.getCapability(
        NFTPawnshop.PublicPath
    ).borrow<&NFTPawnshop.PledgeCollection{NFTPawnshop.PledgeCollectionPublic}>()

    if pledgeCollection == nil {
        return []
    }

    let pledgeInfos: [NFTPawnshop.PledgeInfo] = []

    for pledgeID in pledgeCollection!.getIDs() {
        let pledge = pledgeCollection!.borrowPledge(id: pledgeID)
        pledgeInfos.append(pledge.getInfo())
    }

    return pledgeInfos
}
`;
