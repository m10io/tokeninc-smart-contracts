pragma solidity 0.5.2;

import "./Ownable.sol";


contract TokenIOERC20FeesApplyProxy is Ownable {

  address tokenIOERC20FeesApplyImpl;

  constructor(address _tokenIOERC20FeesApplyImpl) public {
    tokenIOERC20FeesApplyImpl = _tokenIOERC20FeesApplyImpl;
  }

  function upgradeTokenImplamintation(address _newTokenIOERC20FeesApplyImpl) onlyOwner external {
    require (_newTokenIOERC20FeesApplyImpl != address(0));
    tokenIOERC20FeesApplyImpl = _newTokenIOERC20FeesApplyImpl;
  }
  
  function setParams(
    string calldata _name,
    string calldata _symbol,
    string calldata _tla,
    string calldata _version,
    uint256 _decimals,
    address _feeContract,
    uint256 _fxUSDBPSRate
    ) onlyOwner external returns(bool) {
    (bool success, ) = tokenIOERC20FeesApplyImpl.call(abi.encodeWithSignature("setParams(bytes32,bytes32,bytes32,bytes32,uint256,address,uint256)", stringToBytes32(_name), stringToBytes32(_symbol), stringToBytes32(_tla), stringToBytes32(_version), _decimals, _feeContract, _fxUSDBPSRate));
    return success;
  }

  function transfer(address to, uint256 amount) external returns(bool) {
    (bool success, ) = tokenIOERC20FeesApplyImpl.call(abi.encodeWithSignature("transfer(address,uint256)", to, amount));
    require(success, "Unable to execute transfer");
    
    return success;
  }

  function transferFrom(address from, address to, uint256 amount) external returns(bool) {
    (bool success, ) = tokenIOERC20FeesApplyImpl.call(abi.encodeWithSignature("transferFrom(address,address,uint256)", from, to, amount));
    require(success, "Unable to execute transferFrom");
    return success;
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    (bool success, ) = tokenIOERC20FeesApplyImpl.call(abi.encodeWithSignature("approve(address,uint256)", spender, amount));
    require(success, "Unable to execute approve");
    return success;
  }

  function name() external view returns (string memory) {
    bytes memory payload = abi.encodeWithSignature("name()");
    (bool success, bytes memory returnData) = tokenIOERC20FeesApplyImpl.staticcall(payload);
    return bytesToString(returnData);
  }

  function symbol() external view returns (string memory) {
    bytes memory payload = abi.encodeWithSignature("symbol()");
    (bool success, bytes memory returnData) = tokenIOERC20FeesApplyImpl.staticcall(payload);
    return bytesToString(returnData);
  }

  function tla() external view returns (string memory) {
    bytes memory payload = abi.encodeWithSignature("tla()");
    (bool success, bytes memory returnData) = tokenIOERC20FeesApplyImpl.staticcall(payload);
    return bytesToString(returnData);
  }

  function version() external view returns (string memory) {
    bytes memory payload = abi.encodeWithSignature("version()");
    (bool success, bytes memory returnData) = tokenIOERC20FeesApplyImpl.staticcall(payload);
    return bytesToString(returnData);
  }

  function decimals() external view returns (uint) {
    bytes memory payload = abi.encodeWithSignature("decimals()");
    (bool success, bytes memory returnData) = tokenIOERC20FeesApplyImpl.staticcall(payload);
    return bytesToUint256(returnData);
  }

  function totalSupply() external view returns (uint256) {
    bytes memory payload = abi.encodeWithSignature("totalSupply()");
    (bool success, bytes memory returnData) = tokenIOERC20FeesApplyImpl.staticcall(payload);
    return bytesToUint256(returnData);
  }

  function allowance(address account, address spender) external view returns (uint256) {
    bytes memory payload = abi.encodeWithSignature("allowance(address,address)", account, spender);
    (bool success, bytes memory returnData) = tokenIOERC20FeesApplyImpl.staticcall(payload);
    return bytesToUint256(returnData);
  }

  function balanceOf(address account) external view returns (uint256) {
    bytes memory payload = abi.encodeWithSignature("balanceOf(address)", account);
    (bool success, bytes memory returnData) = tokenIOERC20FeesApplyImpl.staticcall(payload);
    return bytesToUint256(returnData);
  }

  function calculateFees(uint amount) external view returns (uint256) {
    bytes memory payload = abi.encodeWithSignature("calculateFees(uint256)", amount);
    (bool success, bytes memory returnData) = tokenIOERC20FeesApplyImpl.staticcall(payload);
    return bytesToUint256(returnData);
  }

  function deprecateInterface() external onlyOwner returns (bool) {
    bytes memory payload = abi.encodeWithSignature("deprecateInterface()");
    (bool success, bytes memory returnData) = tokenIOERC20FeesApplyImpl.call(payload);
    return bytesToUint256(returnData) != 0;
  }

  function stringToBytes32(string memory source) internal view returns (bytes32 result) {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
        return 0x0;
    }

    assembly {
        result := mload(add(source, 32))
    }
  }

  function bytesToString(bytes memory x) internal view returns (string memory) {
    bytes memory bytesString = new bytes(20);
    uint charCount = 0;
    for (uint j = 0; j < 32; j++) {
        byte char = byte(bytes32(bytesToUint256(x) * 2 ** (8 * j)));
        if (char != 0) {
            bytesString[charCount] = char;
            charCount++;
        }
    }
    bytes memory bytesStringTrimmed = new bytes(charCount);
    for (uint j = 0; j < charCount; j++) {
        bytesStringTrimmed[j] = bytesString[j];
    }
    return string(bytesStringTrimmed);
  }

  function bytesToUint256(bytes memory _b) internal view returns (uint256){
    uint256 number;
    for(uint i=0;i<_b.length;i++){
      number = number + uint256(uint8(_b[i]))*(2**(8*(_b.length-(i+1))));
    }
    return number;
  }

}
