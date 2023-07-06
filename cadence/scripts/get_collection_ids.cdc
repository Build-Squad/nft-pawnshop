import NonFungibleToken from "NonFungibleToken"
import ExampleNFT from "ExampleNFT"

pub fun main(address: Address): [UInt64] {
    let account = getAccount(address)

    let collectionRef = account
        .getCapability(ExampleNFT.CollectionPublicPath)
        .borrow<&{NonFungibleToken.CollectionPublic}>()
        ?? panic("Could not borrow capability from public collection at specified path")

    return collectionRef.getIDs()
}
