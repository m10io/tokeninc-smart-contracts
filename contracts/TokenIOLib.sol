pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;


/**
COPYRIGHT 2018 Token, Inc.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


@title TokenIOLib

@author Ryan Tate <ryan.michael.tate@gmail.com>, Sean Pollock <seanpollock3344@gmail.com>

@notice This library proxies the TokenIOStorage contract for the interface contract,
allowing the library and the interfaces to remain stateless, and share a universally
available storage contract between interfaces.


*/


import "./SafeMath.sol";
import "./TokenIOStorage.sol";


library TokenIOLib {

  /// @dev all math operating are using SafeMath methods to check for overflow/underflows
  using SafeMath for uint;

  /// @dev the Data struct uses the Storage contract for stateful setters
  struct Data {
    TokenIOStorage Storage;
  }

  event LogApproval(address indexed owner, address indexed spender, uint amount);
  event LogDeposit(string currency, address indexed account, uint amount, string issuerFirm);
  event LogWithdraw(string currency, address indexed account, uint amount, string issuerFirm);
  event LogTransfer(string currency, address indexed from, address indexed to, uint amount, bytes data);
  event LogKYCApproval(address indexed account, bool status, string issuerFirm);
  event LogAccountStatus(address indexed account, bool status, string issuerFirm);
  event LogFxSwap(string tokenASymbol,string tokenBSymbol,uint tokenAValue,uint tokenBValue, uint expiration, bytes32 transactionHash);
  event LogAccountForward(address indexed originalAccount, address indexed forwardedAccount);
  event LogNewAuthority(address indexed authority, string issuerFirm);

  /**
   * @notice Set the token name for Token interfaces
   * @dev This method must be set by the token interface's setParams() method
   * @dev NOTE: This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param tokenName Name of the token contract
   * @return {"success" : "Returns true when successfully called from another contract"}
   */
  function setTokenName(Data storage self, string tokenName) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('token.name', address(this)));
    self.Storage.setString(id, tokenName);
    return true;
  }

  /**
   * @notice Set the token symbol for Token interfaces
   * @dev This method must be set by the token interface's setParams() method
   * @dev NOTE: This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param tokenSymbol Symbol of the token contract
   * @return {"success" : "Returns true when successfully called from another contract"}
   */
  function setTokenSymbol(Data storage self, string tokenSymbol) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('token.symbol', address(this)));
    self.Storage.setString(id, tokenSymbol);
    return true;
  }

  /**
   * @notice Set the token three letter abreviation (TLA) for Token interfaces
   * @dev This method must be set by the token interface's setParams() method
   * @dev NOTE: This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param tokenTLA TLA of the token contract
   * @return {"success" : "Returns true when successfully called from another contract"}
   */
  function setTokenTLA(Data storage self, string tokenTLA) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('token.tla', address(this)));
    self.Storage.setString(id, tokenTLA);
    return true;
  }

  /**
   * @notice Set the token version for Token interfaces
   * @dev This method must be set by the token interface's setParams() method
   * @dev NOTE: This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param tokenVersion Semantic (vMAJOR.MINOR.PATCH | e.g. v0.1.0) version of the token contract
   * @return {"success" : "Returns true when successfully called from another contract"}
   */
  function setTokenVersion(Data storage self, string tokenVersion) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('token.version', address(this)));
    self.Storage.setString(id, tokenVersion);
    return true;
  }

  /**
   * @notice Set the token decimals for Token interfaces
   * @dev This method must be set by the token interface's setParams() method
   * @dev NOTE: This method has an `internal` view
   * @dev This method is not set to the address of the contract, rather is maped to currency
   * @dev To derive decimal value, divide amount by 10^decimal representation (e.g. 10132 / 10**2 == 101.32)
   * @param self Internal storage proxying TokenIOStorage contract
   * @param currency TokenIO TSM currency symbol (e.g. USDx)
   * @param tokenDecimals Decimal representation of the token contract unit amount
   * @return {"success" : "Returns true when successfully called from another contract"}
   */
  function setTokenDecimals(Data storage self, string currency, uint tokenDecimals) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('token.decimals', currency));
    self.Storage.setUint(id, tokenDecimals);
    return true;
  }

  /**
   * @notice Set basis point fee for contract interface
   * @dev Transaction fees can be set by the TokenIOFeeContract
   * @dev Fees vary by contract interface specified `feeContract`
   * @dev NOTE: This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param feeBPS Basis points fee for interface contract transactions
   * @return {"success" : "Returns true when successfully called from another contract"}
   */
  function setFeeBPS(Data storage self, uint feeBPS) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('fee.bps', address(this)));
    self.Storage.setUint(id, feeBPS);
    return true;
  }

  /**
   * @notice Set minimum fee for contract interface
   * @dev Transaction fees can be set by the TokenIOFeeContract
   * @dev Fees vary by contract interface specified `feeContract`
   * @dev NOTE: This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param feeMin Minimum fee for interface contract transactions
   * @return {"success" : "Returns true when successfully called from another contract"}
   */
  function setFeeMin(Data storage self, uint feeMin) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('fee.min', address(this)));
    self.Storage.setUint(id, feeMin);
    return true;
  }

  /**
   * @notice Set maximum fee for contract interface
   * @dev Transaction fees can be set by the TokenIOFeeContract
   * @dev Fees vary by contract interface specified `feeContract`
   * @dev NOTE: This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param feeMax Maximum fee for interface contract transactions
   * @return {"success" : "Returns true when successfully called from another contract"}
   */
  function setFeeMax(Data storage self, uint feeMax) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('fee.max', address(this)));
    self.Storage.setUint(id, feeMax);
    return true;
  }

  /**
   * @notice Set flat fee for contract interface
   * @dev Transaction fees can be set by the TokenIOFeeContract
   * @dev Fees vary by contract interface specified `feeContract`
   * @dev NOTE: This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param feeFlat Flat fee for interface contract transactions
   * @return {"success" : "Returns true when successfully called from another contract"}
   */
  function setFeeFlat(Data storage self, uint feeFlat) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('fee.flat', address(this)));
    self.Storage.setUint(id, feeFlat);
    return true;
  }

  /**
   * @notice Set fee contract for a contract interface
   * @dev feeContract must be a TokenIOFeeContract storage approved contract
   * @dev Fees vary by contract interface specified `feeContract`
   * @dev NOTE: This method has an `internal` view
   * @dev NOTE: This must be called directly from the interface contract
   * @param self Internal storage proxying TokenIOStorage contract
   * @param feeContract Set the fee contract for `this` contract address interface
   * @return {"success" : "Returns true when successfully called from another contract"}
   */
  function setFeeContract(Data storage self, address feeContract) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('fee.account', address(this)));
    self.Storage.setAddress(id, feeContract);
    return true;
  }

  /**
   * @notice Set contract interface associated with a given TokenIO currency symbol (e.g. USDx)
   * @dev NOTE: This should only be called once from a token interface contract;
   * @dev NOTE: This method has an `internal` view
   * @dev NOTE: This method is experimental and may be deprecated/refactored
   * @param self Internal storage proxying TokenIOStorage contract
   * @param currency TokenIO TSM currency symbol (e.g. USDx)
   * @return {"success" : "Returns true when successfully called from another contract"}
   */
  function setTokenNameSpace(Data storage self, string currency) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('token.namespace', currency));
    self.Storage.setAddress(id, address(this));
    return true;
  }

  /**
   * @notice Set the KYC approval status (true/false) for a given account
   * @dev NOTE: This method has an `internal` view
   * @dev NOTE: Every account must be KYC'd to be able to use transfer() & transferFrom() methods
   * @dev NOTE: To gain approval for an account, register at https://tsm.token.io/sign-up
   * @param self Internal storage proxying TokenIOStorage contract
   * @param account Ethereum address of account holder
   * @param isApproved Boolean (true/false) KYC approval status for a given account
   * @param issuerFirm Firm name for issuing KYC approval
   * @return {"success" : "Returns true when successfully called from another contract"}
   */
  function setKYCApproval(Data storage self, address account, bool isApproved, string issuerFirm) internal returns (bool success) {
      bytes32 id = keccak256(abi.encodePacked('account.kyc', getForwardedAccount(self, account)));
      self.Storage.setBool(id, isApproved);

      /// @dev NOTE: Issuer is logged for setting account KYC status
      emit LogKYCApproval(account, isApproved, issuerFirm);
      return true;
  }

  /**
   * @notice Set the global approval status (true/false) for a given account
   * @dev NOTE: This method has an `internal` view
   * @dev NOTE: Every account must be permitted to be able to use transfer() & transferFrom() methods
   * @dev NOTE: To gain approval for an account, register at https://tsm.token.io/sign-up
   * @param self Internal storage proxying TokenIOStorage contract
   * @param account Ethereum address of account holder
   * @param isAllowed Boolean (true/false) global status for a given account
   * @param issuerFirm Firm name for issuing approval
   * @return {"success" : "Returns true when successfully called from another contract"}
   */
  function setAccountStatus(Data storage self, address account, bool isAllowed, string issuerFirm) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('account.allowed', getForwardedAccount(self, account)));
    self.Storage.setBool(id, isAllowed);

    /// @dev NOTE: Issuer is logged for setting account status
    emit LogAccountStatus(account, isAllowed, issuerFirm);
    return true;
  }


  /**
   * @notice Set a forwarded address for an account.
   * @dev NOTE: This method has an `internal` view
   * @dev NOTE: Forwarded accounts must be set by an authority in case of account recovery;
   * @dev NOTE: Additionally, the original owner can set a forwarded account (e.g. add a new device, spouse, dependent, etc)
   * @dev NOTE: All transactions will be logged under the same KYC information as the original account holder;
   * @param self Internal storage proxying TokenIOStorage contract
   * @param originalAccount Original registered Ethereum address of the account holder
   * @param forwardedAccount Forwarded Ethereum address of the account holder
   * @return {"success" : "Returns true when successfully called from another contract"}
   */
  function setForwardedAccount(Data storage self, address originalAccount, address forwardedAccount) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('master.account', forwardedAccount));
    self.Storage.setAddress(id, originalAccount);
    return true;
  }

  /**
   * @notice Get the original address for a forwarded account
   * @dev NOTE: This method has an `internal` view
   * @dev NOTE: Will return the registered account for the given forwarded account
   * @param self Internal storage proxying TokenIOStorage contract
   * @param account Ethereum address of account holder
   * @return { "registeredAccount" : "Will return the original account of a forwarded account or the account itself if no account found"}
   */
  function getForwardedAccount(Data storage self, address account) internal view returns (address registeredAccount) {
    bytes32 id = keccak256(abi.encodePacked('master.account', account));
    address originalAccount = self.Storage.getAddress(id);
    if (originalAccount != 0x0) {
      return originalAccount;
    } else {
      return account;
    }
  }

  /**
   * @notice Get KYC approval status for the account holder
   * @dev NOTE: This method has an `internal` view
   * @dev NOTE: All forwarded accounts will use the original account's status
   * @param self Internal storage proxying TokenIOStorage contract
   * @param account Ethereum address of account holder
   * @return { "status" : "Returns the KYC approval status for an account holder" }
   */
  function getKYCApproval(Data storage self, address account) internal view returns (bool status) {
      bytes32 id = keccak256(abi.encodePacked('account.kyc', getForwardedAccount(self, account)));
      return self.Storage.getBool(id);
  }

  /**
   * @notice Get global approval status for the account holder
   * @dev NOTE: This method has an `internal` view
   * @dev NOTE: All forwarded accounts will use the original account's status
   * @param self Internal storage proxying TokenIOStorage contract
   * @param account Ethereum address of account holder
   * @return { "status" : "Returns the global approval status for an account holder" }
   */
  function getAccountStatus(Data storage self, address account) internal view returns (bool status) {
    bytes32 id = keccak256(abi.encodePacked('account.allowed', getForwardedAccount(self, account)));
    return self.Storage.getBool(id);
  }

  /**
   * @notice Get the contract interface address associated with token symbol
   * @dev NOTE: This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param currency TokenIO TSM currency symbol (e.g. USDx)
   * @return { "contractAddress" : "Returns the contract interface address for a symbol" }
   */
  function getTokenNameSpace(Data storage self, string currency) internal view returns (address contractAddress) {
    bytes32 id = keccak256(abi.encodePacked('token.namespace', currency));
    return self.Storage.getAddress(id);
  }

  /**
   * @notice Get the token name for Token interfaces
   * @dev This method must be set by the token interface's setParams() method
   * @dev NOTE: This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param contractAddress Contract address of the queryable interface
   * @return {"tokenName" : "Name of the token contract"}
   */
  function getTokenName(Data storage self, address contractAddress) internal view returns (string tokenName) {
    bytes32 id = keccak256(abi.encodePacked('token.name', contractAddress));
    return self.Storage.getString(id);
  }

  /**
   * @notice Get the token symbol for Token interfaces
   * @dev This method must be set by the token interface's setParams() method
   * @dev NOTE: This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param contractAddress Contract address of the queryable interface
   * @return {"tokenSymbol" : "Symbol of the token contract"}
   */
  function getTokenSymbol(Data storage self, address contractAddress) internal view returns (string tokenSymbol) {
    bytes32 id = keccak256(abi.encodePacked('token.symbol', contractAddress));
    return self.Storage.getString(id);
  }

  /**
   * @notice Get the token Three letter abbreviation (TLA) for Token interfaces
   * @dev This method must be set by the token interface's setParams() method
   * @dev NOTE: This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param contractAddress Contract address of the queryable interface
   * @return {"tokenTLA" : "TLA of the token contract"}
   */
  function getTokenTLA(Data storage self, address contractAddress) internal view returns (string tokenTLA) {
    bytes32 id = keccak256(abi.encodePacked('token.tla', contractAddress));
    return self.Storage.getString(id);
  }

  /**
   * @notice Get the token version for Token interfaces
   * @dev This method must be set by the token interface's setParams() method
   * @dev NOTE: This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param contractAddress Contract address of the queryable interface
   * @return {"tokenVersion" : "Semantic version of the token contract"}
   */
  function getTokenVersion(Data storage self, address contractAddress) internal view returns (string) {
    bytes32 id = keccak256(abi.encodePacked('token.version', contractAddress));
    return self.Storage.getString(id);
  }

  /**
   * @notice Get the token decimals for Token interfaces
   * @dev This method must be set by the token interface's setParams() method
   * @dev NOTE: This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param currency TokenIO TSM currency symbol (e.g. USDx)
   * @return {"tokenDecimals" : "Decimals of the token contract"}
   */
  function getTokenDecimals(Data storage self, string currency) internal view returns (uint tokenDecimals) {
    bytes32 id = keccak256(abi.encodePacked('token.decimals', currency));
    return self.Storage.getUint(id);
  }

  /**
   * @notice Get the basis points fee of the contract address; typically TokenIOFeeContract
   * @dev NOTE: This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param contractAddress Contract address of the queryable interface
   * @return { "feeBps" : "Returns the basis points fees associated with the contract address"}
   */
  function getFeeBPS(Data storage self, address contractAddress) internal view returns (uint feeBps) {
    bytes32 id = keccak256(abi.encodePacked('fee.bps', contractAddress));
    return self.Storage.getUint(id);
  }

  /**
   * @notice Get the minimum fee of the contract address; typically TokenIOFeeContract
   * @dev NOTE: This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param contractAddress Contract address of the queryable interface
   * @return { "feeMin" : "Returns the minimum fees associated with the contract address"}
   */
  function getFeeMin(Data storage self, address contractAddress) internal view returns (uint feeMin) {
    bytes32 id = keccak256(abi.encodePacked('fee.min', contractAddress));
    return self.Storage.getUint(id);
  }

  /**
   * @notice Get the maximum fee of the contract address; typically TokenIOFeeContract
   * @dev NOTE: This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param contractAddress Contract address of the queryable interface
   * @return { "feeMax" : "Returns the maximum fees associated with the contract address"}
   */
  function getFeeMax(Data storage self, address contractAddress) internal view returns (uint feeMax) {
    bytes32 id = keccak256(abi.encodePacked('fee.max', contractAddress));
    return self.Storage.getUint(id);
  }

  /**
   * @notice Get the flat fee of the contract address; typically TokenIOFeeContract
   * @dev NOTE: This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param contractAddress Contract address of the queryable interface
   * @return { "feeFlat" : "Returns the flat fees associated with the contract address"}
   */
  function getFeeFlat(Data storage self, address contractAddress) internal view returns (uint feeFlat) {
    bytes32 id = keccak256(abi.encodePacked('fee.flat', contractAddress));
    return self.Storage.getUint(id);
  }

  /**
   * @notice Set the master fee contract used as the default fee contract when none is provided
   * @dev NOTE: This method has an `internal` view
   * @dev NOTE: This value is set in the TokenIOAuthority contract
   * @param self Internal storage proxying TokenIOStorage contract
   * @param contractAddress Contract address of the queryable interface
   * @return { "success" : "Returns true when successfully called from another contract"}
   */
  function setMasterFeeContract(Data storage self, address contractAddress) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('fee.contract.master'));
    require(self.Storage.setAddress(id, contractAddress));
    return true;
  }

  /**
   * @notice Get the master fee contract set via the TokenIOAuthority contract
   * @dev NOTE: This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @return { "masterFeeContract" : "Returns the master fee contract set for TSM."}
   */
  function getMasterFeeContract(Data storage self) internal view returns (address masterFeeContract) {
    bytes32 id = keccak256(abi.encodePacked('fee.contract.master'));
    return self.Storage.getAddress(id);
  }

  /**
   * @notice Get the fee contract set for a contract interface
   * @dev NOTE: This method has an `internal` view
   * @dev NOTE: Custom fee pricing can be set by assigning a fee contract to transactional contract interfaces
   * @dev NOTE: If a fee contract has not been set by an interface contract, then the master fee contract will be returned
   * @param self Internal storage proxying TokenIOStorage contract
   * @param contractAddress Contract address of the queryable interface
   * @return { "feeContract" : "Returns the fee contract associated with a contract interface"}
   */
  function getFeeContract(Data storage self, address contractAddress) internal view returns (address feeContract) {
    bytes32 id = keccak256(abi.encodePacked('fee.account', contractAddress));

    address feeAccount = self.Storage.getAddress(id);
    if (feeAccount == 0x0) {
      return getMasterFeeContract(self);
    } else {
      return feeAccount;
    }
  }

  /**
   * @notice Get the token supply for a given TokenIO TSM currency symbol (e.g. USDx)
   * @dev NOTE: This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param currency TokenIO TSM currency symbol (e.g. USDx)
   * @return { "supply" : "Returns the token supply of the given currency"}
   */
  function getTokenSupply(Data storage self, string currency) internal view returns (uint supply) {
    bytes32 id = keccak256(abi.encodePacked('token.supply', currency));
    return self.Storage.getUint(id);
  }

  /**
   * @notice Get the token spender allowance for a given account
   * @dev NOTE: This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param account Ethereum address of account holder
   * @param spender Ethereum address of spender
   * @return { "allowance" : "Returns the allowance of a given spender for a given account"}
   */
  function getTokenAllowance(Data storage self, string currency, address account, address spender) internal view returns (uint allowance) {
    bytes32 id = keccak256(abi.encodePacked('token.allowance', currency, getForwardedAccount(self, account), getForwardedAccount(self, spender)));
    return self.Storage.getUint(id);
  }

  /**
   * @notice Get the token balance for a given account
   * @dev NOTE: This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param currency TokenIO TSM currency symbol (e.g. USDx)
   * @param account Ethereum address of account holder
   * @return { "balance" : "Return the balance of a given account for a specified currency"}
   */
  function getTokenBalance(Data storage self, string currency, address account) internal view returns (uint balance) {
    bytes32 id = keccak256(abi.encodePacked('token.balance', currency, getForwardedAccount(self, account)));
    return self.Storage.getUint(id);
  }

  /**
   * @notice Get the frozen token balance for a given account
   * @dev NOTE: This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param currency TokenIO TSM currency symbol (e.g. USDx)
   * @param account Ethereum address of account holder
   * @return { "frozenBalance" : "Return the frozen balance of a given account for a specified currency"}
   */
  function getTokenFrozenBalance(Data storage self, string currency, address account) internal view returns (uint frozenBalance) {
    bytes32 id = keccak256(abi.encodePacked('token.frozen', currency, getForwardedAccount(self, account)));
    return self.Storage.getUint(id);
  }

  /**
   * @notice Set the frozen token balance for a given account
   * @dev NOTE: This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param currency TokenIO TSM currency symbol (e.g. USDx)
   * @param account Ethereum address of account holder
   * @param amount Amount of tokens to freeze for account
   * @return { "success" : "Return true if successfully called from another contract"}
   */
  function setTokenFrozenBalance(Data storage self, string currency, address account, uint amount) internal view returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('token.frozen', currency, getForwardedAccount(self, account)));
    require(self.Storage.setUint(id, amount));
    return true;
  }

  /**
   * @notice Set the frozen token balance for a given account
   * @dev NOTE: This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param contractAddress Contract address of the fee contract
   * @param amount Transaction value
   * @return { "calculatedFees" : "Return the calculated transaction fees for a given amount and fee contract" }
   */
  function calculateFees(Data storage self, address contractAddress, uint amount) internal view returns (uint calculatedFees) {

    uint maxFee = self.Storage.getUint(keccak256(abi.encodePacked('fee.max', contractAddress)));
    uint minFee = self.Storage.getUint(keccak256(abi.encodePacked('fee.min', contractAddress)));
    uint bpsFee = self.Storage.getUint(keccak256(abi.encodePacked('fee.bps', contractAddress)));
    uint flatFee = self.Storage.getUint(keccak256(abi.encodePacked('fee.flat', contractAddress)));
    uint fees = ((amount.mul(bpsFee)).div(10000)).add(flatFee);

    if (fees > maxFee) {
      return maxFee;
    } else if (fees < minFee) {
      return minFee;
    } else {
      return fees;
    }
  }

  /**
   * @notice Verified KYC and global status for two accounts and return true or throw if either account is not verified
   * @dev NOTE: This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param accountA Ethereum address of first account holder to verify
   * @param accountB Ethereum address of second account holder to verify
   * @return { "verified" : "Returns true if both accounts are successfully verified" }
   */
  function verifyAccounts(Data storage self, address accountA, address accountB) internal returns (bool verified) {
    require(verifyAccount(self, accountA));
    require(verifyAccount(self, accountB));
    return true;
  }

  /**
   * @notice Verified KYC and global status for a single account and return true or throw if account is not verified
   * @dev NOTE: This method has an `internal` view
   * @param self Internal storage proxying TokenIOStorage contract
   * @param account Ethereum address of account holder to verify
   * @return { "verified" : "Returns true if account is successfully verified" }
   */
  function verifyAccount(Data storage self, address account) internal returns (bool verified) {
    require(getKYCApproval(self, account));
    require(getAccountStatus(self, account));
    return true;
  }


  function transfer(Data storage self, string currency, address to, uint amount, bytes data) internal returns (bool success) {
    require(address(to) != 0x0);

    /* string memory currency = getTokenSymbol(self, address(this)); */
    address feeContract = getFeeContract(self, address(this));
    uint fees = calculateFees(self, feeContract, amount);
    require(setAccountSpendingAmount(self, msg.sender, getFxUSDAmount(self, currency, amount)));
    require(forceTransfer(self, currency, msg.sender, to, amount, data));
    require(forceTransfer(self, currency, msg.sender, feeContract, fees, "0x747846656573"));

    return true;
  }

  function transferFrom(Data storage self, string currency, address from, address to, uint amount, bytes data) internal returns (bool success) {
    require(address(to) != 0x0);

    address feeContract = getFeeContract(self, address(this));
    uint fees = calculateFees(self, feeContract, amount);
    /* string memory currency = getTokenSymbol(self, address(this)); */

    require(setAccountSpendingAmount(self, from, getFxUSDAmount(self, currency, amount)));
    require(forceTransfer(self, currency, from, to, amount, data));
    require(forceTransfer(self, currency, from, feeContract, fees, "0x747846656573"));
    require(updateAllowance(self, currency, from, amount));

    return true;
  }

  function forceTransfer(Data storage self, string currency, address from, address to, uint amount, bytes data) internal returns (bool success) {
    require(address(to) != 0x0);

    bytes32 id_a = keccak256(abi.encodePacked('token.balance', currency, getForwardedAccount(self, from)));
    bytes32 id_b = keccak256(abi.encodePacked('token.balance', currency, getForwardedAccount(self, to)));

    require(self.Storage.setUint(id_a, self.Storage.getUint(id_a).sub(amount)));
    require(self.Storage.setUint(id_b, self.Storage.getUint(id_b).add(amount)));

    emit LogTransfer(currency, from, to, amount, data);

    return true;
  }

  function updateAllowance(Data storage self, string currency, address account, uint amount) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('token.allowance', currency, getForwardedAccount(self, account), getForwardedAccount(self, msg.sender)));
    require(self.Storage.setUint(id, self.Storage.getUint(id).sub(amount)));
    return true;
  }

  function approve(Data storage self, address spender, uint amount) internal returns (bool success) {
    string memory currency = getTokenSymbol(self, address(this));

    bytes32 id_a = keccak256(abi.encodePacked('token.allowance', currency, getForwardedAccount(self, msg.sender), getForwardedAccount(self, spender)));
    bytes32 id_b = keccak256(abi.encodePacked('token.balance', currency, getForwardedAccount(self, msg.sender)));

    require(self.Storage.getUint(id_a) == 0 || amount == 0);
    require(self.Storage.getUint(id_b) >= amount);
    require(self.Storage.setUint(id_a, amount));

    emit LogApproval(msg.sender, spender, amount);

    return true;
  }

  function deposit(Data storage self, string currency, address account, uint amount, string issuerFirm) internal returns (bool success) {
    bytes32 id_a = keccak256(abi.encodePacked('token.balance', currency, getForwardedAccount(self, account)));
    bytes32 id_b = keccak256(abi.encodePacked('token.issued', currency, issuerFirm));
    bytes32 id_c = keccak256(abi.encodePacked('token.supply', currency));


    require(self.Storage.setUint(id_a, self.Storage.getUint(id_a).add(amount)));
    require(self.Storage.setUint(id_b, self.Storage.getUint(id_b).add(amount)));
    require(self.Storage.setUint(id_c, self.Storage.getUint(id_c).add(amount)));

    emit LogDeposit(currency, account, amount, issuerFirm);

    return true;

  }

  function withdraw(Data storage self, string currency, address account, uint amount, string issuerFirm) internal returns (bool success) {
    bytes32 id_a = keccak256(abi.encodePacked('token.balance', currency, getForwardedAccount(self, account)));
    bytes32 id_b = keccak256(abi.encodePacked('token.issued', currency, issuerFirm)); // possible for issuer to go negative
    bytes32 id_c = keccak256(abi.encodePacked('token.supply', currency));

    require(self.Storage.setUint(id_a, self.Storage.getUint(id_a).sub(amount)));
    require(self.Storage.setUint(id_b, self.Storage.getUint(id_b).sub(amount)));
    require(self.Storage.setUint(id_c, self.Storage.getUint(id_c).sub(amount)));

    emit LogWithdraw(currency, account, amount, issuerFirm);

    return true;

  }

  function setRegisteredFirm(Data storage self, string _firmName, bool _authorized) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('registered.firm', _firmName));
    require(self.Storage.setBool(id, _authorized));
    return true;
  }

  function setRegisteredAuthority(Data storage self, string _firmName, address _authority, bool _authorized) internal returns (bool success) {
    require(isRegisteredFirm(self, _firmName));
    bytes32 id_a = keccak256(abi.encodePacked('registered.authority', _firmName, _authority));
    bytes32 id_b = keccak256(abi.encodePacked('registered.authority.firm', _authority));

    require(self.Storage.setBool(id_a, _authorized));
    require(self.Storage.setString(id_b, _firmName));

    return true;
  }

  function getFirmFromAuthority(Data storage self, address _authority) internal view returns (string) {
    bytes32 id = keccak256(abi.encodePacked('registered.authority.firm', getForwardedAccount(self, _authority)));
    return self.Storage.getString(id);
  }

  function isRegisteredFirm(Data storage self, string _firmName) internal view returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('registered.firm', _firmName));
    return self.Storage.getBool(id);
  }

  function isRegisteredToFirm(Data storage self, string _firmName, address _authority) internal view returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('registered.authority', _firmName, getForwardedAccount(self, _authority)));
    return self.Storage.getBool(id);
  }

  function isRegisteredAuthority(Data storage self, address _authority) internal view returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('registered.authority', getFirmFromAuthority(self, getForwardedAccount(self, _authority)), getForwardedAccount(self, _authority)));
    return self.Storage.getBool(id);
  }

  function getTxStatus(Data storage self, bytes32 _txHash) internal view returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('tx.status', _txHash));
    return self.Storage.getBool(id);
  }

  function setTxStatus(Data storage self, bytes32 _txHash) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('tx.status', _txHash));
    require(self.Storage.setBool(id, true));
    return true;
  }

  function execSwap(
    Data storage self,
    address requester,
    string symbolA,
    string symbolB,
    uint valueA,
    uint valueB,
    uint8 sigV,
    bytes32 sigR,
    bytes32 sigS,
    uint expiration
  ) internal returns (bool success) {

    bytes32 fxTxHash = keccak256(abi.encodePacked(requester, symbolA, symbolB, valueA, valueB, expiration));
    require(verifyAccounts(self, msg.sender, requester));

    // Ensure transaction has not yet been used;
    require(!getTxStatus(self, fxTxHash));

    // Immediately set this transaction to be confirmed before updating any params;
    require(setTxStatus(self, fxTxHash));

    // Ensure contract has not yet expired;
    require(expiration >= now);

    // Recover the address of the signature from the hashed digest;
    // Ensure it equals the requester's address
    require(ecrecover(fxTxHash, sigV, sigR, sigS) == requester);

    // Transfer funds from each account to another.
    require(forceTransfer(self, symbolA, msg.sender, requester, valueA, "0x0"));
    require(forceTransfer(self, symbolB, requester, msg.sender, valueB, "0x0"));

    emit LogFxSwap(symbolA, symbolB, valueA, valueB, expiration, fxTxHash);

    return true;
  }

  function setDeprecatedContract(Data storage self, address contractAddress) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('depcrecated', contractAddress));
    require(self.Storage.setBool(id, true));
    return true;
  }

  function isContractDeprecated(Data storage self, address contractAddress) internal view returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('depcrecated', contractAddress));
    return self.Storage.getBool(id);
  }

  /**
   * @notice Set the Universal Spending Period Limit as UNIX timestamp for GMT Period
   * @dev This period is the same for all accounts and is updated monthly.
   * @param self Internal reference to library
   * @param period Update spending period for TSM system
   * @return {"success" : "Returns true is successfully called from interface contract"}
   */
  function setAccountSpendingPeriod(Data storage self, address account, uint period) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('limit.spending.period', account));
    require(self.Storage.setUint(id, period));
    return true;
  }

  function getAccountSpendingPeriod(Data storage self, address account) internal view returns (uint period) {
    bytes32 id = keccak256(abi.encodePacked('limit.spending.period', account));
    return self.Storage.getUint(id);
  }

  function setAccountSpendingLimit(Data storage self, address account, uint limit) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('account.spending.limit', account));
    require(self.Storage.setUint(id, limit));
    return true;
  }

  function getAccountSpendingLimit(Data storage self, address account) internal view returns (uint limit) {
    bytes32 id = keccak256(abi.encodePacked('account.spending.limit', account));
    return self.Storage.getUint(id);
  }

  function setAccountSpendingAmount(Data storage self, address account, uint amount) internal returns (bool success) {
    require(updateAccountSpendingPeriod(self, account));
    uint updatedAmount = getAccountSpendingAmount(self, account).add(amount);
    require(getAccountSpendingLimit(self, account) >= updatedAmount);
    bytes32 id = keccak256(abi.encodePacked('account.spending.amount', account, getAccountSpendingPeriod(self, account)));
    require(self.Storage.setUint(id, updatedAmount));
    return true;
  }

  function updateAccountSpendingPeriod(Data storage self, address account) internal returns (bool success) {
    uint begDate = getAccountSpendingPeriod(self, account);
    if (begDate > now) {
      return true;
    } else {
      uint period = 86400; // 86400 Seconds in a Day
      require(setAccountSpendingPeriod(self, account, begDate.add(((now.sub(begDate)).div(period).add(1)).mul(period))));
      return true;
    }
  }

  function getAccountSpendingAmount(Data storage self, address account) internal view returns (uint amount) {
    bytes32 id = keccak256(abi.encodePacked('account.spending.amount', account, getAccountSpendingPeriod(self, account)));
    return self.Storage.getUint(id);
  }

  function getAccountSpendingRemaining(Data storage self, address account) internal returns (uint remainingLimit) {
    return getAccountSpendingLimit(self, account).sub(getAccountSpendingAmount(self, account));
  }

  function setFxUSDBPSRate(Data storage self, string currency, uint bpsRate) internal returns (bool success) {
    bytes32 id = keccak256(abi.encodePacked('fx.usd.rate', currency));
    require(self.Storage.setUint(id, bpsRate));
    return true;
  }

  function getFxUSDBPSRate(Data storage self, string currency) internal view returns (uint amount) {
    bytes32 id = keccak256(abi.encodePacked('fx.usd.rate', currency));
    return self.Storage.getUint(id);
  }

  function getFxUSDAmount(Data storage self, string currency, uint fxAmount) internal view returns (uint usdAmount) {
    uint usdDecimals = getTokenDecimals(self, 'USDx');
    uint fxDecimals = getTokenDecimals(self, currency);
    return ((fxAmount.mul(getFxUSDBPSRate(self, currency)).div(10000)).mul(10**usdDecimals)).div(10**fxDecimals);
  }


}
