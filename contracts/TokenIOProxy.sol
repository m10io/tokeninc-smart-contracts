pragma solidity 0.4.24;

import './Ownable.sol';
import './TokenIOStorage.sol';
import './TokenIOStorageLib.sol';

/**
COPYRIGHT 2018 Token, Inc.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


@title TokenIOProxy

@author Ryan Tate <ryan.tate@token.io>, Sean Pollock <sean.pollock@token.io>

@notice This library proxies the TokenIOStorage contract for the interface contract,
allowing the library and the interfaces to remain stateless, and share a universally
available storage contract between interfaces.


*/

contract TokenIOProxy is Ownable {

	//// @dev Set reference to TokenIOStorageLib interface which proxies to TokenIOStorage
  using TokenIOStorageLib for TokenIOStorageLib.Data;
  TokenIOStorageLib.Data lib;

  /**
  * @notice Constructor method for TokenIOProxy contract
  * @param _storageContract     address of TokenIOStorage contract
  */
  constructor(address _storageContract) public {
    //// @dev Set the storage contract for the interface
    //// @dev This contract will be unable to use the storage constract until
    //// @dev contract address is authorized with the storage contract
    //// @dev Once authorized, Use the `setParams` method to set storage values
    lib.Storage = TokenIOStorage(_storageContract);

    //// @dev set owner to contract initiator
    owner[msg.sender] = true;
  }

	function getContractProxy() view public returns (address contractProxy) {
		return lib.Storage.getAddress(keccak256(abi.encodePacked('proxy.interface', address(this))));
	}

	function getProxyContract(string contractName) view public returns (address proxyContract) {
		return lib.Storage.getAddress(keccak256(abi.encodePacked('proxy.interface', contractName)));
	}

	function getNamedProxiedInterface() view public returns (string) {
		return lib.Storage.getString(keccak256(abi.encodePacked('proxy.interface', address(this))));
	}

	function updateProxiedContract(address contractProxy, string contractName) public onlyOwner returns (bool success) {
		require(lib.Storage.setAddress(keccak256(abi.encodePacked('proxy.interface', address(this))), contractProxy));
		require(lib.Storage.setAddress(keccak256(abi.encodePacked('proxy.interface', contractName)), address(this)));
		require(lib.Storage.setString(keccak256(abi.encodePacked('proxy.interface', address(this))), contractName));
		return true;
	}


	/// Forward data to proxied contract
	function () payable public {
    address target = getContractProxy();
    require(target != address(0));
    bytes memory data = msg.data;

    assembly {
      let result := delegatecall(gas, target, add(data, 0x20), mload(data), 0, 0)
      let size := returndatasize
      let ptr := mload(0x40)
      returndatacopy(ptr, 0, size)
      switch result
      case 0 { revert(ptr, size) }
      default { return(ptr, size) }
    }
  }

}
