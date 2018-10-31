pragma solidity 0.4.24;

import "./Ownable.sol";
import "./SafeMath.sol";
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
  /// @dev use safe math operations
  using SafeMath for uint;

  //// @dev Set reference to TokenIOLib interface which proxies to TokenIOStorage
  using TokenIOLib for TokenIOLib.Data;
  TokenIOLib.Data lib;

  event StableSwap(address fromAsset, address toAsset, address requestedBy, uint amount, string currency);
  event TransferredHoldings(address asset, address to, uint amount);
  event AllowedERC20Asset(address asset, string currency);

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
	 * @return { "success" : "Returns true if successfully called from another contract"}
	 */
	function allowAsset(address asset, string currency) public onlyOwner notDeprecated returns (bool success) {
		bytes32 id = keccak256(abi.encodePacked('allowed.stable.asset', asset, currency));
    require(
      lib.Storage.setBool(id, true),
      "Error: Unable to set storage value. Please ensure contract interface is allowed by the storage contract."
    );

    /// @notice set TLA for the asset;
    require(setAssetTLA(asset, currency));

    /// @dev Log Allow ERC20 Asset
    emit AllowedERC20Asset(asset, currency);
		return true;
	}

	/**
	 * @notice Return boolean if the asset is an allowed stable asset for the corresponding currency
	 * @param  asset Ethereum address of the ERC20 compliant smart contract to check allowed status of
	 * @param  currency string Currency symbol of the token (e.g. `USD`, `EUR`, `GBP`, `JPY`, `AUD`, `CAD`, `CHF`, `NOK`, `NZD`, `SEK`)
	 * @return {"allowed": "Returns true if the asset is allowed"}
	 */
	function isAllowedAsset(address asset, string currency) public view returns (bool allowed) {
		if (isTokenXContract(asset, currency)) {
			return true;
		} else {
			bytes32 id = keccak256(abi.encodePacked('allowed.stable.asset', asset, currency));
			return lib.Storage.getBool(id);
		}
	}

  /**
   * Set the Three Letter Abbrevation for the currency associated to the asset
   * @param asset Ethereum address of the asset to set the currency for
   * @param currency string TLA of the asset
   * @return { "success" : "Returns true if successfully called from another contract"}
   */
  function setAssetTLA(address asset, string currency) public onlyOwner returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('asset.tla', asset));
    require(
      lib.Storage.setString(id, currency),
      "Error: Unable to set storage value. Please ensure contract interface is allowed by the storage contract."
    );
    return true;
  }

  /**
   * Get the TLA for an associated asset;
   * @param asset Ethereum address of the asset to get the currency for
   * @return {"tla": "Returns the TLA of the asset if the asset has been allowed."}
   */
  function getAssetTLA(address asset) public view returns (string tla) {
    bytes32 id = keccak256(abi.encodePacked('asset.tla', asset));
    return lib.Storage.getString(id);
  }

  /**
	 * @notice Register the address of the asset as a Token X asset for a specific currency
	 * @notice This method may be deprecated or refactored to allow for multiple interfaces
	 * @param  asset Ethereum address of the ERC20 compliant Token X asset
	 * @param  currency string Currency symbol of the token (e.g. `USD`, `EUR`, `GBP`, `JPY`, `AUD`, `CAD`, `CHF`, `NOK`, `NZD`, `SEK`)
	 * @return { "success" : "Returns true if successfully called from another contract"}
	 */
	function setTokenXCurrency(address asset, string currency) public onlyOwner notDeprecated returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('tokenx', asset, currency));
    require(
      lib.Storage.setBool(id, true),
      "Error: Unable to set storage value. Please ensure contract interface is allowed by the storage contract."
    );

    /// @notice set TLA for the asset;
    require(setAssetTLA(asset, currency));

    return true;
	}

  /**
    * @notice Return boolean if the asset is a registered Token X asset for the corresponding currency
    * @param  asset Ethereum address of the asset to check if is a registered Token X stable coin asset
    * @param  currency string Currency symbol of the token (e.g. `USD`, `EUR`, `GBP`, `JPY`, `AUD`, `CAD`, `CHF`, `NOK`, `NZD`, `SEK`)
    * @return {"allowed": "Returns true if the asset is allowed"}
   */
	function isTokenXContract(address asset, string currency) public view returns (bool isX) {
		bytes32 id = keccak256(abi.encodePacked('tokenx', asset, currency));
		return lib.Storage.getBool(id);
	}

  /**
   * @notice Set BPS, Min, Max, and Flat fee params for asset
   * @param asset Ethereum address of the asset to set fees for.
   * @param feeBps Basis points transaction fee
	 * @param feeMin Minimum transaction fees
	 * @param feeMax Maximum transaction fee
	 * @param feeFlat Flat transaction fee
	 * @return { "success" : "Returns true if successfully called from another contract"}
   */
  function setAssetFeeParams(address asset, uint feeBps, uint feeMin, uint feeMax, uint feeFlat) public onlyOwner notDeprecated returns (bool success) {
    /// @dev This method bypasses the setFee library methods and directly sets the fee params for a requested asset.
    /// @notice Fees can be different per asset. Some assets may have different liquidity requirements.
    require(lib.Storage.setUint(keccak256(abi.encodePacked('fee.max', asset)), feeMax),
      'Error: Failed to set fee parameters with storage contract. Please check permissions.');

    require(lib.Storage.setUint(keccak256(abi.encodePacked('fee.min', asset)), feeMin),
      'Error: Failed to set fee parameters with storage contract. Please check permissions.');

    require(lib.Storage.setUint(keccak256(abi.encodePacked('fee.bps', asset)), feeBps),
      'Error: Failed to set fee parameters with storage contract. Please check permissions.');

    require(lib.Storage.setUint(keccak256(abi.encodePacked('fee.flat', asset)), feeFlat),
      'Error: Failed to set fee parameters with storage contract. Please check permissions.');

    return true;
  }

  /**
   * [calcAssetFees description]
   * @param  asset Ethereum address of the asset to calculate fees based on
   * @param  amount Amount to calculate fees on
   * @return { "fees" : "Returns the fees for the amount associated with the asset contract"}
   */
  function calcAssetFees(address asset, uint amount) public view returns (uint fees) {
    return lib.calculateFees(asset, amount);
  }

  /**
    * @notice Return boolean if the asset is a registered Token X asset for the corresponding currency
    * @notice Amounts will always be passed in according to the decimal representation of the `fromAsset` token;
    * @param  fromAsset Ethereum address of the asset with allowance for this contract to transfer and
    * @param  toAsset Ethereum address of the asset to check if is a registered Token X stable coin asset
    * @param  amount Amount of fromAsset to be transferred.
    * @return { "success" : "Returns true if successfully called from another contract"}
   */
	function convert(address fromAsset, address toAsset, uint amount) public notDeprecated returns (bool success) {
    /// @notice lookup currency from one of the assets, check if allowed by both assets.
    string memory currency = getAssetTLA(fromAsset);
    uint fromDecimals = ERC20Interface(fromAsset).decimals();
    uint toDecimals = ERC20Interface(toAsset).decimals();

    /// @dev Ensure assets are allowed to be swapped;
		require(isAllowedAsset(fromAsset, currency), 'Error: Unsupported asset requested. Asset must be supported by this contract and have a currency of `USD`, `EUR`, `GBP`, `JPY`, `AUD`, `CAD`, `CHF`, `NOK`, `NZD`, `SEK` .');
		require(isAllowedAsset(toAsset, currency), 'Error: Unsupported asset requested. Asset must be supported by this contract and have a currency of `USD`, `EUR`, `GBP`, `JPY`, `AUD`, `CAD`, `CHF`, `NOK`, `NZD`, `SEK` .');


		/// @dev require one of the assets be equal to Token X asset;
		if (isTokenXContract(toAsset, currency)) {
      /// @notice This requires the erc20 transfer function to return a boolean result of true;
      /// @dev the amount being transferred must be in the same decimal representation of the asset
      /// e.g. If decimals = 6 and want to transfer $100.00 the amount passed to this contract should be 100e6 (100 * 10 ** 6)
      require(
        ERC20Interface(fromAsset).transferFrom(msg.sender, address(this), amount),
        'Error: Unable to transferFrom your asset holdings. Please ensure this contract has an approved allowance equal to or greater than the amount called in transferFrom method.'
      );

      /// @dev Deposit TokenX asset to the user;
      /// @notice Amount received from deposit is net of fees.
      uint netAmountFrom = amount.sub(calcAssetFees(fromAsset, amount));
      /// @dev Ensure amount is converted for the correct decimal representation;
      uint convertedAmountFrom = (netAmountFrom.mul(10**toDecimals)).div(10**fromDecimals);
      require(
        lib.deposit(lib.getTokenSymbol(toAsset), msg.sender, convertedAmountFrom, 'Token, Inc.'),
        "Error: Unable to deposit funds. Please check issuerFirm and firm authority are registered"
      );
		} else if(isTokenXContract(fromAsset, currency)) {
      ///@dev Transfer the asset to the user;
      /// @notice Amount received from withdraw is net of fees.
      uint netAmountTo = amount.sub(calcAssetFees(toAsset, amount));
      /// @dev Ensure amount is converted for the correct decimal representation;
      uint convertedAmountTo = (netAmountTo.mul(10**fromDecimals)).div(10**toDecimals);
      require(
      	ERC20Interface(toAsset).transfer(msg.sender, convertedAmountTo),
      	'Unable to call the requested erc20 contract.'
      );

      /// @dev Withdraw TokenX asset from the user
      require(
      	lib.withdraw(lib.getTokenSymbol(fromAsset), msg.sender, amount, 'Token, Inc.'),
      	"Error: Unable to withdraw funds. Please check issuerFirm and firm authority are registered and have issued funds that can be withdrawn"
      );
		} else {
        revert('Error: At least one asset must be issued by Token, Inc. (Token X).');
		}

    /// @dev Log the swap event for event listeners
    emit StableSwap(fromAsset, toAsset, msg.sender, amount, currency);
    return true;
	}

  /**
   * Allow this contract to transfer collected fees to another contract;
   * @param  asset Ethereum address of asset to transfer
   * @param  to Transfer collected fees to the following account;
   * @param  amount Amount of fromAsset to be transferred.
   * @return { "success" : "Returns true if successfully called from another contract"}
   */
  function transferCollectedFees(address asset, address to, uint amount) public onlyOwner notDeprecated returns (bool success) {
		require(
			ERC20Interface(asset).transfer(to, amount),
			"Error: Unable to transfer fees to account."
		);
    emit TransferredHoldings(asset, to, amount);
		return true;
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
