/*global event*/
/*eslint no-restricted-globals: ["error", "event"]*/
import React, { useState, useEffect } from 'react';
import { Button, Modal } from 'react-bootstrap';
import './App.css';
import * as fcl from '@onflow/fcl';
import * as types from '@onflow/types';
import { getIDs } from './scripts/getIDs';
import { getMetadata } from './scripts/getMetadata';
import { setupAccount } from './transactions/setupAccount';
import { destroyCollection } from './transactions/destroyCollection';
import { addPawn } from './transactions/addPawn';
import { redeemPledge } from './transactions/redeemPledge';
import { getPledgeInfo } from './scripts/getPledgeInfo';

fcl.config({
    'flow.network': 'testnet',
    'app.detail.title': 'Nft-pawnshop',
    'accessNode.api': 'https://rest-testnet.onflow.org',
    'app.detail.icon': 'https://placekitten.com/g/200/200',
    'discovery.wallet':
        'https://fcl-discovery.onflow.org/testnet/authn',
    '0xNFTPawnshop': '0xac69e3c69589639e',
    '0xDomains': '0xac69e3c69589639e',
    '0xMetadataViews': '0x631e88ae7f1d7c20',
    '0xNonFungibleToken': '0x631e88ae7f1d7c20',
    '0xFungibleToken': '0x9a0766d93b6608b7',
    '0xFlowToken': '0x7e60df042a9c0868',
});

function App() {
    const [user, setUser] = useState();
    const [images, setImages] = useState([]);
    const [selectedNfts, setSelectedNfts] = useState([]);
    const [pledges, setPledges] = useState([]);
    const [showModal, setShow] = useState(false);

    const handleClose = () => setShow(false);
    const handleShow = () => setShow(true);

    const logIn = () => {
        fcl.authenticate();
    };

    const logOut = () => {
        setImages([]);
        setPledges([]);
        fcl.unauthenticate();
    };

    useEffect(() => {
        // This listens to changes in the user objects
        // and updates the connected user
        fcl.currentUser().subscribe(setUser);
    }, []);

    useEffect(() => {
        if (user && user.addr) {
            fetchNFTs();
            fetchPledges();
            console.log(images);
        }
    }, [user]);

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

    const RenderNfts = () => {
        return (
            <div>
                {images.length > 0 ? (
                    <>
                        <h2>Your NFTs</h2>
                        <div className="image-container">
                            {images}
                        </div>
                        {selectedNfts.length > 0 ? null : (
                            <div className="button-container">
                                <button
                                    className="cta-button button-glow"
                                    onClick={handlePawnClick}
                                >
                                    Pawn
                                </button>
                            </div>
                        )}
                    </>
                ) : (
                    'No NFTs Owned'
                )}
            </div>
        );
    };

    const RenderPledges = () => {
        return (
            <div>
                {pledges.length > 0 ? (
                    <div style={{ marginTop: '50px' }}>
                        <h2>Your Pledges</h2>
                        <div
                            style={{
                                display: 'flex',
                                justifyContent: 'center',
                            }}
                        >
                            <table>
                                <thead>
                                    <tr>
                                        <th>NFT ids</th>
                                        <th>Expiry</th>
                                        <th>Collection</th>
                                    </tr>
                                    <tr>
                                        <td>
                                            {
                                                pledges[0]
                                                    .collections[0]
                                                    .nftIDs[0]
                                            }
                                        </td>
                                        <td>
                                            {new Date(
                                                Number(
                                                    pledges[0].expiry
                                                ) * 1000
                                            ).toDateString()}
                                        </td>
                                        <td>
                                            {
                                                pledges[0]
                                                    .collections[0]
                                                    .identifier
                                            }
                                        </td>
                                    </tr>
                                </thead>
                            </table>
                        </div>
                        <div
                            style={{ marginTop: '50px' }}
                            className="button-container"
                        >
                            <button
                                className="cta-button button-glow"
                                onClick={() => {
                                    if (
                                        confirm(
                                            'You are about to redeem your pawned NFTs by paying 15 Flow tokens. Are you sure?'
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
                    ''
                )}
            </div>
        );
    };

    const RenderSetup = () => {
        return (
            <div>
                <div className="button-container">
                    <button
                        className="cta-button button-glow"
                        onClick={() => setup()}
                    >
                        Setup
                    </button>
                </div>
            </div>
        );
    };

    const handleClick = (event, key) => {
        if (!selectedNfts.includes(key)) {
            selectedNfts.push(key);
            setSelectedNfts(selectedNfts);
            event.currentTarget.style.border = '2px solid green';
        } else {
            const index = selectedNfts.indexOf(key);
            selectedNfts.splice(index, 1);
            setSelectedNfts(selectedNfts);
            event.currentTarget.style.border = '';
        }
        console.log(selectedNfts);
    };

    const handlePawnClick = (event, key) => {
        if (selectedNfts.length > 0) {
            if (
                confirm(
                    'You are about to pawn NFTs for 15 Flow tokens, you can redeem the NFTs within a year. Are you sure?'
                )
            ) {
                pawn();
            }
        } else {
            alert(
                'You have to choose an NFT first by clicking on it!'
            );
        }
        console.log(selectedNfts);
    };

    const fetchNFTs = async () => {
        // Empty the images array
        setImages([]);
        let IDs = [];

        // Fetch the IDs with a script (no fees or signers)
        try {
            IDs = await fcl.query({
                cadence: `${getIDs}`,
                args: (arg, t) => [arg(user.addr, types.Address)],
            });
        } catch (err) {
            console.log('No NFTs Owned');
        }

        let _imageSrc = [];
        try {
            for (let i = 0; i < IDs.length; i++) {
                const result = await fcl.query({
                    cadence: `${getMetadata}`,
                    args: (arg, t) => [
                        arg(user.addr, types.Address),
                        arg(IDs[i].toString(), types.UInt64),
                    ],
                });
                _imageSrc.push(result['thumbnail']);
            }
        } catch (err) {
            console.log(err);
        }

        if (images.length < _imageSrc.length) {
            setImages(
                Array.from(
                    { length: _imageSrc.length },
                    (_, i) => i
                ).map((number, index) => (
                    <img
                        style={{
                            margin: '10px',
                            height: '150px',
                        }}
                        src={_imageSrc[index]}
                        key={number}
                        onClick={(event) => {
                            handleClick(event, number);
                        }}
                        alt={'NFT #' + number}
                    />
                ))
            );
        }
    };

    const fetchPledges = async () => {
        // Empty the images array
        setPledges([]);
        let pledge = {};

        // Fetch the IDs with a script (no fees or signers)
        try {
            pledge = await fcl.query({
                cadence: `${getPledgeInfo}`,
                args: (arg, t) => [arg(user.addr, types.Address)],
            });
            setPledges([pledge]);
            console.log(pledge);
        } catch (err) {
            console.log('No Pledge Found.');
        }

        // let _imageSrc = [];
        // try {
        //     for (let i = 0; i < IDs.length; i++) {
        //         const result = await fcl.query({
        //             cadence: `${getMetadata}`,
        //             args: (arg, t) => [
        //                 arg(user.addr, types.Address),
        //                 arg(IDs[i].toString(), types.UInt64),
        //             ],
        //         });
        //         _imageSrc.push(result['thumbnail']);
        //     }
        // } catch (err) {
        //     console.log(err);
        // }

        // if (images.length < _imageSrc.length) {
        //     setImages(
        //         Array.from(
        //             { length: _imageSrc.length },
        //             (_, i) => i
        //         ).map((number, index) => (
        //             <img
        //                 style={{
        //                     margin: '10px',
        //                     height: '150px',
        //                 }}
        //                 src={_imageSrc[index]}
        //                 key={number}
        //                 onClick={(event) => {
        //                     handleClick(event, number);
        //                 }}
        //                 alt={'NFT #' + number}
        //             />
        //         ))
        //     );
        // }
    };

    const destroy = async () => {
        try {
            const transactionId = await fcl.mutate({
                cadence: `${destroyCollection}`,
                proposer: fcl.currentUser,
                payer: fcl.currentUser,
                limit: 99,
            });
            console.log(
                'Destroying collection now with transaction ID',
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
            alert('Collection destroyed successfully!');
        } catch (error) {
            console.log(error);
            alert(
                'Error destroying collection, please check the console for error details!'
            );
        }
    };

    const pawn = async () => {
        console.log('SelectedNFTS');
        console.log(selectedNfts);

        try {
            const transactionId = await fcl.mutate({
                cadence: `${addPawn}`,
                args: (arg, t) => [
                    arg(selectedNfts, t.Array(t.UInt64)),
                    //arg(['0.1'], t.Array(t.UFix64)),
                ],
                proposer: fcl.currentUser,
                payer: fcl.currentUser,
                limit: 1000,
            });
            console.log(
                'Pawn an NFT now with transaction ID',
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
            alert('NFT pawned successfully!');
        } catch (error) {
            console.log(error);
            alert(
                'Error pawning NFT, please check the console for error details!'
            );
        }
    };

    const redeem = async () => {
        console.log('Calling Redeem.');
        try {
            const transactionId = await fcl.mutate({
                cadence: `${redeemPledge}`,
                args: (arg, t) => [],
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

    const setup = async () => {
        try {
            const transactionId = await fcl.mutate({
                cadence: `${setupAccount}`,
                args: (arg, t) => [],
                proposer: fcl.currentUser,
                payer: fcl.currentUser,
                limit: 99,
            });
            console.log('Setting up account', transactionId);
            const transaction = await fcl
                .tx(transactionId)
                .onceSealed();
            console.log(
                'Testnet explorer link:',
                `https://testnet.flowscan.org/transaction/${transactionId}`
            );
            console.log(transaction);
            alert('Account setup successfully!');
        } catch (error) {
            console.log(error);
            alert(
                'Error setting up the account, please check the console for error details!'
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
                        <img
                            src="./logo.png"
                            className="flow-logo"
                            alt="flow logo"
                        />
                        <p className="header">
                            ✨Best NFTs pawnshop ever on Flow ✨
                        </p>
                    </div>

                    <p className="sub-text">
                        Harvesting your NFT losses in few clicks.
                    </p>
                </div>

                {/* If not logged in, render login button */}
                {user && user.addr ? (
                    //'Wallet connected!'
                    <React.Fragment>
                        <RenderNfts />
                        <RenderPledges />
                    </React.Fragment>
                ) : (
                    <RenderLogin />
                )}
            </div>
            {/* <Modal show={showModal} onHide={handleClose}>
                <Modal.Header closeButton>
                    <Modal.Title>Modal heading</Modal.Title>
                </Modal.Header>
                <Modal.Body>
                    Woohoo, you're reading this text in a modal!
                </Modal.Body>
                <Modal.Footer>
                    <Button variant="secondary" onClick={handleClose}>
                        Close
                    </Button>
                    <Button variant="primary" onClick={handleClose}>
                        Save Changes
                    </Button>
                </Modal.Footer>
            </Modal> */}
        </div>
    );
}

export default App;
