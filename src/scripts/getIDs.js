export const getIDs = `
import Domains from 0xDomains
import NonFungibleToken from 0xNonFungibleToken

pub fun main(address: Address): [UInt64] {
    let collectionRef = getAccount(address).getCapability<&Domains.Collection{NonFungibleToken.CollectionPublic, Domains.CollectionPublic}>(
        Domains.DomainsPublicPath
    ).borrow() ?? panic("Could not borrow Collection reference")
    return collectionRef.getIDs()
}
`;
