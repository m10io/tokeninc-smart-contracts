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
        require(lib.setFeeBPS(_bps));
        require(lib.setFeeMin(_min));
        require(lib.setFeeMax(_max));
        require(lib.setFeeFlat(_flat));
        require(lib.setFeeAccount(_feeAccount));
        require(lib.setTokenNameSpace(_symbol));

        return true;
    }

    function name() public view returns (string) {
        return lib.getTokenName(address(this));
    }

    function symbol() public view returns (string) {
        return lib.getTokenSymbol(address(this));
    }

    function tla() public view returns (string) {
        return lib.getTokenTLA(address(this));
    }

    function version() public view returns (string) {
        return lib.getTokenVersion(address(this));
    }

    function decimals() public view returns (uint) {
        return lib.getTokenDecimals(address(this));
    }

    function totalSupply() public view returns (uint) {
      return lib.getTokenSupply(lib.getTokenSymbol(address(this)));
    }

    function allowance(address account, address spender) public view returns (uint) {
      return lib.getTokenAllowance(lib.getTokenSymbol(address(this)), account, spender);
    }

    function balanceOf(address account) public view returns (uint) {
      return lib.getTokenBalance(lib.getTokenSymbol(address(this)), account);
    }

    function getFeeParams() public view returns (uint bps, uint min, uint max, uint flat, address feeAccount) {
        return (
            lib.getFeeBPS(address(this)),
            lib.getFeeMin(address(this)),
            lib.getFeeMax(address(this)),
            lib.getFeeFlat(address(this)),
            lib.getFeeAccount(address(this))
        );
    }

    function transfer(address to, uint amount) public returns (bool) {
      require(lib.getKYCApproval(msg.sender));
      require(lib.getKYCApproval(to));
      require(lib.transfer(to, amount, "0x0"));

      return true;
    }

    function transferFrom(address from, address to, uint amount) public returns (bool) {
        require(lib.getKYCApproval(from));
        require(lib.getKYCApproval(to));
        require(lib.transferFrom(from, to, amount));
        return true;
    }

    function approve(address spender, uint amount) public returns (bool) {
        require(lib.approve(spender, amount));
        return true;
    }



}
