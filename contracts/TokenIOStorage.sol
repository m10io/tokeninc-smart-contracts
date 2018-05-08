pragma solidity 0.4.23;

// NOTE: This contract is inspired by the RocketPool Storage Contract,
// found here: https://github.com/rocket-pool/rocketpool/blob/master/contracts/RocketStorage.sol
// And this medium article: https://medium.com/rocket-pool/upgradable-solidity-contract-design-54789205276d

import "./Ownable.sol";


contract TokenIOStorage is Ownable {


    // Mappings for Primitive Data Types
    //
    mapping(bytes32 => uint256)    internal uIntStorage;
    mapping(bytes32 => string)     internal stringStorage;
    mapping(bytes32 => address)    internal addressStorage;
    mapping(bytes32 => bytes)      internal bytesStorage;
    mapping(bytes32 => bool)       internal boolStorage;
    mapping(bytes32 => int256)     internal intStorage;

    constructor() public {
        owner[msg.sender] = true;
    }

    // Set Methods
    function setAddress(bytes32 _key, address _value) public onlyOwner returns (bool) {
        addressStorage[_key] = _value;
        return true;
    }

    function setUint(bytes32 _key, uint _value) public onlyOwner returns (bool) {
        uIntStorage[_key] = _value;
        return true;
    }

    function setString(bytes32 _key, string _value) public onlyOwner returns (bool) {
        stringStorage[_key] = _value;
        return true;
    }

    function setBytes(bytes32 _key, bytes _value) public onlyOwner returns (bool) {
        bytesStorage[_key] = _value;
        return true;
    }

    function setBool(bytes32 _key, bool _value) public onlyOwner returns (bool) {
        boolStorage[_key] = _value;
        return true;
    }

    function setInt(bytes32 _key, int _value) public onlyOwner returns (bool) {
        intStorage[_key] = _value;
        return true;
    }

    // Delete Methods
    function deleteAddress(bytes32 _key) public onlyOwner returns (bool) {
        delete addressStorage[_key];
        return true;
    }

    function deleteUint(bytes32 _key) public onlyOwner returns (bool) {
        delete uIntStorage[_key];
        return true;
    }

    function deleteString(bytes32 _key) public onlyOwner returns (bool) {
        delete stringStorage[_key];
        return true;
    }

    function deleteBytes(bytes32 _key) public onlyOwner returns (bool) {
        delete bytesStorage[_key];
        return true;
    }

    function deleteBool(bytes32 _key) public onlyOwner returns (bool) {
        delete boolStorage[_key];
        return true;
    }

    function deleteInt(bytes32 _key) public onlyOwner returns (bool) {
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

}
