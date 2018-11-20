pragma solidity 0.4.24;

/*
COPYRIGHT 2018 Token, Inc.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


/**
@title TokenIOAuthority - Authority Smart Contract for Token, Inc.

@author Ryan Tate <ryan.tate@token.io>, Sean Pollock <sean.pollock@token.io>

@notice Contract uses generalized storage contract, `TokenIOStorage`, for
upgradeability of interface contract.
*/

import "./Ownable.sol";
import "./TokenIOStorage.sol";
import "./TokenIOLib.sol";

contract TokenIOAuthority is Ownable {

    /// @dev Set reference to TokenIOLib interface which proxies to TokenIOStorage
    using TokenIOLib for TokenIOLib.Data;
    TokenIOLib.Data lib;

    /**
     * @notice Constructor method for Authority contract
     * @param _storageContract Ethereum Address of TokenIOStorage contract
     */
    constructor(address _storageContract) public {
        /*
         * @notice Set the storage contract for the interface
         * @dev This contract will be unable to use the storage constract until
         * @dev contract address is authorized with the storage contract
         * @dev Once authorized, you can setRegisteredFirm and setRegisteredAuthority
        */
        lib.Storage = TokenIOStorage(_storageContract);

        /// @dev set owner to contract initiator
        owner[msg.sender] = true;
    }

    /**
     * @notice Registers a firm as authorized true/false
     * @param firmName Name of firm
     * @param _authorized Authorization status
     * @return {"success" : "Returns true if lib.setRegisteredFirm succeeds"}
     */
    function setRegisteredFirm(string firmName, bool _authorized) public onlyAuthority(firmName, msg.sender) returns (bool success) {
        /// @notice set firm registration status
        require(
          lib.setRegisteredFirm(firmName, _authorized),
          "Error: Failed to register firm with storage contract! Please check your arguments."
        );
        return true;
    }

    /**
     * @notice Registers an authority asoociated with the given firm as true/false
     * @param firmName Name of firm
     * @param authority Address of authority account
     * @param _authorized Authorization status
     * @return {"success" : "Returns true if lib.setRegisteredAuthority succeeds"}
     */
    function setRegisteredAuthority(string firmName, address authority, bool _authorized) public onlyAuthority(firmName, msg.sender) returns (bool success) {
        /// @notice set authority of firm to given status
        require(
          lib.setRegisteredAuthority(firmName, authority, _authorized),
          "Error: Failed to register authority for issuer firm with storage contract! Please check your arguments and ensure firmName is registered before allowing an authority of said firm"
        );
        return true;
    }

    /**
     * @notice Gets firm asoociated with an authority address
     * @param authority Address of authority account
     * @return {"firm" : "name of firm"}
     */
    function getFirmFromAuthority(address authority) public view returns (string firm) {
        return lib.getFirmFromAuthority(authority);
    }

    /**
     * @notice Gets status of firm registration
     * @param firmName Name of firm
     * @return {"status" : "Returns status of firm registration"}
     */
    function isRegisteredFirm(string firmName) public view returns (bool status) {
        /// @notice check firm's registration status
        return lib.isRegisteredFirm(firmName);
    }

    /**
     * @notice Checks if an authority account is registered to a given firm
     * @param firmName Name of firm
     * @param authority Address of authority account
     * @return {"registered" : "Returns status of account registration to firm"}
     */
    function isRegisteredToFirm(string firmName, address authority) public view returns (bool registered) {
        /// @notice check if registered to firm
        return lib.isRegisteredToFirm(firmName, authority);
    }

    /**
     * @notice Gets status of authority registration
     * @param authority Address of authority account
     * @return { "registered" : "Returns true if account is a registered authority" }
     */
    function isRegisteredAuthority(address authority) public view returns (bool registered) {
        /// @notice check if registered authority
        return lib.isRegisteredAuthority(authority);
    }

    /**
     * @notice Sets contract which specifies fee parameters
     * @param feeContract Address of the fee contract
     * @return { "success" : "Returns true if lib.setMasterFeeContract succeeds" }
     */
    function setMasterFeeContract(address feeContract) public onlyOwner returns (bool success) {
      /// @notice set master fee contract
      require(
        lib.setMasterFeeContract(feeContract),
        "Error: Unable to set master fee contract. Please ensure fee contract has the correct parameters."
      );
      return true;
    }

    function setKYCRequired(bool required) public onlyOwner returns (bool success) {
      /// @notice set master fee contract
      require(
        lib.Storage.setBool(keccak256(abi.encodePacked('kyc.required')), required),
        "Error: Unable to set KYC requirement."
      );
      return true;
    }

    modifier onlyAuthority(string firmName, address authority) {
        /// @notice throws if not an owner authority or not registered to the given firm
        require(owner[authority] || lib.isRegisteredToFirm(firmName, authority),
          "Error: Transaction sender does not have permission for this operation!"
        );
        _;
    }

}
