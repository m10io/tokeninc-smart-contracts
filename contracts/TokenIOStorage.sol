pragma solidity 0.4.24;

import "./Ownable.sol";

/**

COPYRIGHT 2018 Token, Inc.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


@title TokenIOStorage - Serves as derived contract for TokenIO contract and
is used to upgrade interfaces in the event of deprecating the main contract.

@author Ryan Tate <ryan.tate@token.io>, Sean Pollock <sean.pollock@token.io>

@notice Storage contract

@dev In the event that the main contract becomes deprecated, the upgraded contract
will be set as the owner of this contract, and use this contract's storage to
maintain data consistency between contract.

@notice NOTE: This contract is based on the RocketPool Storage Contract,
found here: https://github.com/rocket-pool/rocketpool/blob/master/contracts/RocketStorage.sol
And this medium article: https://medium.com/rocket-pool/upgradable-solidity-contract-design-54789205276d

Changes:
 - setting primitive mapping view to internal;
 - setting method views to public;

 @dev NOTE: When deprecating the main TokenIO contract, the upgraded contract
 must take ownership of the TokenIO contract, it will require using the public methods
 to update changes to the underlying data. The updated contract must use a
 standard call to original TokenIO contract such that the  request is made from
 the upgraded contract and not the transaction origin (tx.origin) of the signing
 account.


 @dev NOTE: The reasoning for using the storage contract is to abstract the interface
 from the data of the contract on chain, limiting the need to migrate data to
 new contracts.

*/
contract TokenIOStorage is Ownable {


    /// @dev mapping for Primitive Data Types;
		/// @notice primitive data mappings have `internal` view;
		/// @dev only the derived contract can use the internal methods;
		/// @dev key == `keccak256(param1, param2...)`
		/// @dev Nested mapping can be achieved using multiple params in keccak256 hash;

    struct Entity {
        string name;
        string symbol;
        string tla;
        string version;
        address feeContract;
        uint fxUSDBPSRate;
    }
    
    struct FeeData {
        uint maxFee;
        uint minFee;
        uint bpsFee;
        uint flatFee;
    }

    mapping(address => mapping(string => uint256)) internal balances;

    mapping(address => FeeData) internal fees;
    mapping(address => address) internal relatedAccounts;
    mapping(address => bool)    internal isDeprecated;
    mapping(string => uint)     internal decimals;
    mapping(address => Entity)  internal entities;
    
    mapping(bytes32 => uint256)    internal uIntStorage;
    mapping(bytes32 => string)     internal stringStorage;
    mapping(bytes32 => address)    internal addressStorage;
    mapping(bytes32 => bytes)      internal bytesStorage;
    mapping(bytes32 => bool)       internal boolStorage;
    mapping(bytes32 => int256)     internal intStorage;

    constructor() public {
				/// @notice owner is set to msg.sender by default
				/// @dev consider removing in favor of setting ownership in inherited
				/// contract
        owner[msg.sender] = true;
    }

    /// @dev Set Key Methods

    /**
     * @notice Set value for Address associated with bytes32 id key
     * @param _key Pointer identifier for value in storage
     * @param _value The Address value to be set
     * @return { "success" : "Returns true when successfully called from another contract" }
     */
    function setAddress(bytes32 _key, address _value) external onlyOwner returns (bool success) {
        addressStorage[_key] = _value;
        return true;
    }

    /**
     * @notice Set value for Uint associated with bytes32 id key
     * @param _key Pointer identifier for value in storage
     * @param _value The Uint value to be set
     * @return { "success" : "Returns true when successfully called from another contract" }
     */
    function setUint(bytes32 _key, uint _value) public onlyOwner returns (bool success) {
        uIntStorage[_key] = _value;
        return true;
    }

    /**
     * @notice Set value for String associated with bytes32 id key
     * @param _key Pointer identifier for value in storage
     * @param _value The String value to be set
     * @return { "success" : "Returns true when successfully called from another contract" }
     */
    function setString(bytes32 _key, string _value) external onlyOwner returns (bool success) {
        stringStorage[_key] = _value;
        return true;
    }

    /**
     * @notice Set value for Bytes associated with bytes32 id key
     * @param _key Pointer identifier for value in storage
     * @param _value The Bytes value to be set
     * @return { "success" : "Returns true when successfully called from another contract" }
     */
    function setBytes(bytes32 _key, bytes _value) external onlyOwner returns (bool success) {
        bytesStorage[_key] = _value;
        return true;
    }

    /**
     * @notice Set value for Bool associated with bytes32 id key
     * @param _key Pointer identifier for value in storage
     * @param _value The Bool value to be set
     * @return { "success" : "Returns true when successfully called from another contract" }
     */
    function setBool(bytes32 _key, bool _value) external onlyOwner returns (bool success) {
        boolStorage[_key] = _value;
        return true;
    }

    /**
     * @notice Set value for Int associated with bytes32 id key
     * @param _key Pointer identifier for value in storage
     * @param _value The Int value to be set
     * @return { "success" : "Returns true when successfully called from another contract" }
     */
    function setInt(bytes32 _key, int _value) external onlyOwner returns (bool success) {
        intStorage[_key] = _value;
        return true;
    }

    /// @dev Delete Key Methods
		/// @dev delete methods may be unnecessary; Use set methods to set values
		/// to default?

    /**
     * @notice Delete value for Address associated with bytes32 id key
     * @param _key Pointer identifier for value in storage
     * @return { "success" : "Returns true when successfully called from another contract" }
     */
    function deleteAddress(bytes32 _key) external onlyOwner returns (bool success) {
        delete addressStorage[_key];
        return true;
    }

    /**
     * @notice Delete value for Uint associated with bytes32 id key
     * @param _key Pointer identifier for value in storage
     * @return { "success" : "Returns true when successfully called from another contract" }
     */
    function deleteUint(bytes32 _key) external onlyOwner returns (bool success) {
        delete uIntStorage[_key];
        return true;
    }

    /**
     * @notice Delete value for String associated with bytes32 id key
     * @param _key Pointer identifier for value in storage
     * @return { "success" : "Returns true when successfully called from another contract" }
     */
    function deleteString(bytes32 _key) external onlyOwner returns (bool success) {
        delete stringStorage[_key];
        return true;
    }

    /**
     * @notice Delete value for Bytes associated with bytes32 id key
     * @param _key Pointer identifier for value in storage
     * @return { "success" : "Returns true when successfully called from another contract" }
     */
    function deleteBytes(bytes32 _key) external onlyOwner returns (bool success) {
        delete bytesStorage[_key];
        return true;
    }

    /**
     * @notice Delete value for Bool associated with bytes32 id key
     * @param _key Pointer identifier for value in storage
     * @return { "success" : "Returns true when successfully called from another contract" }
     */
    function deleteBool(bytes32 _key) external onlyOwner returns (bool success) {
        delete boolStorage[_key];
        return true;
    }

    /**
     * @notice Delete value for Int associated with bytes32 id key
     * @param _key Pointer identifier for value in storage
     * @return { "success" : "Returns true when successfully called from another contract" }
     */
    function deleteInt(bytes32 _key) external onlyOwner returns (bool success) {
        delete intStorage[_key];
        return true;
    }

    /// @dev Get Key Methods

    /**
     * @notice Get value for Address associated with bytes32 id key
     * @param _key Pointer identifier for value in storage
     * @return { "_value" : "Returns the Address value associated with the id key" }
     */
    function getAddress(bytes32 _key) external view returns (address _value) {
        return addressStorage[_key];
    }

    /**
     * @notice Get value for Uint associated with bytes32 id key
     * @param _key Pointer identifier for value in storage
     * @return { "_value" : "Returns the Uint value associated with the id key" }
     */
    function getUint(bytes32 _key) public view returns (uint _value) {
        return uIntStorage[_key];
    }

    /**
     * @notice Get value for String associated with bytes32 id key
     * @param _key Pointer identifier for value in storage
     * @return { "_value" : "Returns the String value associated with the id key" }
     */
    function getString(bytes32 _key) external view returns (string _value) {
        return stringStorage[_key];
    }

    /**
     * @notice Get value for Bytes associated with bytes32 id key
     * @param _key Pointer identifier for value in storage
     * @return { "_value" : "Returns the Bytes value associated with the id key" }
     */
    function getBytes(bytes32 _key) external view returns (bytes _value) {
        return bytesStorage[_key];
    }

    /**
     * @notice Get value for Bool associated with bytes32 id key
     * @param _key Pointer identifier for value in storage
     * @return { "_value" : "Returns the Bool value associated with the id key" }
     */
    function getBool(bytes32 _key) external view returns (bool _value) {
        return boolStorage[_key];
    }

    /**
     * @notice Get value for Int associated with bytes32 id key
     * @param _key Pointer identifier for value in storage
     * @return { "_value" : "Returns the Int value associated with the id key" }
     */
    function getInt(bytes32 _key) external view returns (int _value) {
        return intStorage[_key];
    }

    function getDeprecated(address _address) external view returns (bool _value) {
        return isDeprecated[_address];
    }

    function setDeprecated(address _address, bool _value) external onlyOwner returns (bool success) {
        isDeprecated[_address] = _value;
        return true;
    }

    function getFees(address _address) external view returns (uint maxFee, uint minFee, uint bpsFee, uint flatFee) {
        FeeData memory feeData = fees[_address];
        return (feeData.maxFee, feeData.minFee, feeData.bpsFee, feeData.flatFee);
    }

    function setFees(address _address, uint maxFee, uint minFee, uint bpsFee, uint flatFee) external onlyOwner returns (bool success) {
        FeeData memory feeData = FeeData(maxFee, minFee, bpsFee, flatFee);
        fees[_address] = feeData;
        return true;
    }
    
    function getRelatedAccount(address _address) external view returns (address value) {
        address relatedAddress = relatedAccounts[_address];
        return (0x0 != relatedAddress) ? relatedAddress : _address;
    }

    function getRelatedAccounts(address[3] _addresses) internal view returns (address[3] memory) {
        address[3] memory relatedAddresses;
        for(uint i = 0; i < _addresses.length; i++) {
            relatedAddresses[i] = relatedAccounts[_addresses[i]];
            relatedAddresses[i] = (0x0 != relatedAddresses[i]) ? relatedAddresses[i] : _addresses[i];
        }

        return relatedAddresses;
    }

    function getTransferDetails(address _account, address[3] _addresses) external view returns(string memory currency, address[3] memory addresses) {
      currency = entities[_account].symbol;
      addresses = getRelatedAccounts(_addresses);
    }

    function setRelatedAccount(address _address, address _related) external onlyOwner returns (bool success) {
        relatedAccounts[_address] = _related;
        return true;
    }
    
    function getBalance(address _address, string _currency) external view returns (uint256 value) {
        //return getUint(keccak256(abi.encodePacked('token.balance', _address, _currency)));
        return balances[_address][_currency];
    }

    function setBalance(address _address, string _currency, uint _value) external onlyOwner returns (bool success) {
        //setUint(keccak256(abi.encodePacked('token.balance', _address, _currency)), _value);
        balances[_address][_currency] = _value;
        return true;
    }

    function setBalances(address[3] _addresses, string _currency, uint[3] _values) external onlyOwner {
        for(uint i = 0; i < _addresses.length; i++) {
            balances[_addresses[i]][_currency] = _values[i];
        }
    }

    function setTokenParams(address _address, string _name, string _symbol, string _tla, string _version, uint _decimals, address _feeContract, uint _fxUSDBPSRate) external onlyOwner returns(bool success) {
        entities[_address] = Entity(_name, _symbol, _tla, _version, _feeContract, _fxUSDBPSRate);

        decimals[_symbol] = _decimals;

        return true;
    }

    function getTokenName(address _address) external view returns(string) {
        return entities[_address].name;
    }

    function setTokenName(address _address, string _tokenName) external onlyOwner returns(bool success) {
        entities[_address].name = _tokenName;
        return true;
    }

    function getTokenSymbol(address _address) external view returns(string) {
        return entities[_address].symbol;
    }

    function setTokenSymbol(address _address, string _value) external onlyOwner returns (bool success) {
        entities[_address].symbol = _value;
        return true;
    }

    function getTokenTLA(address _address) external view returns(string) {
        return entities[_address].tla;
    }

    function setTokenTLA(address _address, string _tokenTLA) external onlyOwner returns(bool success) {
        entities[_address].tla = _tokenTLA;
        return true;
    }

    function getTokenVersion(address _address) external view returns(string) {
        return entities[_address].version;
    }

    function setTokenVersion(address _address, string _tokenVersion) external onlyOwner returns(bool success) {
        entities[_address].version = _tokenVersion;
        return true;
    }

    function getTokenDecimals(string _currency) external view returns(uint) {
        return decimals[_currency];
    }

    function setTokenDecimals(string _currency, uint _decimals) external onlyOwner returns(bool success) {
         decimals[_currency] = _decimals;
         return true;
    }

    function getTokenFeeContract(address _address) external view returns(address) {
        return entities[_address].feeContract;
    }

    function setTokenFeeContract(address _address, address _value) external onlyOwner returns (bool success) {
        entities[_address].feeContract = _value;
        return true;
    }

    function getTokenfxUSDBPSRate(address _address) external view returns(uint) {
        return entities[_address].fxUSDBPSRate;
    }

}