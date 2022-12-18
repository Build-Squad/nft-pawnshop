export const getPledgeInfo = `
import NFTPawnshop from 0xNFTPawnshop

pub fun main(address: Address): NFTPawnshop.PledgeInfo {
    let account = getAccount(address)

    let pledge = account.getCapability(
        /public/nftPawnshop
    ).borrow<&NFTPawnshop.Pledge{NFTPawnshop.PledgePublic}>()
    ?? panic("Could not borrow PledgePublic reference!")

    return pledge.getInfo()
}
`;
