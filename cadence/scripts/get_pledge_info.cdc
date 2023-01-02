import NFTPawnshop from "../contracts/NFTPawnshop.cdc"

pub fun main(address: Address): NFTPawnshop.PledgeInfo {
    let account = getAccount(address)

    let pledge = account.getCapability(
        NFTPawnshop.PublicPath
    ).borrow<&NFTPawnshop.Pledge{NFTPawnshop.PledgePublic}>()
    ?? panic("Could not borrow PledgePublic reference!")

    return pledge.getInfo()
}
