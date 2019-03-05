pragma solidity 0.5.2;

import "./Ownable.sol";

interface TokenIOERC20I {
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

contract TokenIOERC20Proxy is Ownable {

  address implementationInstance;

  constructor(address _tokenIOERC20Impl) public {
    implementationInstance = _tokenIOERC20Impl;
  }

  function upgradeTo(address _newImplementationInstance) onlyOwner external {
    require(_newImplementationInstance != address(0));
    implementationInstance = _newImplementationInstance;
  }

  function staticCall(bytes calldata payload) external view returns(bytes memory) {
    (bool res, bytes memory result) = implementationInstance.staticcall(payload);
    return result;
  }

  function call(bytes calldata payload) external {
    (bool res, bytes memory result) = implementationInstance.call(payload);
    require(res);
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
      require(TokenIOERC20I(implementationInstance).setParams(_name, _symbol, _tla, _version, _decimals, _feeContract, _fxUSDBPSRate), 
        "Unable to execute setParams");
    return true;
  }

  function transfer(address to, uint256 amount) external returns(bool) {
    require(TokenIOERC20I(implementationInstance).transfer(to, amount, msg.sender), 
      "Unable to execute transfer");
    
    return true;
  }

  function transferFrom(address from, address to, uint256 amount) external returns(bool) {
    require(TokenIOERC20I(implementationInstance).transferFrom(from, to, amount, msg.sender), 
      "Unable to execute transferFrom");

    return true;
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    require(TokenIOERC20I(implementationInstance).approve(spender, amount, msg.sender), 
      "Unable to execute approve");

    return true;
  }

  function name() external view returns (string memory) {
    return TokenIOERC20I(implementationInstance).name();
  }

  function symbol() external view returns (string memory) {
    return TokenIOERC20I(implementationInstance).symbol();
  }

  function tla() external view returns (string memory) {
    return TokenIOERC20I(implementationInstance).tla();
  }

  function version() external view returns (string memory) {
    return TokenIOERC20I(implementationInstance).version();
  }

  function decimals() external view returns (uint) {
    return TokenIOERC20I(implementationInstance).decimals();
  }

  function totalSupply() external view returns (uint256) {
    return TokenIOERC20I(implementationInstance).totalSupply();
  }

  function allowance(address account, address spender) external view returns (uint256) {
    return TokenIOERC20I(implementationInstance).allowance(account, spender);
  }

  function balanceOf(address account) external view returns (uint256) {
    return TokenIOERC20I(implementationInstance).balanceOf(account);
  }

  function getFeeParams() public view returns (uint bps, uint min, uint max, uint flat, bytes memory feeMsg, address feeAccount) {
    return TokenIOERC20I(implementationInstance).getFeeParams();
  }

  function calculateFees(uint amount) external view returns (uint256) {
    return TokenIOERC20I(implementationInstance).calculateFees(amount);
  }

  function deprecateInterface() external onlyOwner returns (bool) {
    require(TokenIOERC20I(implementationInstance).deprecateInterface(), 
      "Unable to execute deprecateInterface");

    return true;
  }

}
