/*eslint no-restricted-globals: ["error", "event"]*/
import React, { useState, useEffect } from "react";
import "./App.css";
import * as fcl from "@onflow/fcl";
import { pawnNFTs } from "./transactions/pawnNFTs";
import LoginPage from "./RegisterAuth/LoginPage";
import LoggedOutPage from "./RegisterAuth/LoggedOutPage";
import CollectionsPage from "./FlowPages/CollectionsPage";
import NftsPage from "./FlowPages/NftsPage";
import PledgesPage from "./FlowPages/PledgesPage";
import CheckAccountSetupPage from "./RegisterAuth/CheckAccountSetupPage";

fcl.config({
  "flow.network": "testnet",
  "app.detail.title": "NFT Pawnshop",
  "accessNode.api": "https://rest-testnet.onflow.org",
  "app.detail.icon": "https://placekitten.com/g/200/200",
  "discovery.wallet": "https://fcl-discovery.onflow.org/testnet/authn",
  "0xNFTPawnshop": "0x32f248a8b1603c92",
  "0xFungibleToken": "0x9a0766d93b6608b7",
  "0xFlowToken": "0x7e60df042a9c0868",
  "0xNonFungibleToken": "0x631e88ae7f1d7c20",
  "0xMetadataViews": "0x631e88ae7f1d7c20",
  "0xNFTCatalog": "0x324c34e1c517e4db",
  "0xNFTRetrieval": "0x324c34e1c517e4db",
});

function App() {
  const [user, setUser] = useState();
  const [selectedCollection, setSelectedCollection] = useState("");
  const [selectedNFTs, setSelectedNFTs] = useState([]);
  const [isAccountSetupCorrect, setIsAccountSetupCorrect] = useState(false);

  useEffect(() => {
    fcl.currentUser().subscribe(setUser);
  }, []);

  const handlePawnClick = (_, key) => {
    if (selectedNFTs.length === 0) {
      alert("You have to choose an NFT first by clicking on it!");
      return;
    }

    const confirmed = confirm(
      "You are about to pawn NFTs for 15 Flow tokens each, you can redeem the NFTs within a year. Are you sure?"
    );

    if (confirmed) {
      pawn();
    }
  };

  const pawn = async () => {
    try {
      const transactionId = await fcl.mutate({
        cadence: `${pawnNFTs}`,
        args: (arg, t) => [
          arg(selectedCollection, t.String),
          arg(selectedNFTs, t.Array(t.UInt64)),
        ],
        proposer: fcl.currentUser,
        payer: fcl.currentUser,
        limit: 1000,
      });

      console.log("Pawning NFTs now with transaction ID", transactionId);

      const transaction = await fcl.tx(transactionId).onceSealed();

      console.log(
        "Testnet explorer link:",
        `https://testnet.flowscan.org/transaction/${transactionId}`
      );

      console.log(transaction);
      alert("NFTs sold successfully!");
    } catch (error) {
      console.log(error);
      alert("Error selling NFT, please check the console for error details!");
    }
  };

  const onSelectCollection = (key) => {
    setSelectedCollection(key);
    setSelectedNFTs([]);
  };

  const onSelectNfts = (selectedNFTs) => {
    setSelectedNFTs(selectedNFTs);
  };

  return (
    <div className="App">
      {user && user.addr ? <LoggedOutPage userDetails={user} fcl={fcl} /> : ""}
      <div className="container">
        <div className="header-container">
          <div className="logo-container">
            <img src="./logo.png" className="flow-logo" alt="flow logo" />
            <p className="header">✨ Best NFT Pawnshop ever on Flow ✨</p>
          </div>

          <p className="sub-text">
            Pawn your illiquid or underperforming NFTs, <br />
            save thousands in tax money or simply get some liquidity during
            tough times.
          </p>
        </div>

        {user && user.addr ? (
          !isAccountSetupCorrect ? (
            <CheckAccountSetupPage
              userDetails={user}
              fcl={fcl}
              onSetSetupStatus={(status) => setIsAccountSetupCorrect(status)}
            />
          ) : (
            <React.Fragment>
              <CollectionsPage
                userDetails={user}
                onSelectCollection={onSelectCollection}
                fcl={fcl}
              />

              {selectedCollection && (
                <NftsPage
                  userDetails={user}
                  collectionKey={selectedCollection}
                  selectedNFTs={selectedNFTs}
                  onSelectNfts={onSelectNfts}
                  fcl={fcl}
                />
              )}

              <div
                style={{ marginTop: "50px", marginBottom: "50px" }}
                className="button-container"
              >
                <button
                  className="cta-button button-glow"
                  onClick={handlePawnClick}
                >
                  Pawn
                </button>
              </div>

              <PledgesPage userDetails={user} fcl={fcl} confirm={confirm} />
            </React.Fragment>
          )
        ) : (
          <LoginPage fcl={fcl} />
        )}
      </div>
    </div>
  );
}

export default App;
