import NFTPawnshop from "../contracts/NFTPawnshop.cdc"

pub fun main(identifier: String): [UInt64] {
    return NFTPawnshop.getAdminCollectionIDs(identifier: identifier)
}
