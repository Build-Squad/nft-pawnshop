import { readFileSync, writeFileSync } from 'fs';
import { exec } from 'child_process';
import * as fcl from "@onflow/fcl";

fcl.config()
  .put("accessNode.api", "http://localhost:8888")
  .put("flow.network", "emulator")
  .put("0xNonFungibleToken", "0xf8d6e0586b0a20c7")
  .put("0xMetadataViews", "0xf8d6e0586b0a20c7")
  .put("0xNFTCatalog", "0x179b6b1cb6755e31")

const args = process.argv.slice(2);

const collectionIdentifier = args[0];
if (collectionIdentifier === undefined) {
  console.error('You need to pass the Collection identifier as an argument.');
  process.exit(1);
}

const signer = args[1];
if (signer === undefined) {
  console.error('You need to pass the transaction signer as an argument.');
  process.exit(1);
}

try {
  const scriptPath = new URL('../scripts/get_nft_catalog_collection_data.cdc', import.meta.url);
  const scriptCode = readFileSync(scriptPath, { encoding: 'utf8' });

  const nftCollection = await fcl.query({
    cadence: scriptCode,
    args: (arg, t) => [
      arg(collectionIdentifier, t.String)
    ]
  });

  console.log(nftCollection);

  const filePath = new URL('./setup_collection_template.cdc', import.meta.url);
  const transactionTemplate = readFileSync(filePath, { encoding: 'utf8' });

  const transaction = transactionTemplate.replaceAll(
    '{CONTRACT_NAME}',
    nftCollection.contractName
  )
  .replaceAll(
    '{CONTRACT_ADDRESS}',
    nftCollection.contractAddress
  ).replaceAll(
    '{STORAGE_PATH}',
    `/${nftCollection.storagePath.domain}/${nftCollection.storagePath.identifier}`
  ).replaceAll(
    '{PRIVATE_PATH}',
    `/${nftCollection.privatePath.domain}/${nftCollection.privatePath.identifier}`
  ).replaceAll(
    '{PUBLIC_PATH}',
    `/${nftCollection.publicPath.domain}/${nftCollection.publicPath.identifier}`
  ).replaceAll(
    '{PUBLIC_LINKED_TYPE}',
    nftCollection.publicLinkedType.type.typeID.replace(/A\.\w{16}\./g, '')
  ).replaceAll(
    '{PRIVATE_LINKED_TYPE}',
    nftCollection.privateLinkedType.type.typeID.replace(/A\.\w{16}\./g, '')
  );

  const transactionPath = './cadence/transactions/setup_collection.cdc';
  writeFileSync(
    transactionPath,
    transaction
  );

  const transactionCommand = `
    flow transactions send ${transactionPath} ${collectionIdentifier} --network=emulator --signer=${signer}
  `;
  console.log(transactionCommand);

  exec(transactionCommand, (err, output) => {
    if (err) {
      console.error("Error while sending transaction: ", err);
      return;
    }

    console.log(output);
  });
} catch (err) {
  console.error(err.message);
}
