pragma solidity 0.4.21;


contract StorageInterface {

    // Modifiers
    modifier isAllowed() {_;}
    modifier isActive() {_;}

    // Set methods
    function setAddress(bytes32 _key, address _value)
        external
        isActive
        isAllowed
        returns (bool);

    function setUint(bytes32 _key, uint _value)
        external
        isActive
        isAllowed
        returns (bool);

    function setString(bytes32 _key, string _value)
        external
        isActive
        isAllowed
        returns (bool);

    function setBytes(bytes32 _key, bytes _value)
        external
        isActive
        isAllowed
        returns (bool);

    function setBool(bytes32 _key, bool _value)
        external
        isActive
        isAllowed
        returns (bool);

    function setInt(bytes32 _key, int _value)
        external
        isActive
        isAllowed
        returns (bool);

    // Delete Methods
    function deleteAddress(bytes32 _key)
        external
        isActive
        isAllowed
        returns (bool);

    function deleteUint(bytes32 _key)
        external
        isActive
        isAllowed
        returns (bool);

    function deleteString(bytes32 _key)
        external
        isActive
        isAllowed
        returns (bool);

    function deleteBytes(bytes32 _key)
        external
        isActive
        isAllowed
        returns (bool);

    function deleteBool(bytes32 _key)
        external
        isActive
        isAllowed
        returns (bool);

    function deleteInt(bytes32 _key)
        external
        isActive
        isAllowed
        returns (bool);

    // Get Methods
    function getAddress(bytes32 _key)
        external
        view
        returns (address);

    function getUint(bytes32 _key)
        external
        view
        returns (uint);

    function getString(bytes32 _key)
        external
        view
        returns (string);

    function getBytes(bytes32 _key)
        external
        view
        returns (bytes);

    function getBytes32(bytes32 _key)
        external
        view
        returns (bytes);

    function getBool(bytes32 _key)
        external
        view
        returns (bool);

    function getInt(bytes32 _key)
        external
        view
        returns (int);
}
