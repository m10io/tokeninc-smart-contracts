pragma solidity 0.5.2;

import "./Ownable.sol";

interface TokenIOERC20FeesApplyI {
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

contract TokenIOERC20FeesApplyProxy is Ownable {

  address implementationInstance;

  constructor(address _tokenIOERC20FeesApplyImpl) public {
    implementationInstance = _tokenIOERC20FeesApplyImpl;
  }

  function upgradeTo(address _newImplementationInstance) onlyOwner external {
    implementationInstance = _newImplementationInstance;
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
      require(TokenIOERC20FeesApplyI(implementationInstance).setParams(_name, _symbol, _tla, _version, _decimals, _feeContract, _fxUSDBPSRate), 
        "Unable to execute setParams");
    return true;
  }

  function staticCall(bytes calldata payload) external view returns(bytes memory) {
    (bool res, bytes memory result) = implementationInstance.staticcall(payload);
    return result;
  }

  function call(bytes calldata payload) external {
    (bool res, bytes memory result) = implementationInstance.call(payload);
    require(res);
  }
  
  function transfer(address to, uint256 amount) external returns(bool) {
    require(TokenIOERC20FeesApplyI(implementationInstance).transfer(to, amount, msg.sender), 
      "Unable to execute transfer");
    
    return true;
  }

  function transferFrom(address from, address to, uint256 amount) external returns(bool) {
    require(TokenIOERC20FeesApplyI(implementationInstance).transferFrom(from, to, amount, msg.sender), 
      "Unable to execute transferFrom");

    return true;
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    require(TokenIOERC20FeesApplyI(implementationInstance).approve(spender, amount, msg.sender), 
      "Unable to execute approve");

    return true;
  }

  function name() external view returns (string memory) {
    return TokenIOERC20FeesApplyI(implementationInstance).name();
  }

  function symbol() external view returns (string memory) {
    return TokenIOERC20FeesApplyI(implementationInstance).symbol();
  }

  function tla() external view returns (string memory) {
    return TokenIOERC20FeesApplyI(implementationInstance).tla();
  }

  function version() external view returns (string memory) {
    return TokenIOERC20FeesApplyI(implementationInstance).version();
  }

  function decimals() external view returns (uint) {
    return TokenIOERC20FeesApplyI(implementationInstance).decimals();
  }

  function totalSupply() external view returns (uint256) {
    return TokenIOERC20FeesApplyI(implementationInstance).totalSupply();
  }

  function allowance(address account, address spender) external view returns (uint256) {
    return TokenIOERC20FeesApplyI(implementationInstance).allowance(account, spender);
  }

  function balanceOf(address account) external view returns (uint256) {
    return TokenIOERC20FeesApplyI(implementationInstance).balanceOf(account);
  }

  function calculateFees(uint amount) external view returns (uint256) {
    return TokenIOERC20FeesApplyI(implementationInstance).calculateFees(amount);
  }

  function deprecateInterface() external onlyOwner returns (bool) {
    require(TokenIOERC20FeesApplyI(implementationInstance).deprecateInterface(), 
      "Unable to execute deprecateInterface");

    return true;
  }

}
