pragma solidity ^0.4.24;

import "./Ownable.sol";
import "./TokenIOStorage.sol";
import "./TokenIOLib.sol";


/*

- Sets Fee params
- Hold Token Balances & Send Token Balances to other accounts.

 */


contract TokenIOFeeContract is Ownable {

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

	function setFeeParams(uint feeBps, uint feeMin, uint feeMax, uint feeFlat) public onlyOwner returns (bool) {
		require(lib.setFeeBPS(feeBps));
		require(lib.setFeeMin(feeMin));
		require(lib.setFeeMax(feeMax));
		require(lib.setFeeFlat(feeFlat));
		return true;
	}

	function getFeeParams() public view returns (uint bps, uint min, uint max, uint flat) {
			return (
					lib.getFeeBPS(address(this)),
					lib.getFeeMin(address(this)),
					lib.getFeeMax(address(this)),
					lib.getFeeFlat(address(this))
			);
	}

	function getTokenBalance(string currency) public view returns(uint) {
		return lib.getTokenBalance(currency, address(this));
	}

	function calculateFees(uint amount) public view returns (uint) {
		return lib.calculateFees(address(this), amount);
	}

	function transferCollectedFees(string currency, address to, uint amount, bytes data) public onlyOwner returns (bool) {
		require(lib.verifyAccount(to));
		require(lib.forceTransfer(currency, address(this), to, amount, data));
		return true;
	}


}
