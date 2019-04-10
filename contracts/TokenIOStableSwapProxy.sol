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

  address implementationInstance;

  constructor(address _tokenIOStableSwapImpl) public {
    implementationInstance = _tokenIOStableSwapImpl;
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

  /**
   * @notice Return boolean if the asset is an allowed stable asset for the corresponding currency
   * @param  asset Ethereum address of the ERC20 compliant smart contract to check allowed status of
   * @param  currency string Currency symbol of the token (e.g. `USD`, `EUR`, `GBP`, `JPY`, `AUD`, `CAD`, `CHF`, `NOK`, `NZD`, `SEK`)
   * @return {"allowed": "Returns true if the asset is allowed"}
   */
  function isAllowedAsset(address asset, string memory currency) public view returns (bool allowed) {
      return TokenIOStableSwapI(implementationInstance).isAllowedAsset(asset, currency);
  }

  /**
   * Get the Currency for an associated asset;
   * @param asset Ethereum address of the asset to get the currency for
   * @return {"currency": "Returns the Currency of the asset if the asset has been allowed."}
   */
  function getAssetCurrency(address asset) public view returns (string memory currency) {
    return TokenIOStableSwapI(implementationInstance).getAssetCurrency(asset);
  }

  /**
    * @notice Return boolean if the asset is a registered Token X asset for the corresponding currency
    * @param  asset Ethereum address of the asset to check if is a registered Token X stable coin asset
    * @param  currency string Currency symbol of the token (e.g. `USD`, `EUR`, `GBP`, `JPY`, `AUD`, `CAD`, `CHF`, `NOK`, `NZD`, `SEK`)
    * @return {"allowed": "Returns true if the asset is allowed"}
   */
  function isTokenXContract(address asset, string memory currency) public view returns (bool isX) {
    return TokenIOStableSwapI(implementationInstance).isTokenXContract(asset, currency);
  }

  /**
   * [calcAssetFees description]
   * @param  asset Ethereum address of the asset to calculate fees based on
   * @param  amount Amount to calculate fees on
   * @return { "fees" : "Returns the fees for the amount associated with the asset contract"}
   */
  function calcAssetFees(address asset, uint amount) public view returns (uint fees) {
    return TokenIOStableSwapI(implementationInstance).calcAssetFees(asset, amount);
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
    require(TokenIOStableSwapI(implementationInstance).convert(fromAsset, toAsset, amount, msg.sender), 'Unable to execute convert');
    
    return true;
  }

}
