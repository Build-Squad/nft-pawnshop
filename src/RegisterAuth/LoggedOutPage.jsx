import React from "react";

const LoggedOutPage = ({ userDetails = null, fcl }) => {
  const onLogOut = () => {
    fcl.unauthenticate();
  };

  return (
    <div className="onLcontainer">
      <button className="cta-button logout-btn" onClick={() => onLogOut()}>
        ❎ {"  "}
        {userDetails.addr.substring(0, 6)}...
        {userDetails.addr.substring(userDetails.addr.length - 4)}
      </button>
    </div>
  );
};

export default LoggedOutPage;
