import NFTPawnshop from "../contracts/NFTPawnshop.cdc"

pub fun main(): {UInt64: NFTPawnshop.PledgeInfo} {
    return NFTPawnshop.pledges
}
