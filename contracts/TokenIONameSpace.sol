pragma solidity ^0.4.24;


/**
COPYRIGHT 2018 Token, Inc.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



@title Token Name Space Interface for Token, Inc. Smart Money System

@author Ryan Tate <ryan.tate@token.io>, Sean Pollock <sean.pollock@token.io>

@notice Contract uses generalized storage contract, `TokenIOStorage`, for
upgradeability of interface contract.

@dev In the event that the main contract becomes deprecated, the upgraded contract
will be set as the owner of this contract, and use this contract's storage to
maintain data consistency between contract.

*/

import "./Ownable.sol";
import "./TokenIOStorage.sol";
import "./TokenIOLib.sol";

contract TokenIONameSpace is Ownable {

    /// @dev Set reference to TokenIOLib interface which proxies to TokenIOStorage
    using TokenIOLib for TokenIOLib.Data;
    TokenIOLib.Data lib;

    /**
  	* @notice Constructor method for TokenIONameSpace contract
  	* @param _storageContract     address of TokenIOStorage contract
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
     * @notice Returns the address of the contract associated with the currency symbol
     * @notice This method may be deprecated or refactored to allow for multiple interfaces
     * @param  currency string Currency symbol of the token (e.g. USDx, JYPx, GBPx)
     * @return {"contractAddress": "Returns the token contract address associated with the currency"}
     */
    function getTokenNameSpace(string currency) public view returns (address contractAddress) {
        return lib.getTokenNameSpace(currency);
    }

}
