import { readFileSync, writeFileSync } from 'fs';
import { exec } from 'child_process';
import * as fcl from "@onflow/fcl";

fcl.config()
  .put("accessNode.api", "http://localhost:8888")
  .put("flow.network", "emulator")
  .put("0xNonFungibleToken", "0xf8d6e0586b0a20c7")
  .put("0xMetadataViews", "0xf8d6e0586b0a20c7")
  .put("0xNFTCatalog", "0x179b6b1cb6755e31")

const collection = 'ExampleNFT';

  try {
  const scriptPath = new URL('../scripts/get_nft_catalog_collection_data.cdc', import.meta.url);
  const scriptCode = readFileSync(scriptPath, { encoding: 'utf8' });

  const nftCollection = await fcl.query({
    cadence: scriptCode,
    args: (arg, t) => [
      arg(collection, t.String)
    ]
  });

  console.log(nftCollection);

  const filePath = new URL('./add_admin_collection_template.cdc', import.meta.url);
  const transactionTemplate = readFileSync(filePath, { encoding: 'utf8' });

  const transaction = transactionTemplate.replaceAll(
    '{CONTRACT_NAME}',
    nftCollection.contractName
  )
  .replaceAll(
    '{CONTRACT_ADDRESS}',
    nftCollection.contractAddress
  ).replaceAll(
    '{PUBLIC_LINKED_TYPE}',
    nftCollection.publicLinkedType.type.typeID.replace(/A\.\w{16}\./g, '')
  ).replaceAll(
    '{PRIVATE_LINKED_TYPE}',
    nftCollection.privateLinkedType.type.typeID.replace(/A\.\w{16}\./g, '')
  );


  const transactionPath = './cadence/transactions/add_admin_collection.cdc';
  writeFileSync(
    transactionPath,
    transaction
  );

  const storagePath = `/${nftCollection.storagePath.domain}/${nftCollection.storagePath.identifier}`;
  const privatePath = `/${nftCollection.privatePath.domain}/${nftCollection.privatePath.identifier}`;
  const publicPath = `/${nftCollection.publicPath.domain}/${nftCollection.publicPath.identifier}`;

  const transactionCommand = `
    flow transactions send ${transactionPath} ${collection} ${storagePath} ${privatePath} ${publicPath} --network=emulator --signer=emulator-admin
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
