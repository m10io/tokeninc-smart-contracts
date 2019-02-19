pragma solidity 0.5.2;

import "./Ownable.sol";

interface TokenIONameSpaceI {
  function getTokenNameSpace(string calldata currency) external view returns (address contractAddress);
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
