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
@title TokenIOCurrencyAuthority - Currency Authority Smart Contract for Token, Inc.

@author Ryan Tate <ryan.tate@token.io>, Sean Pollock <sean.pollock@token.io>

@notice Contract uses generalized storage contract, `TokenIOStorage`, for
upgradeability of interface contract.
*/

contract TokenIOCurrencyAuthority is Ownable {

    /// @dev Set reference to TokenIOLib interface which proxies to TokenIOStorage */
    using TokenIOLib for TokenIOLib.Data;
    TokenIOLib.Data lib;

    /**
     * @notice Constructor method for CurrencyAuthority contract
     * @param _storageContract Address of TokenIOStorage contract
     */
    constructor(address _storageContract) public {
        /**
         * @notice Set the storage contract for the interface
         * @dev This contract will be unable to use the storage constract until
         * @dev Contract address is authorized with the storage contract
         */
        lib.Storage = TokenIOStorage(_storageContract);

        // @dev set owner to contract initiator
        owner[msg.sender] = true;
    }

    /**
     * @notice Gets balance of sepcified account for a given currency
     * @param currency Currency symbol 'USDx'
     * @param account Sepcified account address
     * @return { "balance": "Returns account balance"}
     */
    function getTokenBalance(string currency, address account) public view returns (uint balance) {
      return lib.getTokenBalance(currency, account);
    }

    /**
     * @notice Gets total supply of specified currency
     * @param currency Currency symbol 'USDx'
     * @return { "supply": "Returns total supply of currency"}
     */
    function getTokenSupply(string currency) public view returns (uint supply) {
      return lib.getTokenSupply(currency);
    }

    /**
     * @notice Updates account status. false: frozen, true: un-frozen
     * @param account Sepcified account address
     * @param isAllowed Frozen status
     * @param issuerFirm Name of the issuer firm with authority on account holder;
     * @return { "success": "Returns true if successfully called from another contract"}
     */
    function freezeAccount(address account, bool isAllowed, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool success) {
        // @notice updates account status
        // @dev !!! mutates storage state
        require(lib.setAccountStatus(account, isAllowed, issuerFirm));
        return true;
    }

    /**
     * @notice Sets approval status of specified account
     * @param account Sepcified account address
     * @param isApproved Frozen status
     * @param issuerFirm Name of the issuer firm with authority on account holder;
     * @return { "success": "Returns true if successfully called from another contract"}
     */
    function approveKYC(address account, bool isApproved, uint limit, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool success) {
        // @notice updates kyc approval status
        // @dev !!! mutates storage state
        require(lib.setKYCApproval(account, isApproved, issuerFirm));
        // @notice updates account statuss
        // @dev !!! mutates storage state
        require(lib.setAccountStatus(account, isApproved, issuerFirm));
        require(lib.setAccountSpendingLimit(account, limit));
        require(lib.setAccountSpendingPeriod(account, (now + 86400)));
        return true;
    }

    /**
     * @notice Approves account and deposits specified amount of given currency
     * @param currency Currency symbol of amount to be deposited;
     * @param account Ethereum address of account holder;
     * @param amount Deposit amount for account holder;
     * @param issuerFirm Name of the issuer firm with authority on account holder;
     * @return { "success": "Returns true if successfully called from another contract"}
     */
    function approveKYCAndDeposit(string currency, address account, uint amount, uint limit, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool success) {
        /// @notice updates kyc approval status
        /// @dev !!! mutates storage state
        require(lib.setKYCApproval(account, true, issuerFirm));
        /// @notice updates kyc approval status
        /// @dev !!! mutates storage state
        require(lib.setAccountStatus(account, true, issuerFirm));
        require(lib.deposit(currency, account, amount, issuerFirm));
        require(lib.setAccountSpendingLimit(account, limit));
        require(lib.setAccountSpendingPeriod(account, (now + 86400)));
        return true;
    }

    /**
     * @notice Sets the spending limit for a given account
     * @param account Ethereum address of account holder;
     * @param limit Spending limit amount for account;
     * @param issuerFirm Name of the issuer firm with authority on account holder;
     * @return { "success": "Returns true if successfully called from another contract"}
     */
    function setAccountSpendingLimit(address account, uint limit, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool success) {
      require(lib.setAccountSpendingLimit(account, limit));
      return true;
    }

    /**
     * @notice Returns the periodic remaining spending amount for an account
     * @param  account Ethereum address of account holder;
     * @return {"spendingRemaining" : "Returns the remaining spending amount for the account"}
     */
    function getAccountSpendingRemaining(address account) public view returns (uint spendingRemaining) {
      return lib.getAccountSpendingRemaining(account);
    }

    /**
     * @notice Return the spending limit for an account
     * @param  account Ethereum address of account holder
     * @return {"spendingLimit" : "Returns the remaining daily spending limit of the account"}
     */
    function getAccountSpendingLimit(address account) public view returns (uint spendingLimit) {
      return lib.getAccountSpendingLimit(account);
    }

    /**
     * @notice Set the foreign currency exchange rate to USD in basis points
     * @dev NOTE: This value should always be relative to USD pair; e.g. JPY/USD, GBP/USD, etc.
     * @param currency The TokenIO currency symbol (e.g. USDx, JPYx, GBPx)
     * @param bpsRate Basis point rate of foreign currency exchange rate to USD
     * @param issuerFirm Firm setting the foreign currency exchange
     * @return { "success": "Returns true if successfully called from another contract"}
     */
    function setFxBpsRate(string currency, uint bpsRate, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool success) {
      require(lib.setFxUSDBPSRate(currency, bpsRate));
      return true;
    }

    /**
     * @notice Return the foreign currency USD exchanged amount
     * @param currency The TokenIO currency symbol (e.g. USDx, JPYx, GBPx)
     * @param fxAmount Amount of foreign currency to exchange into USD
     * @return {"usdAmount" : "Returns the foreign currency amount in USD"}
     */
    function getFxUSDAmount(string currency, uint fxAmount) public view returns (uint usdAmount) {
      return lib.getFxUSDAmount(currency, fxAmount);
    }

    /**
     * @notice Updates to new forwarded account
     * @param originalAccount [address]
     * @param updatedAccount [address]
     * @param issuerFirm Name of the issuer firm with authority on account holder;
     * @return { "success": "Returns true if successfully called from another contract"}
     */
    function approveForwardedAccount(address originalAccount, address updatedAccount, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool success) {
        // @notice updatesa forwarded account
        // @dev !!! mutates storage state
        require(lib.setForwardedAccount(originalAccount, updatedAccount));
        return true;
    }

    /**
     * @notice Issues a specified account to recipient account of a given currency
     * @param currency [string] currency symbol
     * @param amount [uint] issuance amount
     * @param issuerFirm Name of the issuer firm with authority on account holder;
     * @return { "success": "Returns true if successfully called from another contract"}
     */
    function deposit(string currency, address account, uint amount, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool success) {
        require(lib.verifyAccount(account));
        // @notice depositing tokens to account
        // @dev !!! mutates storage state
        require(lib.deposit(currency, account, amount, issuerFirm));
        return true;
    }

    /**
     * @notice Withdraws a specified amount of tokens of a given currency
     * @param currency Currency symbol
     * @param account Ethereum address of account holder
     * @param amount Issuance amount
     * @param issuerFirm Name of the issuer firm with authority on account holder
     * @return { "success": "Returns true if successfully called from another contract"}
     */
    function withdraw(string currency, address account, uint amount, string issuerFirm) public onlyAuthority(issuerFirm, msg.sender) returns (bool success) {
        require(lib.verifyAccount(account));
        // @notice withdrawing from account
        // @dev !!! mutates storage state
        require(lib.withdraw(currency, account, amount, issuerFirm));
        return true;
    }

    /**
     * @notice Ensure only authorized currency firms and authorities can modify protected methods
     * @dev authority must be registered to an authorized firm to use protected methods
     */
    modifier onlyAuthority(string _firmName, address _authority) {
        // @notice throws if authority account is not registred to the given firm
        require(lib.isRegisteredToFirm(_firmName, _authority));
        _;
    }

}
