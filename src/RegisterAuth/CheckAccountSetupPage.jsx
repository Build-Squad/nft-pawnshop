import React, { useEffect } from "react";
import { checkAccountSetup } from "../scripts/checkAccountSetup";
import { setupPledgeCollection } from "../transactions/setupPledgeCollection";

const CheckAccountSetupPage = ({ userDetails, fcl, onSetSetupStatus }) => {
  useEffect(() => {
    checkSetupStatus();
  }, []);

  const setupAccount = async () => {
    try {
      const transactionId = await fcl.mutate({
        cadence: `${setupPledgeCollection}`,
        proposer: fcl.currentUser,
        payer: fcl.currentUser,
        limit: 1000,
      });

      console.log("Setting up account with transaction ID", transactionId);

      const transaction = await fcl.tx(transactionId).onceSealed();

      console.log(
        "Testnet explorer link:",
        `https://testnet.flowscan.org/transaction/${transactionId}`
      );

      console.log(transaction);
      alert("Account setup successfully!");
    } catch (error) {
      console.log(error);
      alert("Error while setting up account!");
    }
  };

  const checkSetupStatus = async () => {
    let isSetupCorrect = false;

    try {
      isSetupCorrect = await fcl.query({
        cadence: `${checkAccountSetup}`,
        args: (arg, t) => [
          arg(userDetails.addr, t.Address)
        ],
      });
    } catch (err) {
      console.log(err);
    }

    onSetSetupStatus(isSetupCorrect);
  };

  return (
    <div
      style={{ marginTop: "50px", marginBottom: "50px" }}
      className="button-container"
    >
      <button
        className="cta-button button-glow"
        onClick={setupAccount}
      >
        Setup
      </button>
    </div>
  );
};

export default CheckAccountSetupPage;
