pragma solidity 0.4.24;


import "./SafeMath.sol";
import "./TokenIOStorage.sol";

contract TokenIOExchange {

  using SafeMath for uint;

  mapping(string => address) storageContracts;
  mapping(bytes32 => bool) confirmed;
  mapping(address => bool) owners;

  event LogExchange(
    string tokenASymbol,
    string tokenBSymbol,
    uint tokenAValue,
    uint tokenBValue,
    bytes32 transactionHash
  );

  constructor(address owner) {
    // Set owner of the exchange
    owners[owner] = true;
  }

  function addTokenStorageContract(string tokenSymbol, address storageContract) public returns(bool) {
    // Only accessible to owner;
    require(owners[msg.sender]);

    storageContracts[tokenSymbol] = storageContract;

    return true;
  }

  function executeTransaction(
    address fulfiller,
    string tokenASymbol,
    string tokenBSymbol,
    uint tokenAValue,
    uint tokenBValue,
    uint expiration,
    bytes32 transactionHash, // keccak256(requester, fulfiller, tokenASymbol, tokenBSymbol, tokenAValue, tokenBValue, expiration)
    uint8 receiverSignatureV,
    bytes32 receiverSignatureR,
    bytes32 receiverSignatureS
  ) public returns (bool) {

    // Ensure transaction has not yet been used;
    require(!confirmed[transactionHash]);

    // Ensure contract has not yet expired;
    require(expiration >= now);

    // Ensure fulfiller has authorized this transaction
    require(ecrecover(
        transactionHash,
        receiverSignatureV,
        receiverSignatureR,
        receiverSignatureS
    ) == fulfiller);

    TokenIOStorage storageA = TokenIOStorage(storageContracts[tokenASymbol]);
    TokenIOStorage storageB = TokenIOStorage(storageContracts[tokenBSymbol]);

    // Ensure storage contracts have been set with exchange contract and are not null;
    require(address(storageA) != 0x0 && address(storageB) != 0x0);

    bytes32 requesterId = keccak256('balance', msg.sender);
    bytes32 fulfillerId = keccak256('balance', fulfiller);

    // Update balances for tokenA
    // NOTE: transaction will fail if the balance for the account is insufficient (SafeMath)

    // Decrease Requester balance of tokenA;
    require(storageA.setUint(requesterId, storageA.getUint(requesterId).sub(tokenAValue)));

    // Increase Fulfiller balance of tokenB
    require(storageA.setUint(fulfillerId, storageA.getUint(fulfillerId).add(tokenAValue)));

    // Update balances for tokenB

    // Increase Requester balance of tokenB
    require(storageB.setUint(requesterId, storageB.getUint(requesterId).add(tokenBValue)));

    // Decrease Fulfiller balance of tokenB
    require(storageB.setUint(fulfillerId, storageB.getUint(fulfillerId).sub(tokenBValue)));

    // Ensure transaction cannot be replayed
    confirmed[transactionHash] = true;

    // Log Event to generate price history
    emit LogExchange(
      tokenASymbol,
      tokenBSymbol,
      tokenAValue,
      tokenBValue,
      transactionHash
    );

    // Finally, return true if the transaction is successful
    return true;

  }

}
