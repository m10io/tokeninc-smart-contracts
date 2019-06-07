pragma solidity 0.5.2;

import "./Ownable.sol";
import "./TokenIOLib.sol";
import "./TokenIOStorage.sol";


interface TokenIOFXProxyI {
  function swap(address requester, string calldata symbolA, string calldata symbolB, uint valueA, uint valueB, uint8 sigV, bytes32 sigR, bytes32 sigS, uint expiration, address sender) external returns (bool success);
}

contract TokenIOFXProxy is Ownable {

  address implementationInstance;

	constructor(address _tokenIOFx) public {
			implementationInstance = _tokenIOFx;
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

  function swap(
    address requester,
    string memory symbolA,
    string memory symbolB,
    uint valueA,
    uint valueB,
    uint8 sigV,
    bytes32 sigR,
    bytes32 sigS,
    uint expiration
  ) public returns (bool success) {
    require(
      TokenIOFXProxyI(implementationInstance).swap(requester, symbolA, symbolB, valueA, valueB, sigV, sigR, sigS, expiration, msg.sender),
      "Error: Unable to perform atomic currency swap. Please check parameters."
    );
    return true;
  }

}
