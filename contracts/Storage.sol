pragma solidity 0.4.23;

// NOTE: This contract is inspired by the RocketPool Storage Contract,
// found here: https://github.com/rocket-pool/rocketpool/blob/master/contracts/RocketStorage.sol
// And this medium article: https://medium.com/rocket-pool/upgradable-solidity-contract-design-54789205276d

contract Storage {

    // Mappings for Primitive Data Types
    //
    mapping(bytes32 => uint256)    private uIntStorage;
    mapping(bytes32 => string)     private stringStorage;
    mapping(bytes32 => address)    private addressStorage;
    mapping(bytes32 => bytes)      private bytesStorage;
    mapping(bytes32 => bool)       private boolStorage;
    mapping(bytes32 => int256)     private intStorage;

    constructor() public {


        // Set original contract creator as owner to prevent external changes
        /* boolStorage[keccak256("storage.allowed", msg.sender)] = true; */

        /* uIntStorage[keccak256("token.decimals")] = 5; // millicents */

        // Ensure supply & fixed fees are represented as expanded representation based on decimals
        /* uIntStorage[keccak256("token.supply")] = 2343200000; // 23432 * 5**10; */

        // Set the full balance to creator of the contract
        /* uIntStorage[keccak256("token.balance", msg.sender)] = 2343200000; */

        /* uIntStorage[keccak256("fee.min")] = */
        /* uIntStorage[keccak256("fee.max")] = */
        /* uIntStorage[keccak256("fee.bps")] = */
        /* uIntStorage[keccak256("fee.flat")] = */

        // Fees are fixed costs
        /* uIntStorage[keccak256("fee.kyc")] = 110000; // 1.10 * 5**10 */
        /* uIntStorage[keccak256("fee.account")] = 50000; // .50 * 5**10 */

        //
        /* uIntStorage[keccak256("fee.multiplier.max")] = 4; */
        /* uIntStorage[keccak256("fee.multiplier.mid")] = 2; */
        /* uIntStorage[keccak256("fee.multiplier.min")] = 1; */

    }

    // Set Methods
    function setAddress(bytes32 _key, address _value) external isAllowed returns (bool) {
        addressStorage[_key] = _value;
        return true;
    }

    function setUint(bytes32 _key, uint _value) external isAllowed returns (bool) {
        uIntStorage[_key] = _value;
        return true;
    }

    function setString(bytes32 _key, string _value) external isAllowed returns (bool) {
        stringStorage[_key] = _value;
        return true;
    }

    function setBytes(bytes32 _key, bytes _value) external isAllowed returns (bool) {
        bytesStorage[_key] = _value;
        return true;
    }

    function setBool(bytes32 _key, bool _value) external isAllowed returns (bool) {
        boolStorage[_key] = _value;
        return true;
    }

    function setInt(bytes32 _key, int _value) external isAllowed returns (bool) {
        intStorage[_key] = _value;
        return true;
    }

    // Delete Methods
    function deleteAddress(bytes32 _key) external isAllowed returns (bool) {
        delete addressStorage[_key];
        return true;
    }

    function deleteUint(bytes32 _key) external isAllowed returns (bool) {
        delete uIntStorage[_key];
        return true;
    }

    function deleteString(bytes32 _key) external isAllowed returns (bool) {
        delete stringStorage[_key];
        return true;
    }

    function deleteBytes(bytes32 _key) external isAllowed returns (bool) {
        delete bytesStorage[_key];
        return true;
    }

    function deleteBool(bytes32 _key) external isAllowed returns (bool) {
        delete boolStorage[_key];
        return true;
    }

    function deleteInt(bytes32 _key) external isAllowed returns (bool) {
        delete intStorage[_key];
        return true;
    }

    // Get Methods
    function getAddress(bytes32 _key) external view returns (address) {
        return addressStorage[_key];
    }

    function getUint(bytes32 _key) external view returns (uint) {
        return uIntStorage[_key];
    }

    function getString(bytes32 _key) external view returns (string) {
        return stringStorage[_key];
    }

    function getBytes(bytes32 _key) external view returns (bytes) {
        return bytesStorage[_key];
    }

    function getBool(bytes32 _key) external view returns (bool) {
        return boolStorage[_key];
    }

    function getInt(bytes32 _key) external view returns (int) {
        return intStorage[_key];
    }

    // Modifiers
    modifier isAllowed() {
        require(boolStorage[keccak256("storage.allowed", msg.sender)]);
        _;
    }

}
