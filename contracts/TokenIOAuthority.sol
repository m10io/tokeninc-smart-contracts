pragma solidity ^0.4.24;


import "./Ownable.sol";
import "./TokenIOStorage.sol";
import "./TokenIOLib.sol";

contract TokenIOAuthority is Ownable {

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

    function setRegisteredFirm(string _firmName, bool _authorized) public onlyAuthority(_firmName, msg.sender) returns (bool) {
        require(lib.setRegisteredFirm(_firmName, _authorized));
        return true;
    }

    function setRegisteredAuthority(string _firmName, address _authority, bool _authorized) public onlyAuthority(_firmName, msg.sender) returns (bool) {
        require(lib.setRegisteredAuthority(_firmName, _authority, _authorized));
        return true;
    }

    function getFirmFromAuthority(address _authority) public view returns (string) {
        return lib.getFirmFromAuthority(_authority);
    }

    function isRegisteredFirm(string _firmName) public view returns (bool) {
        return lib.isRegisteredFirm(_firmName);
    }

    function isRegisteredToFirm(string _firmName, address _authority) public view returns (bool) {
        return lib.isRegisteredToFirm(_firmName, _authority);
    }

    function isRegisteredAuthority(address _authority) public view returns (bool) {
        return lib.isRegisteredAuthority(_authority);
    }

    modifier onlyAuthority(string _firmName, address _authority) {
        require(owner[_authority] || lib.isRegisteredToFirm(_firmName, _authority));
        _;
    }

}
