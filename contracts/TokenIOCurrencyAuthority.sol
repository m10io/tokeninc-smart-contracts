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

    function freezeAccount(address account, bool isAllowed, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool) {
        require(lib.setAccountStatus(account, isAllowed, issuerFirm));
        return true;
    }

    function approveKYC(address account, bool isApproved, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool) {
        require(lib.setKYCApproval(account, isApproved, issuerFirm));
        require(lib.setAccountStatus(account, isApproved, issuerFirm));
        return true;
    }

    function approveKYCAndDeposit(string currency, address account, uint amount, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool) {
        require(lib.setKYCApproval(account, true, issuerFirm));
        require(lib.setAccountStatus(account, true, issuerFirm));
        require(lib.deposit(currency, account, amount, issuerFirm));
        return true;
    }

    function approveForwardedAccount(address originalAccount, address updatedAccount, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool) {
      require(lib.setForwardedAccount(originalAccount, updatedAccount));
      return true;
    }

    function deposit(string currency, address account, uint amount, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool) {
        require(lib.getKYCApproval(account));
        require(lib.getAccountStatus(account));
        require(lib.deposit(currency, account, amount, issuerFirm));
        return true;
    }

    function getTokenBalance(string currency, address account) public view returns (uint) {
      return lib.getTokenBalance(currency, account);
    }

    function withdraw(string currency, address account, uint amount, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool) {
        require(lib.getAccountStatus(account));
        require(lib.withdraw(currency, account, amount, issuerFirm));
        return true;
    }

    modifier onlyAuthority(string _firmName, address _authority) {
        require(lib.isRegisteredToFirm(_firmName, _authority));
        _;
    }

}
