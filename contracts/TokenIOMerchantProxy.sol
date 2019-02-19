pragma solidity 0.5.2;

import "./Ownable.sol";

interface TokenIOMerchantI {
  function setParams(address feeContract) external returns (bool success);

  function getFeeParams() external view returns (uint bps, uint min, uint max, uint flat, bytes memory feeMsg, address feeAccount);

  function calculateFees(uint amount) external view returns (uint fees);

  function pay(string calldata currency, address merchant, uint amount, bool merchantPaysFees, bytes calldata data, address sender) external returns (bool success);
}

contract TokenIOMerchantProxy is Ownable {

    TokenIOMerchantI tokenIOMerchantImpl;

    constructor(address _tokenIOMerchantImpl) public {
      tokenIOMerchantImpl = TokenIOMerchantI(_tokenIOMerchantImpl);
    }

    function upgradeTokenImplamintation(address _newTokenIOMerchantImpl) onlyOwner external {
      require(_newTokenIOMerchantImpl != address(0));
      tokenIOMerchantImpl = TokenIOMerchantI(_newTokenIOMerchantImpl);
    }
  
    function setParams(address feeContract) public onlyOwner returns (bool success) {
      require(tokenIOMerchantImpl.setParams(feeContract),
        "Unable to execute setParams");
      
      return true;
    }

    function getFeeParams() public view returns (uint bps, uint min, uint max, uint flat, bytes memory feeMsg, address feeAccount) {
      return tokenIOMerchantImpl.getFeeParams();
    }

    function calculateFees(uint amount) public view returns (uint fees) {
      return tokenIOMerchantImpl.calculateFees(amount);
    }

    function pay(string memory currency, address merchant, uint amount, bool merchantPaysFees, bytes memory data) public returns (bool success) {
      require(tokenIOMerchantImpl.pay(currency, merchant, amount, merchantPaysFees, data, msg.sender),
        "Unable to execute pay");

      return true;
    }

}
