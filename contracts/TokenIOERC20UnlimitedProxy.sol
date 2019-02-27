pragma solidity 0.5.2;

import "./Ownable.sol";

interface TokenIOERC20UnlimitedI {
  function setParams(string calldata _name, string calldata _symbol, string calldata _tla, string calldata _version, uint _decimals, address _feeContract, uint _fxUSDBPSRate) external returns(bool success);

  function name() external view returns (string memory _name);

  function symbol() external view returns (string memory _symbol);

  function tla() external view returns (string memory _tla);

  function version() external view returns (string memory _version);

  function decimals() external view returns (uint _decimals);

  function totalSupply() external view returns (uint supply);

  function allowance(address account, address spender) external view returns (uint amount);

  function balanceOf(address account) external view returns (uint balance);

  function getFeeParams() external view returns (uint bps, uint min, uint max, uint flat, bytes memory feeMsg, address feeAccount);

  function calculateFees(uint amount) external view returns (uint fees);

  function transfer(address to, uint amount, address sender) external returns(bool success);

  function transferFrom(address from, address to, uint amount, address sender) external returns(bool success);

  function approve(address spender, uint amount, address sender) external returns (bool success);

  function deprecateInterface() external returns (bool deprecated);
}

contract TokenIOERC20UnlimitedProxy is Ownable {

  TokenIOERC20UnlimitedI tokenIOERC20UnlimitedImpl;

  constructor(address _tokenIOERC20UnlimitedImpl) public {
    tokenIOERC20UnlimitedImpl = TokenIOERC20UnlimitedI(_tokenIOERC20UnlimitedImpl);
  }

  function upgradeTokenImplamintation(address _newTokenIOERC20UnlimitedImpl) onlyOwner external {
    require(_newTokenIOERC20UnlimitedImpl != address(0));
    tokenIOERC20UnlimitedImpl = TokenIOERC20UnlimitedI(_newTokenIOERC20UnlimitedImpl);
  }
  
  function setParams(
    string memory _name,
    string memory _symbol,
    string memory _tla,
    string memory _version,
    uint256 _decimals,
    address _feeContract,
    uint256 _fxUSDBPSRate
    ) onlyOwner public returns(bool) {
      require(tokenIOERC20UnlimitedImpl.setParams(_name, _symbol, _tla, _version, _decimals, _feeContract, _fxUSDBPSRate), 
        "Unable to execute setParams");
    return true;
  }

  function transfer(address to, uint256 amount) external returns(bool) {
    require(tokenIOERC20UnlimitedImpl.transfer(to, amount, msg.sender), 
      "Unable to execute transfer");
    
    return true;
  }

  function transferFrom(address from, address to, uint256 amount) external returns(bool) {
    require(tokenIOERC20UnlimitedImpl.transferFrom(from, to, amount, msg.sender), 
      "Unable to execute transferFrom");

    return true;
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    require(tokenIOERC20UnlimitedImpl.approve(spender, amount, msg.sender), 
      "Unable to execute approve");

    return true;
  }

  function name() external view returns (string memory) {
    return tokenIOERC20UnlimitedImpl.name();
  }

  function symbol() external view returns (string memory) {
    return tokenIOERC20UnlimitedImpl.symbol();
  }

  function tla() external view returns (string memory) {
    return tokenIOERC20UnlimitedImpl.tla();
  }

  function version() external view returns (string memory) {
    return tokenIOERC20UnlimitedImpl.version();
  }

  function decimals() external view returns (uint) {
    return tokenIOERC20UnlimitedImpl.decimals();
  }

  function totalSupply() external view returns (uint256) {
    return tokenIOERC20UnlimitedImpl.totalSupply();
  }

  function allowance(address account, address spender) external view returns (uint256) {
    return tokenIOERC20UnlimitedImpl.allowance(account, spender);
  }

  function balanceOf(address account) external view returns (uint256) {
    return tokenIOERC20UnlimitedImpl.balanceOf(account);
  }

  function calculateFees(uint amount) external view returns (uint256) {
    return tokenIOERC20UnlimitedImpl.calculateFees(amount);
  }

  function deprecateInterface() external onlyOwner returns (bool) {
    require(tokenIOERC20UnlimitedImpl.deprecateInterface(), 
      "Unable to execute deprecateInterface");

    return true;
  }

}
