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

  TokenIOFeeContractI tokenIOFeeContractImpl;

  constructor(address _tokenIOFeeContractImpl) public {
    tokenIOFeeContractImpl = TokenIOFeeContractI(_tokenIOFeeContractImpl);
  }

  function upgradeTokenImplamintation(address _newTokenIOFeeContractImpl) onlyOwner external {
    require(_newTokenIOFeeContractImpl != address(0));
    tokenIOFeeContractImpl = TokenIOFeeContractI(_newTokenIOFeeContractImpl);
  }
  
  function setFeeParams(uint feeBps, uint feeMin, uint feeMax, uint feeFlat, bytes memory feeMsg) public returns (bool success) {
  	require(tokenIOFeeContractImpl.setFeeParams(feeBps, feeMin, feeMax, feeFlat, feeMsg), 
        "Unable to execute setFeeParams");
    return true;
  }

  function getFeeParams() public view returns (uint bps, uint min, uint max, uint flat, bytes memory feeMsg, address feeContract) {
    return tokenIOFeeContractImpl.getFeeParams();
  }

  function getTokenBalance(string memory currency) public view returns(uint balance) {
    return tokenIOFeeContractImpl.getTokenBalance(currency);
  }

  function calculateFees(uint amount) public view returns (uint fees) {
	return tokenIOFeeContractImpl.calculateFees(amount);
  }

  function transferCollectedFees(string memory currency, address to, uint amount, bytes memory data) public onlyOwner returns (bool success) {
	require(
		tokenIOFeeContractImpl.transferCollectedFees(currency, to, amount, data),
		"Unable to execute transferCollectedFees"
	);
	return true;
  }

}
