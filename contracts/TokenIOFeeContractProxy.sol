pragma solidity 0.5.2;

import "./Ownable.sol";

interface TokenIOFeeContractI {
  function setFeeParams(uint feeBps, uint feeMin, uint feeMax, uint feeFlat, bytes calldata feeMsg) external returns (bool success);

  function getFeeParams() external view returns (uint bps, uint min, uint max, uint flat, bytes memory feeMsg, address feeContract);

  function getTokenBalance(string calldata currency) external view returns(uint balance);

  function calculateFees(uint amount) external view returns (uint fees);

  function transferCollectedFees(string calldata currency, address to, uint amount, bytes calldata data) external returns (bool success);
}

contract TokenIOFeeContractProxy is Ownable {

  address implementationInstance;

  constructor(address _tokenIOFeeContractImpl) public {
    implementationInstance = _tokenIOFeeContractImpl;
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
  
  function setFeeParams(uint feeBps, uint feeMin, uint feeMax, uint feeFlat, bytes memory feeMsg) public returns (bool success) {
  	require(TokenIOFeeContractI(implementationInstance).setFeeParams(feeBps, feeMin, feeMax, feeFlat, feeMsg), 
        "Unable to execute setFeeParams");
    return true;
  }

  function getFeeParams() public view returns (uint bps, uint min, uint max, uint flat, bytes memory feeMsg, address feeContract) {
    return TokenIOFeeContractI(implementationInstance).getFeeParams();
  }

  function getTokenBalance(string memory currency) public view returns(uint balance) {
    return TokenIOFeeContractI(implementationInstance).getTokenBalance(currency);
  }

  function calculateFees(uint amount) public view returns (uint fees) {
	  return TokenIOFeeContractI(implementationInstance).calculateFees(amount);
  }

}
