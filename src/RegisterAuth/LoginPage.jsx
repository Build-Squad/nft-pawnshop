import React from "react";

const LoginPage = ({ fcl }) => {
  const onLogIn = () => {
    fcl.authenticate();
  };

  return (
    <div>
      <button className="cta-button button-glow" onClick={() => onLogIn()}>
        Log In
      </button>
    </div>
  );
};

export default LoginPage;
