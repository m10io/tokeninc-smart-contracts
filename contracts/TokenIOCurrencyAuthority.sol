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

import "./Ownable.sol";
import "./TokenIOStorage.sol";
import "./TokenIOLib.sol";

/*
@title TokenIO - ERC20 Compliant Smart Contract for Token, Inc.

@author Ryan Tate <ryan.michael.tate@gmail.com>, Sean Pollock <seanpollock3344@gmail.com>

@notice Contract uses generalized storage contract, `TokenIOStorage`, for
upgradeability of interface contract.
*/

contract TokenIOCurrencyAuthority is Ownable {

    // @dev Set reference to TokenIOLib interface which proxies to TokenIOStorage
    using TokenIOLib for TokenIOLib.Data;
    TokenIOLib.Data lib;

    /*
     * @notice Constructor method for CurrencyAuthority contract
     * @param _storageContract [address] of TokenIOStorage contract
     */
    constructor(address _storageContract) public {
        /* @notice Set the storage contract for the interface
         * @dev This contract will be unable to use the storage constract until
         * @dev Contract address is authorized with the storage contract
         */
        lib.Storage = TokenIOStorage(_storageContract);

        // @dev set owner to contract initiator
        owner[msg.sender] = true;
    }

    /* @notice Gets balance of sepcified account for a given currency
     * @param currency [string] currency symbol 'USDx'
     * @param account [address] sepcified account
     * @return [uint] account balance
     */
    function getTokenBalance(string currency, address account) public view returns (uint) {
      return lib.getTokenBalance(currency, account);
    }

    /* @notice Gets total supply of specified currency
     * @param currency [string] currency symbol 'USDx'
     * @return [uint] total supply
     */
    function getTokenSupply(string currency) public view returns (uint) {
      return lib.getTokenSupply(currency);
    }

    /* @notice Updates account status. false: frozen, true: un-frozen
     * @param account [address] sepcified account
     * @param isAllowed [bool] false: frozen, true: un-frozen
     * @param issuerFirm [string] name of firm
     * @return [bool] true if lib.setAccountStatus succeeds
     */
    function freezeAccount(address account, bool isAllowed, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool) {
        // @notice updates account status
        // @dev !!! mutates storage state
        require(lib.setAccountStatus(account, isAllowed, issuerFirm));
        return true;
    }

    /* @notice Sets approval status of specified account
     * @param account [address] sepcified account
     * @param isApproved [bool] false: not-approved, true: approved
     * @param issuerFirm [string] name of firm
     * @return [bool] true if lib.setKYCApproval and lib.setAccountStatus succeed
     */
    function approveKYC(address account, bool isApproved, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool) {
        // @notice updates kyc approval status
        // @dev !!! mutates storage state
        require(lib.setKYCApproval(account, isApproved, issuerFirm));
        // @notice updates account statuss
        // @dev !!! mutates storage state
        require(lib.setAccountStatus(account, isApproved, issuerFirm));
        return true;
    }

    /* @notice Approves account and deposits specified amount of given currency
     * @param currency [string] currency symbol
     * @param account [address] specified account
     * @param amount [uint] specified amount
     * @param issuerFirm [string] name of firm
     * @return [bool] true if lib.setKYCApproval, lib.setAccountStatus and lib.deposit succeed
     */
    function approveKYCAndDeposit(string currency, address account, uint amount, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool) {
        // @notice updates kyc approval status
        // @dev !!! mutates storage state
        require(lib.setKYCApproval(account, true, issuerFirm));
        // @notice updates kyc approval status
        // @dev !!! mutates storage state
        require(lib.setAccountStatus(account, true, issuerFirm));
        require(lib.deposit(currency, account, amount, issuerFirm));
        return true;
    }

    /* @notice Updates to new forwarded account
     * @param originalAccount [address]
     * @param updatedAccount [address]
     * @param issuerFirm [string] name of firm
     * @return [bool] true if lib.setForwardedAccount succeeds
     */
    function approveForwardedAccount(address originalAccount, address updatedAccount, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool) {
        // @notice updatesa forwarded account
        // @dev !!! mutates storage state
        require(lib.setForwardedAccount(originalAccount, updatedAccount));
        return true;
    }

    /* @notice Issues a specified account to recipient account of a given currency
     * @param currency [string] currency symbol
     * @param amount [uint] issuance amount
     * @param issuerFirm [string] name of firm
     * @return [bool] true if lib.verifyAccount and lib.deposit succeeds
     */
    function deposit(string currency, address account, uint amount, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool) {
        require(lib.verifyAccount(account));
        // @notice depositing tokens to account
        // @dev !!! mutates storage state
        require(lib.deposit(currency, account, amount, issuerFirm));
        return true;
    }

    /* @notice Withdraws a specified amount of tokens of a given currency
     * @param currency [string] currency symbol
     * @param account [address] specified account
     * @param amount [uint] issuance amount
     * @param issuerFirm [string] name of firm
     * @return [bool] true if lib.verifyAccount and lib.withdraw succeeds
     */
    function withdraw(string currency, address account, uint amount, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool) {
        require(lib.verifyAccount(account));
        // @notice withdrawing from account
        // @dev !!! mutates storage state
        require(lib.withdraw(currency, account, amount, issuerFirm));
        return true;
    }


    modifier onlyAuthority(string _firmName, address _authority) {
        // @notice throws if authority account is not registred to the given firm
        require(lib.isRegisteredToFirm(_firmName, _authority));
        _;
    }

}
