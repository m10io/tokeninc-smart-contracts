pragma solidity 0.4.24;

import './Ownable.sol';
import './TokenIOStorage.sol';
import './TokenIOStorageLib.sol';
import './TokenIOProxy.sol';

/**
COPYRIGHT 2018 Token, Inc.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


@title TokenIOProxyProvider

@author Ryan Tate <ryan.tate@token.io>, Sean Pollock <sean.pollock@token.io>

@notice This library proxies the TokenIOStorage contract for the interface contract,
allowing the library and the interfaces to remain stateless, and share a universally
available storage contract between interfaces.


*/

contract TokenIOProxyProvider is Ownable {

	//// @dev Set reference to TokenIOStorageLib interface which proxies to TokenIOStorage
  using TokenIOStorageLib for TokenIOStorageLib.Data;
  TokenIOStorageLib.Data lib;

	event LogNewProxy(address indexed proxy, address indexed contractProxy, string contractName);
	event LogUpdateProxy(address indexed proxy, address indexed contractProxy, string contractName);

  /**
  * @notice Constructor method for TokenIOProxyProvider contract
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

	function newProxy(address contractProxy, string contractName) public onlyOwner returns (bool success) {
		/// @notice Create the new Proxy Contract
		TokenIOProxy proxy = new TokenIOProxy(address(lib.Storage));
		/// @notice allow the proxy contract access to the storage contract;
		require(lib.Storage.allowOwnership(address(proxy)));
		require(proxy.updateProxiedContract(contractProxy, contractName));

		emit LogNewProxy(proxy, contractProxy, contractName);
		return true;
	}

	function updateProxy(address _proxy, address contractProxy, string contractName) public onlyOwner returns (bool success) {
		TokenIOProxy proxy = TokenIOProxy(_proxy);
		require(proxy.updateProxiedContract(contractProxy, contractName));

		emit LogUpdateProxy(proxy, contractProxy, contractName);
		return true;
	}

	function getProxyContract(string contractName) view public returns (address proxyContract) {
		return lib.Storage.getAddress(keccak256(abi.encodePacked('proxy.interface', contractName)));
	}

}
