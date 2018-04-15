pragma solidity 0.4.21;

import "./StorageInterface.sol";


contract MultiSig {

    StorageInterface public _storage;
    address private _admin;

    function MultiSig(StorageInterface storageContract) public {
        _storage = StorageInterface(storageContract);
        _admin = msg.sender;
    }

    function initializeOwners(address[5] _initialOwners) public onlyAdmin returns (bool) {
        for (uint owner = 0; owner < _initialOwners.length; owner++) {
            _storage.setBool(keccak256("multisig.owner", _initialOwners[owner]), true);
        }
        return true;
    }

    modifier onlyAdmin() {
        require(_admin == msg.sender);
        _;
    }

}


// Step 1: Deploy Storage Contract
// Step 2: Deploy MultiSig Contract w/ Storage Contract Address
