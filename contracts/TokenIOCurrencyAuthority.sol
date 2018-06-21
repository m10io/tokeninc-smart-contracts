pragma solidity ^0.4.24;


import "./Ownable.sol";
import "./TokenIOStorage.sol";
import "./TokenIOLib.sol";


contract TokenIOCurrencyAuthority is Ownable {

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


    function deposit(string currency, address account, uint amount, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool) {
        require(lib.deposit(lib.getTokenNameSpace(currency), account, amount, issuerFirm));
        return true;
    }

    function withdraw(string currency, address account, uint amount, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool) {
        require(lib.withdraw(lib.getTokenNameSpace(currency), account, amount, issuerFirm));
        return true;
    }

    modifier onlyAuthority(string _firmName, address _authority) {
        require(lib.isRegisteredToFirm(_firmName, _authority));
        _;
    }

}
