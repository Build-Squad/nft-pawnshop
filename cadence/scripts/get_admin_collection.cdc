import NFTPawnshop from "NFTPawnshop"

pub fun main(identifier: String): [UInt64] {
    return NFTPawnshop.getAdminCollectionIDs(identifier: identifier)
}
