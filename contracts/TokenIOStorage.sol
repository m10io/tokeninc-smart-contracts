pragma solidity ^0.4.24;

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

@author Ryan Tate <ryan.michael.tate@gmail.com>

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

    /// @dev Delete Key Methods
		/// @dev delete methods may be unnecessary; Use set methods to set values
		/// to default?
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

    /// @dev Get Key Methods
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
