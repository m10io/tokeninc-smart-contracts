pragma solidity ^0.4.24;


import "./Ownable.sol";
import "./TokenIOStorage.sol";
import "./TokenIOLib.sol";

contract TokenIONameSpace is Ownable {

    using TokenIOLib for TokenIOLib.Data;
    TokenIOLib.Data lib;


    constructor(address _storageContract) public {
        // Set the storage contract for the interface
        // This contract will be unable to use the storage constract until
        // contract address is authorized with the storage contract
        // Once authorized, Use the `init` method to set storage values;
        lib.Storage = TokenIOStorage(_storageContract);

        owner[msg.sender] = true;
    }

    function getTokenNameSpace(string _symbol) public view returns (address) {
        return lib.getTokenNameSpace(_symbol);
    }

}
