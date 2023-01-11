import { readFileSync, writeFileSync } from 'fs';
import { execSync } from 'child_process';
import * as fcl from "@onflow/fcl";

fcl.config()
  .put("accessNode.api", "https://rest-testnet.onflow.org")
  .put("flow.network", "testnet")
  .put("0xNFTPawnshop", "0x32f248a8b1603c92")
  .put("0xNonFungibleToken", "0x631e88ae7f1d7c20")
  .put("0xMetadataViews", "0x631e88ae7f1d7c20")
  .put("0xNFTCatalog", "0x324c34e1c517e4db")

try {
  let scriptPath = new URL('../scripts/get_nft_catalog_collection_identifiers.cdc', import.meta.url);
  let scriptCode = readFileSync(scriptPath, { encoding: 'utf8' });

  const collectionIdentifiers = await fcl.query({
    cadence: scriptCode
  });

  console.log(`Total Collections: ${collectionIdentifiers.length}`);

  scriptPath = new URL('../scripts/get_nft_catalog_collection_data.cdc', import.meta.url);
  scriptCode = readFileSync(scriptPath, { encoding: 'utf8' });

  for (const collection of collectionIdentifiers) {
    let collectionData;

    try {
      collectionData = await fcl.query({
        cadence: scriptCode,
        args: (arg, t) => [
          arg(collection, t.String)
        ]
      });
    } catch (err) {
      console.log(`Error occurred while fetching NFTCatalog Collection data for: ${collection}`);
      continue;
    }

    const filePath = new URL('./add_admin_collection_template.cdc', import.meta.url);
    const transactionTemplate = readFileSync(filePath, { encoding: 'utf8' });

    const transaction = transactionTemplate.replaceAll(
      '{CONTRACT_NAME}',
      collectionData.contractName
    )
    .replaceAll(
      '{CONTRACT_ADDRESS}',
      collectionData.contractAddress
    ).replaceAll(
      '{PUBLIC_LINKED_TYPE}',
      collectionData.publicLinkedType.typeID.replace(/A\.\w{16}\./g, '')
    ).replaceAll(
      '{PRIVATE_LINKED_TYPE}',
      collectionData.privateLinkedType.typeID.replace(/A\.\w{16}\./g, '')
    ).replaceAll(
      '"../contracts/NFTPawnshop.cdc"',
      '0x32f248a8b1603c92'
    ).replaceAll(
      '"../contracts/NonFungibleToken.cdc"',
      '0x631e88ae7f1d7c20'
    ).replaceAll(
      '"../contracts/MetadataViews.cdc"',
      '0x631e88ae7f1d7c20'
    );

    const transactionPath = './cadence/transactions/add_admin_collection.cdc';
    writeFileSync(
      transactionPath,
      transaction
    );

    let storagePath = `/${collectionData.storagePath.domain}/${collectionData.storagePath.identifier}`;
    let providerPath = `/${collectionData.privatePath.domain}/${collectionData.privatePath.identifier}`;
    let publicPath = `/${collectionData.publicPath.domain}/${collectionData.publicPath.identifier}`;
    const transactionCommand = `
      flow transactions send ${transactionPath} '${collection}' '${storagePath}' '${providerPath}' '${publicPath}' --network=testnet --signer=testnet-account
    `;
    console.log(transactionCommand);

    execSync(transactionCommand, (err, output) => {
      if (err) {
        console.error("Error while sending transaction: ", err);
        return;
      }

      console.log(output);
    });
  }
} catch (err) {
  console.error(err.message);
}
