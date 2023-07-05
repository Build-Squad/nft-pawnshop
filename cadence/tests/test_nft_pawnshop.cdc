import Test

pub let blockchain = Test.newEmulatorBlockchain()
pub let admin = blockchain.createAccount()
pub let pawner = blockchain.createAccount()

pub fun setup() {
    blockchain.useConfiguration(Test.Configuration({
        "NFTPawnshop": admin.address,
        "NFTCatalog": admin.address
    }))

    var code = Test.readFile("../contracts/NFTPawnshop.cdc")
    var err = blockchain.deployContract(
        name: "NFTPawnshop",
        code: code,
        account: admin,
        arguments: []
    )

    Test.expect(err, Test.beNil())

    code = Test.readFile("../contracts/NFTCatalog.cdc")
    err = blockchain.deployContract(
        name: "NFTCatalog",
        code: code,
        account: admin,
        arguments: []
    )

    Test.expect(err, Test.beNil())
}

pub fun testSetupAdminStorefront() {
    let code = Test.readFile("../transactions/setup_storefront.cdc")
    let tx = Test.Transaction(
        code: code,
        authorizers: [admin.address],
        signers: [admin],
        arguments: []
    )
    let txResult = blockchain.executeTransaction(tx)

    Test.expect(txResult, Test.beSucceeded())
}

pub fun testSetupAdminNFTCatalog() {
    let code = Test.readFile("../transactions/setup_nft_catalog.cdc")
    let tx = Test.Transaction(
        code: code,
        authorizers: [admin.address],
        signers: [admin],
        arguments: []
    )
    let txResult = blockchain.executeTransaction(tx)

    Test.expect(txResult, Test.beSucceeded())
}

pub fun testTransferFlowTokensToAdmin() {
    let code = Test.readFile("../transactions/transfer_flow_tokens.cdc")
    let serviceAccount = blockchain.serviceAccount()
    let tx = Test.Transaction(
        code: code,
        authorizers: [serviceAccount.address],
        signers: [],
        arguments: [admin.address, 1500.0]
    )
    let txResult = blockchain.executeTransaction(tx)

    Test.expect(txResult, Test.beSucceeded())
}

pub fun testFundAdminVault() {
    let code = Test.readFile("../transactions/fund_admin_vault.cdc")
    let tx = Test.Transaction(
        code: code,
        authorizers: [admin.address],
        signers: [admin],
        arguments: [1000.0]
    )
    let txResult = blockchain.executeTransaction(tx)

    Test.expect(txResult, Test.beSucceeded())
}

pub fun testAdminAddNFTCollection() {
    let code = Test.readFile("../transactions/add_admin_collection.cdc")
    let tx = Test.Transaction(
        code: code,
        authorizers: [admin.address],
        signers: [admin],
        arguments: [
            "ExampleNFT",
            /storage/exampleNFTCollection,
            /private/exampleNFTCollection,
            /public/exampleNFTCollection
        ]
    )
    let txResult = blockchain.executeTransaction(tx)

    Test.expect(txResult, Test.beSucceeded())
}

pub fun testAdminAddDuplicateCollection() {
    let code = Test.readFile("../transactions/add_admin_collection.cdc")
    let tx = Test.Transaction(
        code: code,
        authorizers: [admin.address],
        signers: [admin],
        arguments: [
            "ExampleNFT",
            /storage/exampleNFTCollection,
            /private/exampleNFTCollection,
            /public/exampleNFTCollection
        ]
    )
    let txResult = blockchain.executeTransaction(tx)

    Test.expect(txResult, Test.beFailed())
}

pub fun testGetAdminBalance() {
    let code = Test.readFile("../scripts/get_admin_balance.cdc")
    let scriptResult = blockchain.executeScript(
        code,
        []
    )

    Test.expect(scriptResult, Test.beSucceeded())

    let balance = (scriptResult.returnValue as! UFix64?)!
    Test.assertEqual(1000.0, balance)
}

pub fun testGetCollectionNames() {
    let code = Test.readFile("../scripts/get_collection_names.cdc")
    let scriptResult = blockchain.executeScript(
        code,
        []
    )

    Test.expect(scriptResult, Test.beSucceeded())

    let collectionNames = (scriptResult.returnValue as! [String]?)!
    Test.assertEqual(["ExampleNFT"], collectionNames)
}

pub fun testGetSalePrice() {
    let code = Test.readFile("../scripts/get_sale_price.cdc")
    let scriptResult = blockchain.executeScript(
        code,
        []
    )

    Test.expect(scriptResult, Test.beSucceeded())

    let salePrice = (scriptResult.returnValue as! UFix64?)!
    Test.assertEqual(15.0, salePrice)
}

pub fun testTransferFlowTokensToPawner() {
    let code = Test.readFile("../transactions/transfer_flow_tokens.cdc")
    let serviceAccount = blockchain.serviceAccount()
    let tx = Test.Transaction(
        code: code,
        authorizers: [serviceAccount.address],
        signers: [],
        arguments: [pawner.address, 1500.0]
    )
    let txResult = blockchain.executeTransaction(tx)

    Test.expect(txResult, Test.beSucceeded())
}

pub fun testSetupCollectionForPawner() {
    let code = Test.readFile("../transactions/setup_collection.cdc")
    let tx = Test.Transaction(
        code: code,
        authorizers: [pawner.address],
        signers: [pawner],
        arguments: []
    )
    let txResult = blockchain.executeTransaction(tx)

    Test.expect(txResult, Test.beSucceeded())
}

pub fun testSetupPawnerAccountToReceiveRoyalty() {
    let code = Test.readFile("../transactions/setup_account_to_receive_royalty.cdc")
    let tx = Test.Transaction(
        code: code,
        authorizers: [pawner.address],
        signers: [pawner],
        arguments: [/storage/flowTokenVault]
    )
    let txResult = blockchain.executeTransaction(tx)

    Test.expect(txResult, Test.beSucceeded())
}

pub fun testMintNFTsForPawner() {
    var code = Test.readFile("../transactions/mint_nft.cdc")
    let serviceAccount = blockchain.serviceAccount()
    var tx = Test.Transaction(
        code: code,
        authorizers: [serviceAccount.address],
        signers: [],
        arguments: [
            pawner.address,
            "My Example NFT",
            "My Example NFT Description",
            "https://www.example-nft.com/thumbnails/0",
            [0.05],
            ["Tribute to Creator!"],
            [pawner.address]
        ]
    )
    var txResult = blockchain.executeTransaction(tx)

    Test.expect(txResult, Test.beSucceeded())

    tx = Test.Transaction(
        code: code,
        authorizers: [serviceAccount.address],
        signers: [],
        arguments: [
            pawner.address,
            "My Example NFT #2",
            "My Example NFT Description #2",
            "https://www.example-nft.com/thumbnails/1",
            [0.07],
            ["Tribute to Creator!"],
            [pawner.address]
        ]
    )
    txResult = blockchain.executeTransaction(tx)

    Test.expect(txResult, Test.beSucceeded())
}

pub fun testGetCollectionIDsForPawner() {
    let code = Test.readFile("../scripts/get_collection_ids.cdc")
    let scriptResult = blockchain.executeScript(
        code,
        [pawner.address]
    )

    Test.expect(scriptResult, Test.beSucceeded())

    let collectionIDs = (scriptResult.returnValue as! [UInt64]?)!
    Test.assertEqual([0, 1] as [UInt64], collectionIDs)
}

pub fun testSetupPledgeCollectionForPawner() {
    let code = Test.readFile("../transactions/setup_pledge_collection.cdc")
    let tx = Test.Transaction(
        code: code,
        authorizers: [pawner.address],
        signers: [pawner],
        arguments: []
    )
    let txResult = blockchain.executeTransaction(tx)

    Test.expect(txResult, Test.beSucceeded())
}

pub fun testPawnNFTs() {
    let code = Test.readFile("../transactions/pawn_nfts.cdc")
    var tx = Test.Transaction(
        code: code,
        authorizers: [pawner.address],
        signers: [pawner],
        arguments: [
            "ExampleNFT",
            [0] as [UInt64]
        ]
    )
    var txResult = blockchain.executeTransaction(tx)

    Test.expect(txResult, Test.beSucceeded())

    tx = Test.Transaction(
        code: code,
        authorizers: [pawner.address],
        signers: [pawner],
        arguments: [
            "ExampleNFT",
            [1] as [UInt64]
        ]
    )
    txResult = blockchain.executeTransaction(tx)

    Test.expect(txResult, Test.beSucceeded())
}

pub fun testGetAdminCollection() {
    let code = Test.readFile("../scripts/get_admin_collection.cdc")
    let scriptResult = blockchain.executeScript(
        code,
        ["ExampleNFT"]
    )

    Test.expect(scriptResult, Test.beSucceeded())

    let collectionIDs = (scriptResult.returnValue as! [UInt64]?)!
    Test.expect(collectionIDs, Test.haveElementCount(2))
    Test.assertEqual([1, 0] as [UInt64], collectionIDs)
}

pub fun testGetPledgeCollectionInfo() {
    let code = Test.readFile("scripts/get_pledge_collection_info.cdc")
    let scriptResult = blockchain.executeScript(
        code,
        [pawner.address]
    )

    Test.expect(scriptResult, Test.beSucceeded())
}

pub fun testGetAdminPledges() {
    let code = Test.readFile("scripts/get_admin_pledges.cdc")
    let scriptResult = blockchain.executeScript(
        code,
        []
    )

    Test.expect(scriptResult, Test.beSucceeded())
}

pub fun testRedeemPledgeWithUnauthorizedSigner() {
    let code = Test.readFile("transactions/redeem_pledge.cdc")
    let account = blockchain.createAccount()
    let tx = Test.Transaction(
        code: code,
        authorizers: [pawner.address],
        signers: [pawner],
        arguments: [
            "ExampleNFT",
            46 as UInt64,
            account.address,
            15.0
        ]
    )
    let txResult = blockchain.executeTransaction(tx)

    Test.expect(txResult, Test.beFailed())
}

pub fun testRedeemPledgeWithInsufficientAmount() {
    let code = Test.readFile("transactions/redeem_pledge.cdc")
    let account = blockchain.createAccount()
    let tx = Test.Transaction(
        code: code,
        authorizers: [pawner.address],
        signers: [pawner],
        arguments: [
            "ExampleNFT",
            46 as UInt64,
            pawner.address,
            5.0
        ]
    )
    let txResult = blockchain.executeTransaction(tx)

    Test.expect(txResult, Test.beFailed())
}

pub fun testRedeemPledge() {
    var code = Test.readFile("scripts/get_pledge_ids.cdc")
    let scriptResult = blockchain.executeScript(
        code,
        [pawner.address]
    )

    let pledgeIDs = (scriptResult.returnValue as! [UInt64]?)!
    Test.expect(scriptResult, Test.beSucceeded())

    code = Test.readFile("../transactions/redeem_pledge.cdc")
    for pledgeID in pledgeIDs {
        var tx = Test.Transaction(
            code: code,
            authorizers: [pawner.address],
            signers: [pawner],
            arguments: [
                "ExampleNFT",
                pledgeID
            ]
        )
        var txResult = blockchain.executeTransaction(tx)

        Test.expect(txResult, Test.beSucceeded())
    }
}

pub fun testUpdateSalePrice() {
    let code = Test.readFile("../transactions/update_sale_price.cdc")
    let tx = Test.Transaction(
        code: code,
        authorizers: [admin.address],
        signers: [admin],
        arguments: [10.0]
    )
    let txResult = blockchain.executeTransaction(tx)

    Test.expect(txResult, Test.beSucceeded())
}

pub fun testRedeemExpiredPledge() {
    var code = Test.readFile("../transactions/pawn_nfts.cdc")
    var tx = Test.Transaction(
        code: code,
        authorizers: [pawner.address],
        signers: [pawner],
        arguments: [
            "ExampleNFT",
            [0] as [UInt64]
        ]
    )
    var txResult = blockchain.executeTransaction(tx)

    Test.expect(txResult, Test.beSucceeded())

    code = Test.readFile("../transactions/update_default_expiry.cdc")
    tx = Test.Transaction(
        code: code,
        authorizers: [admin.address],
        signers: [admin],
        arguments: [0.001]
    )
    txResult = blockchain.executeTransaction(tx)

    Test.expect(txResult, Test.beSucceeded())

    code = Test.readFile("../transactions/pawn_nfts.cdc")
    tx = Test.Transaction(
        code: code,
        authorizers: [pawner.address],
        signers: [pawner],
        arguments: [
            "ExampleNFT",
            [1] as [UInt64]
        ]
    )
    txResult = blockchain.executeTransaction(tx)

    Test.expect(txResult, Test.beSucceeded())

    code = Test.readFile("scripts/get_pledge_ids.cdc")
    let scriptResult = blockchain.executeScript(
        code,
        [pawner.address]
    )

    let pledgeIDs = (scriptResult.returnValue as! [UInt64]?)!
    Test.expect(scriptResult, Test.beSucceeded())

    code = Test.readFile("../transactions/redeem_pledge.cdc")
    tx = Test.Transaction(
        code: code,
        authorizers: [pawner.address],
        signers: [pawner],
        arguments: [
            "ExampleNFT",
            pledgeIDs[1]
        ]
    )
    txResult = blockchain.executeTransaction(tx)

    Test.expect(txResult, Test.beFailed())
}

pub fun testAdminTransferProceeds() {
    let code = Test.readFile("../transactions/admin_transfer_proceeds.cdc")
    let tx = Test.Transaction(
        code: code,
        authorizers: [admin.address],
        signers: [admin],
        arguments: ["ExampleNFT", admin.address]
    )
    let txResult = blockchain.executeTransaction(tx)

    Test.expect(txResult, Test.beSucceeded())
}

pub fun testDestroyPledgeCollectionForPawner() {
    let code = Test.readFile("transactions/destroy_pledge_collection.cdc")
    let tx = Test.Transaction(
        code: code,
        authorizers: [pawner.address],
        signers: [pawner],
        arguments: []
    )
    let txResult = blockchain.executeTransaction(tx)

    Test.expect(txResult, Test.beSucceeded())
}

pub fun testDestroyAdminResource() {
    let code = Test.readFile("transactions/destroy_admin_resource.cdc")
    let tx = Test.Transaction(
        code: code,
        authorizers: [admin.address],
        signers: [admin],
        arguments: []
    )
    let txResult = blockchain.executeTransaction(tx)

    Test.expect(txResult, Test.beSucceeded())
}
