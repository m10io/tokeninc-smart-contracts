pragma solidity 0.5.2;

import "./Ownable.sol";

interface TokenIONameSpaceI {
  function getTokenNameSpace(string calldata currency) external view returns (address contractAddress);
}

contract TokenIONameSpaceProxy is Ownable {

    address implementationInstance;

    constructor(address _tokenIONameSpaceImpl) public {
      implementationInstance = _tokenIONameSpaceImpl;
    }

    function staticCall(bytes calldata payload) external view returns(bytes memory) {
      (bool res, bytes memory result) = implementationInstance.staticcall(payload);
      return result;
    }

    function call(bytes calldata payload) external {
      (bool res, bytes memory result) = implementationInstance.call(payload);
      require(res);
    }

    function upgradeTo(address _newImplementationInstance) onlyOwner external {
      require(_newImplementationInstance != address(0));
      implementationInstance = _newImplementationInstance;
    }
  
    function getTokenNameSpace(string memory currency) public view returns (address contractAddress) {
        return TokenIONameSpaceI(implementationInstance).getTokenNameSpace(currency);
    }
}
