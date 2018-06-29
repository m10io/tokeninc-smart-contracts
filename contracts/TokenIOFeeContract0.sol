pragma solidity ^0.4.24;

import "./Ownable.sol";
import "./TokenIOStorage.sol";
import "./TokenIOLib.sol";


/*
COPYRIGHT 2018 Token, Inc.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


@title Standard Fee Contract for Token, Inc. Smart Money System

@author Ryan Tate <ryan.michael.tate@gmail.com>, Sean Pollock <seanpollock3344@gmail.com>

@notice Contract uses generalized storage contract, `TokenIOStorage`, for
upgradeability of interface contract.

@dev In the event that the main contract becomes deprecated, the upgraded contract
will be set as the owner of this contract, and use this contract's storage to
maintain data consistency between contract.

*/


contract TokenIOFeeContract is Ownable {

	/**
	 * @notice This contract uses the TokenIOLib for logic handling
	 */
	using TokenIOLib for TokenIOLib.Data;
	TokenIOLib.Data lib;


	/**
	* @notice Constructor method for ERC20 contract
	* @param _storageContract     address of TokenIOStorage contract
	*/
	constructor(address _storageContract) public {
			/// @dev Set the storage contract for the interface
			/// @dev NOTE: This contract will be unable to use the storage constract until
			/// @dev contract address is authorized with the storage contract
			/// @dev Once authorized, Use the `setParams` method to set storage values
			lib.Storage = TokenIOStorage(_storageContract);

			/// @dev set owner to contract initiator
			owner[msg.sender] = true;
	}

	/**
	 * @notice Set Fee Parameters for Fee Contract
	 * @dev The min, max, flat transaction fees should be relative to decimal precision
	 * @param feeBps [uint] Basis points transaction fee
	 * @param feeMin [uint] Minimum transaction fees
	 * @param feeMax [uint] Maximum transaction fee
	 * @param feeFlat [uint] Flat transaction fee
	 * returns bool Returns true if called from another contract successfully.
	 */
	function setFeeParams(uint feeBps, uint feeMin, uint feeMax, uint feeFlat) public onlyOwner returns (bool) {
		require(lib.setFeeBPS(feeBps));
		require(lib.setFeeMin(feeMin));
		require(lib.setFeeMax(feeMax));
		require(lib.setFeeFlat(feeFlat));
		return true;
	}

	/* @notice Gets fee parameters
	* @return [tuple] (uint, uint, uint, uint, address)
	*    bps [uint] fee amount as a mesuare of basis points
	*    min [uint] minimum fee amount
	*    max [uint] maximum fee amount
	*    flat [uint] flat fee amount
	*    contract [address] fee contract address
	*/
	function getFeeParams() public view returns (uint bps, uint min, uint max, uint flat) {
			return (
					lib.getFeeBPS(address(this)),
					lib.getFeeMin(address(this)),
					lib.getFeeMax(address(this)),
					lib.getFeeFlat(address(this))
			);
	}

	/**
	 * @notice Returns balance of this contract associated with currency symbol.
	 * @param  currency string Currency symbol of the token (e.g. USDx, JYPx, GBPx)
	 * @return balance  uint   Returns the balance of the held currency for this contract
	 */
	function getTokenBalance(string currency) public view returns(uint) {
		return lib.getTokenBalance(currency, address(this));
	}

	/* @notice Calculates fee of a given transfer amount
	 * @param amount [uint] transfer amount
	 * @return [uint] fee amount
	 */
	function calculateFees(uint amount) public view returns (uint) {
		return lib.calculateFees(address(this), amount);
	}


	/**
	 * @notice Transfer collected fees to another account; onlyOwner
	 * @param  currency string  Currency symbol of the token (e.g. USDx, JYPx, GBPx)
	 * @param  to 			address Ethereum address of account to send token amount to
	 * @param  amount	  uint    Amount of tokens to transfer
	 * @param  data		  bytes   Arbitrary bytes data message to include in transfer
	 * @return bool		          Returns true if successfully called from another contract
	 */
	function transferCollectedFees(string currency, address to, uint amount, bytes data) public onlyOwner returns (bool) {
		require(lib.verifyAccount(to));
		require(lib.forceTransfer(currency, address(this), to, amount, data));
		return true;
	}


}
