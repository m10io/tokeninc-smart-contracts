pragma solidity ^0.4.24;

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
@title TokenIO - ERC20 Compliant Smart Contract for Token, Inc.

@author Ryan Tate <ryan.michael.tate@gmail.com>, Sean Pollock <seanpollock3344@gmail.com>

@notice Contract uses generalized storage contract, `TokenIOStorage`, for
upgradeability of interface contract.
*/

import "./Ownable.sol";
import "./TokenIOStorage.sol";
import "./TokenIOLib.sol";

contract TokenIOAuthority is Ownable {

    // @dev Set reference to TokenIOLib interface which proxies to TokenIOStorage
    using TokenIOLib for TokenIOLib.Data;
    TokenIOLib.Data lib;

    /*
     * @notice Constructor method for Authority contract
     * @param _storageContract [address] of TokenIOStorage contract
     */
    constructor(address _storageContract) public {
        /*
         * @notice Set the storage contract for the interface
         * @dev This contract will be unable to use the storage constract until
         * @dev contract address is authorized with the storage contract
         * @dev Once authorized, you can setRegisteredFirm and setRegisteredAuthority
        */
        lib.Storage = TokenIOStorage(_storageContract);

        // @dev set owner to contract initiator
        owner[msg.sender] = true;
    }

    /* @notice Registers a firm as authorized true/false
     * @param _firmName Name of firm
     * @param _authorized Authorization status
     * @return {"success" : "Returns true if lib.setRegisteredFirm succeeds"}
     */
    function setRegisteredFirm(string _firmName, bool _authorized) public onlyAuthority(_firmName, msg.sender) returns (bool) {
        // @ notice set firm registration status
        require(lib.setRegisteredFirm(_firmName, _authorized));
        return true;
    }

    /* @notice Registers an authority asoociated with the given firm as true/false
     * @param _firmName Name of firm
     * @param _authority Address of authority account
     * @param _authorized Authorization status
     * @return {"success" : "Returns true if lib.setRegisteredAuthority succeeds"}
     */
    function setRegisteredAuthority(string _firmName, address _authority, bool _authorized) public onlyAuthority(_firmName, msg.sender) returns (bool) {
        // @notice set authority of firm to given status
        require(lib.setRegisteredAuthority(_firmName, _authority, _authorized));
        return true;
    }

    /* @notice Gets firm asoociated with an authority address
     * @param _authority Address of authority account
     * @return {"firm" : "name of firm"}
     */
    function getFirmFromAuthority(address _authority) public view returns (string) {
        return lib.getFirmFromAuthority(_authority);
    }

    /* @notice Gets status of firm registration
     * @param _firmname Name of firm
     * @return {"status" : "Returns status of firm registration"}
     */
    function isRegisteredFirm(string _firmName) public view returns (bool) {
        // @notice check firm's registration status
        return lib.isRegisteredFirm(_firmName);
    }

    /* @notice Checks if an authority account is registered to a given firm
     * @param _firmname Name of firm
     * @param _authority Address of authority account
     * @return {"registered" : "Returns status of account registration to firm"}
     */
    function isRegisteredToFirm(string _firmName, address _authority) public view returns (bool) {
        // @notice check if registered to firm
        return lib.isRegisteredToFirm(_firmName, _authority);
    }

    /* @notice Gets status of authority registration
     * @param _authority Address of authority account
     * @return { "registered" : "Returns true if account is a registered authority }
     */
    function isRegisteredAuthority(address _authority) public view returns (bool) {
        // @notice check if registered authority
        return lib.isRegisteredAuthority(_authority);
    }

    /* @notice Sets contract which specifies fee parameters
     * @param _feeContract Address of the fee contract
     * @return { "success" : "Returns true if lib.setMasterFeeContract succeeds" }
     */
    function setMasterFeeContract(address _feeContract) public onlyOwner returns (bool success) {
        // @notice set master fee contract
        require(lib.setMasterFeeContract(_feeContract));
        return true;
      }


    modifier onlyAuthority(string _firmName, address _authority) {
        // @notice throws if not an owner auuthority or not registered to the given firm
        require(owner[_authority] || lib.isRegisteredToFirm(_firmName, _authority));
        _;
    }

}
