pragma solidity ^0.4.24;


import "./Ownable.sol";
import "./TokenIOStorage.sol";
import "./TokenIOLib.sol";

contract TokenIOERC20 is Ownable {

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

    // Ex: "USDx by token.io", "USDx", "USD", "0.1.2", 2, 2, 0, 100, 2, "0xca35b7d915458ef540ade6068dfe2f44e8fa733c"

    function setParams(
        string _name,
        string _symbol,
        string _tla,
        string _version,
        uint _decimals,
        uint _bps,
        uint _min,
        uint _max,
        uint _flat,
        address _feeAccount
    ) onlyOwner public returns (bool) {

        require(lib.setTokenName(_name));
        require(lib.setTokenSymbol(_symbol));
        require(lib.setTokenTLA(_tla));
        require(lib.setTokenVersion(_version));
        require(lib.setTokenDecimals(_decimals));
        require(lib.setTokenFeeBPS(_bps));
        require(lib.setTokenFeeMin(_min));
        require(lib.setTokenFeeMax(_max));
        require(lib.setTokenFeeFlat(_flat));
        require(lib.setTokenFeeAccount(_feeAccount));

        return true;
    }

    function name() public view returns (string) {
        return lib.getTokenName();
    }

    function symbol() public view returns (string) {
        return lib.getTokenSymbol();
    }

    function tla() public view returns (string) {
        return lib.getTokenTLA();
    }

    function version() public view returns (string) {
        return lib.getTokenVersion();
    }

    function decimals() public view returns (uint) {
        return lib.getTokenDecimals();
    }

    function totalSupply() public view returns (uint) {
      return lib.getTokenSupply();
    }

    function allowance(address account, address spender) public view returns (uint) {
      return lib.getAllowance(account, spender);
    }

    function balanceOf(address account) public view returns (uint) {
      return lib.getBalance(account);
    }

    function getFeeParams() public view returns (uint bps, uint min, uint max, uint flat) {
        return (
            lib.getTokenFeeBPS(),
            lib.getTokenFeeMin(),
            lib.getTokenFeeMax(),
            lib.getTokenFeeFlat()
        );
    }

    function transfer(address to, uint amount) public returns (bool) {
      require(lib.transfer(msg.sender, to, amount));
      return true;
    }

    function transferFrom(address from, address to, uint amount) public returns (bool) {
        require(lib.transferFrom(msg.sender, from, to, amount));
        return true;
    }

    function approve(address spender, uint amount) public returns (bool) {
        require(lib.approve(msg.sender, spender, amount));
        return true;
    }

}
