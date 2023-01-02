import NFTPawnshop from "../contracts/NFTPawnshop.cdc"

pub fun main(): UFix64 {
    return NFTPawnshop.getAdminBalance()
}
