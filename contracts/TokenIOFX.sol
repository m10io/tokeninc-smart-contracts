pragma solidity ^0.4.24;

import "./Ownable.sol";
import "./TokenIOLib.sol";
import "./TokenIOStorage.sol";


/**
COPYRIGHT 2018 Token, Inc.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


@title Currency FX Contract for Token, Inc. Smart Money System

@author Ryan Tate <ryan.tate@token.io>, Sean Pollock <sean.pollock@token.io>

@notice Contract uses generalized storage contract, `TokenIOStorage`, for
upgradeability of interface contract.

@dev In the event that the main contract becomes deprecated, the upgraded contract
will be set as the owner of this contract, and use this contract's storage to
maintain data consistency between contract.

*/

contract TokenIOFX is Ownable {

  /// @dev Set reference to TokenIOLib interface which proxies to TokenIOStorage
  using TokenIOLib for TokenIOLib.Data;
  TokenIOLib.Data lib;


  /**
	* @notice Constructor method for TokenIOFX contract
	* @param _storageContract Address of TokenIOStorage contract
	*/
	constructor(address _storageContract) public {
			/// @dev Set the storage contract for the interface
			/// @dev NOTE: This contract will be unable to use the storage constract until
			/// @dev contract address is authorized with the storage contract
			/// @dev Once authorized, Use the `setParams` method to set storage values
			lib.Storage = TokenIOStorage(_storageContract);

			/// @dev set owner to contract initiator
			owner[msg.sender] = true;
	}


  /**
   * @notice Accepts a signed fx request to swap currency pairs at a given amount;
   * @dev This method can be called directly between peers.
   * @param  requester address Requester is the orginator of the offer and must
   * match the signature of the payload submitted by the fulfiller
   * @param  symbolA    Symbol of the currency desired
   * @param  symbolB    Symbol of the currency offered
   * @param  valueA     Amount of the currency desired
   * @param  valueB     Amount of the currency offered
   * @param  sigV       Ethereum secp256k1 signature V value; used by ecrecover()
   * @param  sigR       Ethereum secp256k1 signature R value; used by ecrecover()
   * @param  sigS       Ethereum secp256k1 signature S value; used by ecrecover()
   * @param  expiration Expiration of the offer; Offer is good until expired
   * @return {"success" : "Returns true if successfully called from another contract"}
   */
  function swap(
    address requester,
    string symbolA,
    string symbolB,
    uint valueA,
    uint valueB,
    uint8 sigV,
    bytes32 sigR,
    bytes32 sigS,
    uint expiration
  ) public returns (bool success) {
    require(lib.execSwap(requester, symbolA, symbolB, valueA, valueB, sigV, sigR, sigS, expiration));
    return true;
  }

}
