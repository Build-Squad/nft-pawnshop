/*eslint no-restricted-globals: ["error", "event"]*/
import React, { useState, useEffect } from 'react';
import './App.css';
import * as fcl from '@onflow/fcl';
import { getCollectionsForAccount } from './scripts/getCollectionsForAccount';
import { getNFTsForAccountCollection } from './scripts/getNFTsForAccountCollection';
import { getPledgeCollectionInfo  } from './scripts/getPledgeCollectionInfo';
import { checkAccountSetup } from './scripts/checkAccountSetup';
import { setupPledgeCollection } from './transactions/setupPledgeCollection';
import { pawnNFTs } from './transactions/pawnNFTs';
import { redeemPledge } from './transactions/redeemPledge';

fcl.config({
  'flow.network': 'testnet',
  'app.detail.title': 'NFT Pawnshop',
  'accessNode.api': 'https://rest-testnet.onflow.org',
  'app.detail.icon': 'https://placekitten.com/g/200/200',
  'discovery.wallet': 'https://fcl-discovery.onflow.org/testnet/authn',
  '0xNFTPawnshop': '0x32f248a8b1603c92',
  '0xFungibleToken': '0x9a0766d93b6608b7',
  '0xFlowToken': '0x7e60df042a9c0868',
  '0xNonFungibleToken': '0x631e88ae7f1d7c20',
  '0xMetadataViews': '0x631e88ae7f1d7c20',
  '0xNFTCatalog': '0x324c34e1c517e4db',
  '0xNFTRetrieval': '0x324c34e1c517e4db'
});

function App() {
  const [user, setUser] = useState();
  const [collections, setCollections] = useState({});
  const [nfts, setNFTs] = useState([]);
  const [selectedCollection, setSelectedCollection] = useState("");
  const [selectedNFTs, setSelectedNFTs] = useState([]);
  const [pledges, setPledges] = useState([]);

  const logIn = () => {
    fcl.authenticate();
  };

  const logOut = () => {
    setCollections([]);
    fcl.unauthenticate();
  };

  useEffect(() => {
    fcl.currentUser().subscribe(setUser);
  }, []);

  useEffect(() => {
    if (user && user.addr) {
      fetchCollections();
      fetchPledges();
    }
  }, [user]);

  const handleCollectionClick = (_, key) => {
    fetchNFTs(key);
    setSelectedCollection(key);
    setSelectedNFTs([]);
  };

  const handlePawnClick = (_, key) => {
    if (selectedNFTs.length === 0) {
      alert('You have to choose an NFT first by clicking on it!');
      return;
    }

    const confirmed = confirm(
      'You are about to pawn NFTs for 15 Flow tokens each, you can redeem the NFTs within a year. Are you sure?'
    );

    if (confirmed) {
      pawn();
    }
  };

  const handleNFTClick = (event, key) => {
    if (!selectedNFTs.includes(key)) {
      selectedNFTs.push(key);
      setSelectedNFTs(selectedNFTs);
      event.currentTarget.style.border = '2px solid green';
    } else {
      const index = selectedNFTs.indexOf(key);
      selectedNFTs.splice(index, 1);
      setSelectedNFTs(selectedNFTs);
      event.currentTarget.style.border = '';
    }
  };

  const RenderLogin = () => {
    return (
      <div>
        <button
          className="cta-button button-glow"
          onClick={() => logIn()}
        >
          Log In
        </button>
      </div>
    );
  };

  const RenderCollections = () => {
    return (
      <div>
        {Object.keys(collections).length > 0 ? (
          <>
            <h2>Your Collections</h2>
            <div className="image-container">
              <ul>
                {Object.entries(collections).map(([name, count]) =>
                  (
                  <li onClick={(event) => {
                    handleCollectionClick(event, name);
                  }} key={name}>{name} ({count} NFTs)</li>))}
              </ul>
            </div>
          </>
        ) : (
          'No Collections Owned!'
        )}
      </div>
    );
  };

  const RenderNFTs = () => {
    return (
      <div>
        {nfts.length > 0 ? (
          <>
            {nfts.map(nft => (
              <div key={nft.id}>
                <div>
                  ID: {nft.id}
                </div>
                <div>
                  Name: {nft.name}
                </div>
                <div>
                  Description: {nft.description}
                </div>
                <div>
                  <img width="50px" height="50px" alt="nft_image" src={nft.thumbnail}
                  onClick={(event) => handleNFTClick(event, nft.id)} />
                </div>
              </div>
            ))}
            <div style={{'marginTop': '50px', 'marginBottom': '50px'}} className="button-container">
              <button
                className="cta-button button-glow"
                onClick={handlePawnClick}
              >
                Pawn
              </button>
            </div>
          </>
        ): ( '' )}
      </div>
    )
  }

  const RenderPledges = () => {
    return (
      <div>
        {pledges.length > 0 ? (
          <div style={{ marginTop: '50px' }}>
            <h2>Your NFT Pledge</h2>
            <div
              style={{
                display: 'flex',
                justifyContent: 'center',
              }}
            >
              <table>
                <thead>
                  <tr>
                    <th>Debitor</th>
                    <th>Expiry</th>
                    <th>Sale Price</th>
                    <th>Collection</th>
                    <th>NFT IDs</th>
                  </tr>
                  {pledges.forEach(pledge => {
                    <tr key={pledge.id}>
                      <td>
                        {pledge.debitor}
                      </td>
                      <td>
                        {new Date(Number(pledge.expiry) * 1000).toDateString()}
                      </td>
                      <td>
                        {pledge.pawns.salePrice}
                      </td>
                      <td>
                        {pledge.pawns.collectionIdentifier}
                      </td>
                      <td>
                        {pledge.pawns.nftIDs.join(', ')}
                      </td>
                    </tr>
                  })}
                </thead>
              </table>
            </div>
            <div style={{ marginTop: '50px' }} className="button-container">
              <button
                className="cta-button button-glow"
                onClick={() => {
                  if (
                    confirm(
                      'You are about to redeem your pawned NFTs by paying 15 Flow tokens for each. Are you sure?'
                    )
                  ) {
                    redeem();
                  }
                }}
              >
                Redeem
              </button>
            </div>
          </div>
        ) : ('')}
      </div>
    )
  }

  const fetchCollections = async () => {
    setCollections([]);
    let collections = {};

    try {
      collections = await fcl.query({
        cadence: `${getCollectionsForAccount}`,
        args: (arg, t) => [arg(user.addr, t.Address)],
      });
    } catch (err) {
      console.log('No Collections Found!');
    }

    setCollections(collections);
  };

  const fetchNFTs = async (collectionIdentifier) => {
    setNFTs([]);
    let nfts = [];

    try {
      nfts = await fcl.query({
        cadence: `${getNFTsForAccountCollection}`,
        args: (arg, t) => [
          arg(user.addr, t.Address),
          arg(collectionIdentifier, t.String)
        ]
      });
    } catch (err) {
      console.log('No NFTs Found!');
    }

    setNFTs(nfts);
  };

  const fetchPledges = async () => {
    setPledges([]);
    let pledges = [];

    try {
      pledges = await fcl.query({
        cadence: `${getPledgeCollectionInfo}`,
        args: (arg, t) => [
          arg(user.addr, t.Address)
        ]
      });
    } catch (err) {
      console.log(err);
      console.log('No Pledge Found!');
    }

    setPledges(pledges);
  };

  const pawn = async () => {
    try {
      const transactionId = await fcl.mutate({
        cadence: `${pawnNFTs}`,
        args: (arg, t) => [
          arg(selectedCollection, t.String),
          arg(selectedNFTs, t.Array(t.UInt64))
        ],
        proposer: fcl.currentUser,
        payer: fcl.currentUser,
        limit: 1000,
      });

      console.log(
        'Pawning NFTs now with transaction ID',
        transactionId
      );

      const transaction = await fcl.tx(transactionId).onceSealed();

      console.log(
        'Testnet explorer link:',
        `https://testnet.flowscan.org/transaction/${transactionId}`
      );

      console.log(transaction);
      alert('NFTs sold successfully!');
    } catch (error) {
      console.log(error);
      alert(
        'Error selling NFT, please check the console for error details!'
      );
    }
  };

  const redeem = async (pledge) => {
    try {
      const transactionId = await fcl.mutate({
        cadence: `${redeemPledge}`,
        args: (arg, t) => [
          arg(pledge.pawns.collectionIdentifier, t.String),
          arg(pledge.id, t.Integer)
        ],
        proposer: fcl.currentUser,
        payer: fcl.currentUser,
        limit: 999,
      });

      console.log(
        'Redeem an NFT now with transaction ID',
        transactionId
      );

      const transaction = await fcl
        .tx(transactionId)
        .onceSealed();

      console.log(
        'Testnet explorer link:',
        `https://testnet.flowscan.org/transaction/${transactionId}`
      );

      console.log(transaction);
      alert('NFT redeem successfully!');
    } catch (error) {
      console.log(error);
      alert(
        'Error redeeming NFT, please check the console for error details!'
      );
    }
  };

  const RenderLogout = () => {
    if (user && user.addr) {
      return (
        <div className="logout-container">
          <button
            className="cta-button logout-btn"
            onClick={() => logOut()}
          >
            ❎ {'  '}
            {user.addr.substring(0, 6)}...
            {user.addr.substring(user.addr.length - 4)}
          </button>
        </div>
      );
    }

    return undefined;
  };

  return (
    <div className="App">
      <RenderLogout />
      <div className="container">
        <div className="header-container">
          <div className="logo-container">
            <img src="./logo.png" className="flow-logo" alt="flow logo" />
            <p className="header">
              ✨ Best NFT Pawnshop ever on Flow ✨
            </p>
          </div>

          <p className="sub-text">
            Pawn your illiquid or underperforming NFTs, <br />
            save thousands in tax money or simply get some liquidity during tough times.
          </p>
        </div>

        {user && user.addr ? (
          <React.Fragment>
            <RenderCollections />
            <RenderNFTs />
            <RenderPledges />
          </React.Fragment>
        ) : (
          <RenderLogin />
        )}
      </div>
    </div>
  );
}

export default App;
