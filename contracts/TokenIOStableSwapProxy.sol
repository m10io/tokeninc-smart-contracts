pragma solidity 0.5.2;

import "./Ownable.sol";

interface TokenIOStableSwapI {
  function allowAsset(address asset, string calldata currency, uint feeBps, uint feeMin, uint feeMax, uint feeFlat) external returns (bool success);

  function removeAsset(address asset) external returns (bool success);

  function isAllowedAsset(address asset, string calldata currency) external view returns (bool allowed);

  function setAssetCurrency(address asset, string calldata currency) external returns (bool success);

  function getAssetCurrency(address asset) external view returns (string memory currency);

  function setTokenXCurrency(address asset, string calldata currency) external returns (bool success);

  function isTokenXContract(address asset, string calldata currency) external view returns (bool isX);

  function setAssetFeeParams(address asset, uint feeBps, uint feeMin, uint feeMax, uint feeFlat) external returns (bool success);

  function calcAssetFees(address asset, uint amount) external view returns (uint fees);

  function convert(address fromAsset, address toAsset, uint amount, address sender) external returns (bool success);

  function transferCollectedFees(address asset, address to, uint amount) external returns (bool success);

  function deprecateInterface() external returns (bool deprecated);
}

contract TokenIOStableSwapProxy is Ownable {

  TokenIOStableSwapI tokenIOStableSwapImpl;

  constructor(address _tokenIOStableSwapImpl) public {
    tokenIOStableSwapImpl = TokenIOStableSwapI(_tokenIOStableSwapImpl);
  }

  function upgradeTokenImplamintation(address _newTokenIOStableSwapImpl) onlyOwner external {
    require(_newTokenIOStableSwapImpl != address(0));
    tokenIOStableSwapImpl = TokenIOStableSwapI(_newTokenIOStableSwapImpl);
  }

  function allowAsset(address asset, string memory currency, uint feeBps, uint feeMin, uint feeMax, uint feeFlat) public onlyOwner returns (bool success) {
    require(
      tokenIOStableSwapImpl.allowAsset(asset, currency, feeBps, feeMin, feeMax, feeFlat),
      "Unable to execute allowAsset"
    );

    return true;
  }

  function removeAsset(address asset) public onlyOwner returns (bool success) {
    require(
      tokenIOStableSwapImpl.removeAsset(asset),
      "Unable to execute removeAsset"
    );

    return true;
  }

  /**
   * @notice Return boolean if the asset is an allowed stable asset for the corresponding currency
   * @param  asset Ethereum address of the ERC20 compliant smart contract to check allowed status of
   * @param  currency string Currency symbol of the token (e.g. `USD`, `EUR`, `GBP`, `JPY`, `AUD`, `CAD`, `CHF`, `NOK`, `NZD`, `SEK`)
   * @return {"allowed": "Returns true if the asset is allowed"}
   */
  function isAllowedAsset(address asset, string memory currency) public view returns (bool allowed) {
      return tokenIOStableSwapImpl.isAllowedAsset(asset, currency);
  }

  /**
   * Set the Three Letter Abbrevation for the currency associated to the asset
   * @param asset Ethereum address of the asset to set the currency for
   * @param currency string Currency of the asset (NOTE: This is the currency for the asset)
   * @return { "success" : "Returns true if successfully called from another contract"}
   */
  function setAssetCurrency(address asset, string memory currency) public onlyOwner returns (bool success) {
    require(
      tokenIOStableSwapImpl.setAssetCurrency(asset, currency),
      "Unable to execute setAssetCurrency"
    );

    return true;
  }

  /**
   * Get the Currency for an associated asset;
   * @param asset Ethereum address of the asset to get the currency for
   * @return {"currency": "Returns the Currency of the asset if the asset has been allowed."}
   */
  function getAssetCurrency(address asset) public view returns (string memory currency) {
    return tokenIOStableSwapImpl.getAssetCurrency(asset);
  }

  /**
   * @notice Register the address of the asset as a Token X asset for a specific currency
   * @notice This method may be deprecated or refactored to allow for multiple interfaces
   * @param  asset Ethereum address of the ERC20 compliant Token X asset
   * @param  currency string Currency symbol of the token (e.g. `USD`, `EUR`, `GBP`, `JPY`, `AUD`, `CAD`, `CHF`, `NOK`, `NZD`, `SEK`)
   * @return { "success" : "Returns true if successfully called from another contract"}
   */
  function setTokenXCurrency(address asset, string memory currency) public onlyOwner returns (bool success) {
    require(
      tokenIOStableSwapImpl.setTokenXCurrency(asset, currency),
      "Unable to execute setTokenXCurrency"
    );

    return true;
  }

  /**
    * @notice Return boolean if the asset is a registered Token X asset for the corresponding currency
    * @param  asset Ethereum address of the asset to check if is a registered Token X stable coin asset
    * @param  currency string Currency symbol of the token (e.g. `USD`, `EUR`, `GBP`, `JPY`, `AUD`, `CAD`, `CHF`, `NOK`, `NZD`, `SEK`)
    * @return {"allowed": "Returns true if the asset is allowed"}
   */
  function isTokenXContract(address asset, string memory currency) public view returns (bool isX) {
    return tokenIOStableSwapImpl.isTokenXContract(asset, currency);
  }

  /**
   * @notice Set BPS, Min, Max, and Flat fee params for asset
   * @param asset Ethereum address of the asset to set fees for.
   * @param feeBps Basis points Swap Fee
   * @param feeMin Minimum Swap Fees
   * @param feeMax Maximum Swap Fee
   * @param feeFlat Flat Swap Fee
   * @return { "success" : "Returns true if successfully called from another contract"}
   */
  function setAssetFeeParams(address asset, uint feeBps, uint feeMin, uint feeMax, uint feeFlat) public onlyOwner returns (bool success) {
    require(tokenIOStableSwapImpl.setAssetFeeParams(asset, feeMax, feeMin, feeBps, feeFlat), "Unable to execute setAssetFeeParams");

    return true;
  }

  /**
   * [calcAssetFees description]
   * @param  asset Ethereum address of the asset to calculate fees based on
   * @param  amount Amount to calculate fees on
   * @return { "fees" : "Returns the fees for the amount associated with the asset contract"}
   */
  function calcAssetFees(address asset, uint amount) public view returns (uint fees) {
    return tokenIOStableSwapImpl.calcAssetFees(asset, amount);
  }

  /**
    * @notice Return boolean if the asset is a registered Token X asset for the corresponding currency
    * @notice Amounts will always be passed in according to the decimal representation of the `fromAsset` token;
    * @param  fromAsset Ethereum address of the asset with allowance for this contract to transfer and
    * @param  toAsset Ethereum address of the asset to check if is a registered Token X stable coin asset
    * @param  amount Amount of fromAsset to be transferred.
    * @return { "success" : "Returns true if successfully called from another contract"}
   */
  function convert(address fromAsset, address toAsset, uint amount) public returns (bool success) {
    require(tokenIOStableSwapImpl.convert(fromAsset, toAsset, amount, msg.sender), 'Unable to execute convert');
    
    return true;
  }

  /**
   * Allow this contract to transfer collected fees to another contract;
   * @param  asset Ethereum address of asset to transfer
   * @param  to Transfer collected fees to the following account;
   * @param  amount Amount of fromAsset to be transferred.
   * @return { "success" : "Returns true if successfully called from another contract"}
   */
  function transferCollectedFees(address asset, address to, uint amount) public onlyOwner returns (bool success) {
    require(tokenIOStableSwapImpl.transferCollectedFees(asset, to, amount), "Unable to execute convert");

    return true;
  }

  /**
  * @notice gets currency status of contract
  * @return {"deprecated" : "Returns true if deprecated, false otherwise"}
  */
  function deprecateInterface() public onlyOwner returns (bool deprecated) {
    require(tokenIOStableSwapImpl.deprecateInterface(),
      "Error: Unable to deprecate contract!");
    return true;
  }

}
