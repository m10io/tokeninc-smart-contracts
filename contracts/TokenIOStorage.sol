pragma solidity 0.4.23;

// NOTE: This contract is inspired by the RocketPool Storage Contract,
// found here: https://github.com/rocket-pool/rocketpool/blob/master/contracts/RocketStorage.sol
// And this medium article: https://medium.com/rocket-pool/upgradable-solidity-contract-design-54789205276d

contract TokenIOStorage {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // Mappings for Primitive Data Types
    //
    mapping(bytes32 => uint256)    private uIntStorage;
    mapping(bytes32 => string)     private stringStorage;
    mapping(bytes32 => address)    private addressStorage;
    mapping(bytes32 => bytes)      private bytesStorage;
    mapping(bytes32 => bool)       private boolStorage;
    mapping(bytes32 => int256)     private intStorage;

    constructor() public {
        // Ensure msg.sender / admin has ability to set values in the storage
        // contract directly.
        boolStorage[keccak256('owner', msg.sender)] = true;
    }

    // Set Methods
    function setAddress(bytes32 _key, address _value) public onlyPermissioned returns (bool) {
        addressStorage[_key] = _value;
        return true;
    }

    function setUint(bytes32 _key, uint _value) public onlyPermissioned returns (bool) {
        uIntStorage[_key] = _value;
        return true;
    }

    function setString(bytes32 _key, string _value) public onlyPermissioned returns (bool) {
        stringStorage[_key] = _value;
        return true;
    }

    function setBytes(bytes32 _key, bytes _value) public onlyPermissioned returns (bool) {
        bytesStorage[_key] = _value;
        return true;
    }

    function setBool(bytes32 _key, bool _value) public onlyPermissioned returns (bool) {
        boolStorage[_key] = _value;
        return true;
    }

    function setInt(bytes32 _key, int _value) public onlyPermissioned returns (bool) {
        intStorage[_key] = _value;
        return true;
    }

    // Delete Methods
    function deleteAddress(bytes32 _key) public onlyPermissioned returns (bool) {
        delete addressStorage[_key];
        return true;
    }

    function deleteUint(bytes32 _key) public onlyPermissioned returns (bool) {
        delete uIntStorage[_key];
        return true;
    }

    function deleteString(bytes32 _key) public onlyPermissioned returns (bool) {
        delete stringStorage[_key];
        return true;
    }

    function deleteBytes(bytes32 _key) public onlyPermissioned returns (bool) {
        delete bytesStorage[_key];
        return true;
    }

    function deleteBool(bytes32 _key) public onlyPermissioned returns (bool) {
        delete boolStorage[_key];
        return true;
    }

    function deleteInt(bytes32 _key) public onlyPermissioned returns (bool) {
        delete intStorage[_key];
        return true;
    }

    // Get Methods
    function getAddress(bytes32 _key) public view returns (address) {
        return addressStorage[_key];
    }

    function getUint(bytes32 _key) public view returns (uint) {
        return uIntStorage[_key];
    }

    function getString(bytes32 _key) public view returns (string) {
        return stringStorage[_key];
    }

    function getBytes(bytes32 _key) public view returns (bytes) {
        return bytesStorage[_key];
    }

    function getBool(bytes32 _key) public view returns (bool) {
        return boolStorage[_key];
    }

    function getInt(bytes32 _key) public view returns (int) {
        return intStorage[_key];
    }

    function transferOwnership(address newOwner) public onlyOwner returns (bool) {
        require(newOwner != address(0));
        emit OwnershipTransferred(msg.sender, newOwner);
        // Add new owner to contract;
        boolStorage[keccak256('owner', newOwner)] = true;
        // Remove existing owner from list;
        boolStorage[keccak256('owner', msg.sender)] = false;

        return true;
    }

    modifier onlyOwner() {
        require(boolStorage[keccak256('owner', msg.sender)]);
        _;
    }

    modifier onlyPermissioned() {
      require(
        boolStorage[keccak256('owner', msg.sender)] ||
        uIntStorage[keccak256('allowedUntil', msg.sender)] > now
      );
      _;
    }

}
