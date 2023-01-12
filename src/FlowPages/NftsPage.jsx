import React, { useEffect, useState } from "react";
import { getNFTsForAccountCollection } from "../scripts/getNFTsForAccountCollection";

const NftsPage = ({
  userDetails,
  collectionKey,
  selectedNFTs,
  onSelectNfts,
  fcl,
}) => {
  const [nfts, setNFTs] = useState([]);

  useEffect(() => {
    fetchNFTs(collectionKey);
  }, [collectionKey]);

  const fetchNFTs = async (collectionIdentifier) => {
    setNFTs([]);
    let nfts = [];

    try {
      nfts = await fcl.query({
        cadence: `${getNFTsForAccountCollection}`,
        args: (arg, t) => [
          arg(userDetails.addr, t.Address),
          arg(collectionIdentifier, t.String),
        ],
      });
    } catch (err) {
      console.log("No NFTs Found!");
    }

    setNFTs(nfts);
  };

  const handleNFTClick = (event, key) => {
    if (!selectedNFTs.includes(key)) {
      selectedNFTs.push(key);
      onSelectNfts(selectedNFTs);
      event.currentTarget.style.border = "2px solid green";
    } else {
      const index = selectedNFTs.indexOf(key);
      selectedNFTs.splice(index, 1);
      onSelectNfts(selectedNFTs);
      event.currentTarget.style.border = "";
    }
  };

  return (
    <div>
      {nfts.length > 0 ? (
        <>
          {nfts.map((nft) => (
            <div key={nft.id}>
              <div>ID: {nft.id}</div>
              <div>Name: {nft.name}</div>
              <div>Description: {nft.description}</div>
              <div>
                <img
                  width="50px"
                  height="50px"
                  alt="nft_image"
                  src={nft.thumbnail}
                  onClick={(event) => handleNFTClick(event, nft.id)}
                />
              </div>
            </div>
          ))}
        </>
      ) : (
        ""
      )}
    </div>
  );
};

export default NftsPage;
