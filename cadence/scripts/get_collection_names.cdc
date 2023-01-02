import NFTPawnshop from "../contracts/NFTPawnshop.cdc"

pub fun main(): [String] {
    return NFTPawnshop.getCollectionNames()
}
