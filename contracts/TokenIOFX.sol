pragma solidity 0.4.24;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";
import "./TokenIOLib.sol";
import "./TokenIOStorage.sol";

contract TokenIOFX is Ownable {

  using TokenIOLib for TokenIOLib.Data;
  TokenIOLib.Data lib;


  constructor(address _storageContract) public {
      // Set the storage contract for the interface
      // This contract will be unable to use the storage constract until
      // contract address is authorized with the storage contract
      // Once authorized, Use the `init` method to set storage values;
      lib.Storage = TokenIOStorage(_storageContract);

      owner[msg.sender] = true;

  }

  function swap(
    address requester,
    string symbolA,
    string symbolB,
    uint valueA,
    uint valueB,
    uint8 sigV,
    bytes32 sigR,
    bytes32 sigS,
    uint expiration,
    bytes32 fxTxHash
  ) public returns (bool) {
    require(lib.execSwap(requester, symbolA, symbolB, valueA, valueB, sigV, sigR, sigS, expiration, fxTxHash));
    return true;
  }

}
