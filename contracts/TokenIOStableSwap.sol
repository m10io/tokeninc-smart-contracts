pragma solidity 0.4.24;

import "./Ownable.sol";
import "./TokenIOStorage.sol";
import "./TokenIOLib.sol";
import "./ERC20Interface.sol";

/*
COPYRIGHT 2018 Token, Inc.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

@title ERC20 Compliant StableCoin Swap Smart Contract for Token, Inc.

@author Ryan Tate <ryan.tate@token.io>, Sean Pollock <sean.pollock@token.io>

@notice Contract uses generalized storage contract, `TokenIOStorage`, for
upgradeability of interface contract.

@dev In the event that the main contract becomes deprecated, the upgraded contract
will be set as the owner of this contract, and use this contract's storage to
maintain data consistency between contract.
*/



contract TokenIOStableSwap is Ownable {
  //// @dev Set reference to TokenIOLib interface which proxies to TokenIOStorage
  using TokenIOLib for TokenIOLib.Data;
  TokenIOLib.Data lib;

  /**
  * @notice Constructor method for TokenIOStableSwap contract
  * @param _storageContract     address of TokenIOStorage contract
  */
  constructor(address _storageContract) public {
    //// @dev Set the storage contract for the interface
    //// @dev This contract will be unable to use the storage constract until
    //// @dev contract address is authorized with the storage contract
    //// @dev Once authorized, Use the `setParams` method to set storage values
    lib.Storage = TokenIOStorage(_storageContract);

    //// @dev set owner to contract initiator
    owner[msg.sender] = true;
  }

	/**
	 * @notice Allows the address of the asset to be accepted by this contract by the currency type. This method is only called by admins.
	 * @notice This method may be deprecated or refactored to allow for multiple interfaces
	 * @param  asset Ethereum address of the ERC20 compliant smart contract to allow the swap
	 * @param  currency string Currency symbol of the token (e.g. `USD`, `EUR`, `GBP`, `JPY`, `AUD`, `CAD`, `CHF`, `NOK`, `NZD`, `SEK`)
	 * @return {"success": "Return boolean success if able to set the allowed asset"}
	 */
	function allowAsset(address asset, string currency) public onlyOwner returns (bool success) {
		bytes32 id = keccak256(abi.encodePacked('allowed.stable.asset', asset, currency));
    require(
      lib.Storage.setBool(id, true),
      "Error: Unable to set storage value. Please ensure contract interface is allowed by the storage contract."
    );
		return true;
	}

	/**
	 * @notice Allows the address of the asset to be accepted by this contract by the currency type. This method is only called by admins.
	 * @notice This method may be deprecated or refactored to allow for multiple interfaces
	 * @param  asset Ethereum address of the ERC20 compliant smart contract to allow the swap
	 * @param  currency string Currency symbol of the token (e.g. `USD`, `EUR`, `GBP`, `JPY`, `AUD`, `CAD`, `CHF`, `NOK`, `NZD`, `SEK`)
	 * @return {"success": "Return boolean success if able to set the allowed asset"}
	 */
	function isAllowedAsset(address asset, string currency) public view returns (bool allowed) {
		if (isTokenXContract(asset, currency)) {
			return true;
		} else {
			bytes32 id = keccak256(abi.encodePacked('allowed.stable.asset', asset, currency));
			return lib.Storage.getBool(id);
		}
	}

	function setTokenXCurrency(address asset, string currency) public onlyOwner returns (bool success) {
		bytes32 id = keccak256(abi.encodePacked('tokenx', asset, currency));
    require(
      lib.Storage.setBool(id, true),
      "Error: Unable to set storage value. Please ensure contract interface is allowed by the storage contract."
    );
		return true;
	}

	function isTokenXContract(address asset, string currency) public view returns (bool isX) {
		bytes32 id = keccak256(abi.encodePacked('tokenx', asset, currency));
		return lib.Storage.getBool(id);
	}

	function convert(address fromAsset, address toAsset, uint amount, string currency) public returns (bool success) {
		/// @dev Ensure assets are allowed to be swapped;
		require(isAllowedAsset(fromAsset, currency), 'Unsupported asset requested. Asset must be supported by this contract and have a currency of `USD`, `EUR`, `GBP`, `JPY`, `AUD`, `CAD`, `CHF`, `NOK`, `NZD`, `SEK` .');
		require(isAllowedAsset(toAsset, currency), 'Unsupported asset requested. Asset must be supported by this contract and have a currency of `USD`, `EUR`, `GBP`, `JPY`, `AUD`, `CAD`, `CHF`, `NOK`, `NZD`, `SEK` .');


		/// @dev require one of the assets be equal to Token X asset;
		if (isTokenXContract(toAsset, currency)) {
			/// @notice This requires the erc20 transfer function to return a boolean result of true;
			require(
				ERC20Interface(fromAsset).transferFrom(msg.sender, address(this), amount),
				/* fromAsset.call(bytes4(keccak256("transferFrom(address, address, uint256)")), msg.sender, address(this), amount), */
				'Unable to transferFrom your asset holdings. Please ensure this contract has an approved allowance equal to or greater than the amount called in transferFrom method.'
			);

			/// @dev Deposit TokenX asset to the user;

			require(
				lib.deposit(lib.getTokenSymbol(toAsset), msg.sender, amount, 'Token, Inc.'),
				"Error: Unable to deposit funds. Please check issuerFirm and firm authority are registered"
			);
			return true;
		} else if(isTokenXContract(fromAsset, currency)) {
			///@dev Transfer the asset to the user;
			require(
				ERC20Interface(toAsset).transfer(msg.sender, amount),
				'Unable to call the requested erc20 contract.'
			);

			/// @dev Withdraw TokenX asset from the user
			require(
				lib.withdraw(lib.getTokenSymbol(fromAsset), msg.sender, amount, 'Token, Inc.'),
				"Error: Unable to withdraw funds. Please check issuerFirm and firm authority are registered and have issued funds that can be withdrawn"
			);
			return true;
		} else {
			revert('BAD_REQUEST: AT LEAST ONE ASSET REQUESTED MUST BE ISSUED BY TOKEN, INC. (TOKEN X)');
		}
	}

	/**
	* @notice gets currency status of contract
	* @return {"deprecated" : "Returns true if deprecated, false otherwise"}
	*/
	function deprecateInterface() public onlyOwner returns (bool deprecated) {
		require(lib.setDeprecatedContract(address(this)),
			"Error: Unable to deprecate contract!");
		return true;
	}

	modifier notDeprecated() {
		/// @notice throws if contract is deprecated
		require(!lib.isContractDeprecated(address(this)),
			"Error: Contract has been deprecated, cannot perform operation!");
		_;
	}


}
