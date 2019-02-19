pragma solidity 0.5.2;

import "./Ownable.sol";

interface TokenIONameSpaceI {
  function setParams(address feeContract) public returns (bool success);

  function getFeeParams() public view returns (uint bps, uint min, uint max, uint flat, bytes memory feeMsg, address feeAccount);

  function calculateFees(uint amount) public view returns (uint fees);

  function pay(string memory currency, address merchant, uint amount, bool merchantPaysFees, bytes memory data) public returns (bool success);
}

contract TokenIONameSpaceProxy is Ownable {

    TokenIONameSpaceI tokenIONameSpaceImpl;

    constructor(address _tokenIONameSpaceImpl) public {
      tokenIONameSpaceImpl = TokenIONameSpaceI(_tokenIONameSpaceImpl);
    }

    function upgradeTokenImplamintation(address _newTokenIONameSpaceImpl) onlyOwner external {
      require(_newTokenIONameSpaceImpl != address(0));
      tokenIONameSpaceImpl = TokenIONameSpaceI(_newTokenIONameSpaceImpl);
    }
  
    function getTokenNameSpace(string memory currency) public view returns (address contractAddress) {
        return tokenIONameSpaceImpl.getTokenNameSpace(currency);
    }
}
