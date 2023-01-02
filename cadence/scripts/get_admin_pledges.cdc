import NFTPawnshop from "../contracts/NFTPawnshop.cdc"

pub fun main(): {Address: NFTPawnshop.PledgeInfo} {
    return NFTPawnshop.pledges
}
