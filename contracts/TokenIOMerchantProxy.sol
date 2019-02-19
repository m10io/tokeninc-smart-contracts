pragma solidity 0.5.2;

import "./Ownable.sol";

interface TokenIOFeeContractI {
  function setParams(address feeContract) public returns (bool success);

  function getFeeParams() public view returns (uint bps, uint min, uint max, uint flat, bytes memory feeMsg, address feeAccount);

  function calculateFees(uint amount) public view returns (uint fees);

  function pay(string memory currency, address merchant, uint amount, bool merchantPaysFees, bytes memory data) public returns (bool success);
}

contract TokenIOAuthorityProxy is Ownable {

    TokenIOAuthorityI tokenIOAuthorityImpl;

    constructor(address _tokenIOAuthorityImpl) public {
      tokenIOAuthorityImpl = TokenIOFeeContractI(_tokenIOAuthorityImpl);
    }

    function upgradeTokenImplamintation(address _newTokenIOAuthorityImpl) onlyOwner external {
      require(_newTokenIOAuthorityImpl != address(0));
      tokenIOAuthorityImpl = TokenIOFeeContractI(_newTokenIOAuthorityImpl);
    }
  
    function setParams(address feeContract) public onlyOwner returns (bool success) {
      require(tokenIOAuthorityImpl.setParams(feeContract),
        "Unable to execute setParams");
      
      return true;
    }

    function getFeeParams() public view returns (uint bps, uint min, uint max, uint flat, bytes memory feeMsg, address feeAccount) {
      return tokenIOAuthorityImpl.getFeeParams();
    }

    function calculateFees(uint amount) public view returns (uint fees) {
      return tokenIOAuthorityImpl.calculateFees(amount);
    }

    function pay(string memory currency, address merchant, uint amount, bool merchantPaysFees, bytes memory data) public returns (bool success) {
      require(tokenIOAuthorityImpl.pay(currency, merchant, amount, merchantPaysFees, data, msg.sender),
        "Unable to execute pay");

      return true;
    }

}
