import React, { useState, useEffect } from "react";
import { getCollectionsForAccount } from "../scripts/getCollectionsForAccount";

const CollectionsPage = ({ userDetails, onSelectCollection, fcl }) => {
  const [collections, setCollections] = useState({});

  useEffect(() => {
    fetchCollections();
  }, []);

  const fetchCollections = async () => {
    setCollections([]);
    let collections = {};

    try {
      collections = await fcl.query({
        cadence: `${getCollectionsForAccount}`,
        args: (arg, t) => [arg(userDetails.addr, t.Address)],
      });
    } catch (err) {
      console.log("No Collections Found!");
    }

    setCollections(collections);
  };

  const handleCollectionClick = (_, key) => {
    onSelectCollection(key);
  };

  return (
    <div>
      {Object.keys(collections).length > 0 ? (
        <>
          <h2>Your Collections</h2>
          <div className="image-container">
            <ul>
              {Object.entries(collections).map(([name, count]) => (
                <li
                  onClick={(event) => {
                    handleCollectionClick(event, name);
                  }}
                  key={name}
                >
                  {name} ({count} NFTs)
                </li>
              ))}
            </ul>
          </div>
        </>
      ) : (
        "No Collections Owned!"
      )}
    </div>
  );
};

export default CollectionsPage;
