import React, { useState, useEffect } from "react";
import { getPledgeCollectionInfo } from "../scripts/getPledgeCollectionInfo";
import { redeemPledge } from "../transactions/redeemPledge";

const PledgesPage = ({ userDetails, fcl, confirm }) => {
  const [pledges, setPledges] = useState([]);

  useEffect(() => {
    fetchPledges();
  }, []);

  const fetchPledges = async () => {
    setPledges([]);
    let pledges = [];

    try {
      pledges = await fcl.query({
        cadence: `${getPledgeCollectionInfo}`,
        args: (arg, t) => [arg(userDetails.addr, t.Address)],
      });
    } catch (err) {
      console.log(err);
      console.log("No Pledge Found!");
    }
    console.log(pledges);

    setPledges(pledges);
  };

  const redeem = async (pledge) => {
    try {
      const transactionId = await fcl.mutate({
        cadence: `${redeemPledge}`,
        args: (arg, t) => [
          arg(pledge.pawns.collectionIdentifier, t.String),
          arg(pledge.id, t.Integer),
        ],
        proposer: fcl.currentUser,
        payer: fcl.currentUser,
        limit: 999,
      });

      console.log("Redeem an NFT now with transaction ID", transactionId);

      const transaction = await fcl.tx(transactionId).onceSealed();

      console.log(
        "Testnet explorer link:",
        `https://testnet.flowscan.org/transaction/${transactionId}`
      );

      console.log(transaction);
      alert("NFT redeem successfully!");
    } catch (error) {
      console.log(error);
      alert("Error redeeming NFT, please check the console for error details!");
    }
  };

  return (
    <div>
      {pledges.length > 0 ? (
        <div style={{ marginTop: "50px" }}>
          <h2>Your NFT Pledges</h2>
          <div
            style={{
              display: "flex",
              justifyContent: "center",
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
                {pledges.map(pledge => (
                  <tr key={pledge.id}>
                    <td>{pledge.debitor}</td>
                    <td>
                      {new Date(Number(pledge.expiry) * 1000).toDateString()}
                    </td>
                    <td>{pledge.pawns.salePrice}</td>
                    <td>{pledge.pawns.collectionIdentifier}</td>
                    <td>{pledge.pawns.nftIDs.join(", ")}</td>
                  </tr>
                ))}
              </thead>
            </table>
          </div>
          <div style={{ marginTop: "50px" }} className="button-container">
            <button
              className="cta-button button-glow"
              onClick={() => {
                if (
                  confirm(
                    "You are about to redeem your pawned NFTs by paying 15 Flow tokens for each. Are you sure?"
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
      ) : (
        ""
      )}
    </div>
  );
};

export default PledgesPage;
