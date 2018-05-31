pragma solidity 0.4.24;


import "./SafeMath.sol";
import "./TokenIOStorage.sol";
import "./Ownable.sol";

/**
@title TokenIO - ERC20 Compliant Smart Contract for Token, Inc.

@author Ryan Tate <ryan.michael.tate@gmail.com>

@notice Contract uses generalized storage contract, `TokenIOStorage`, for
upgradeability of interface contract.

@dev In the event that the main contract becomes deprecated, the upgraded contract
will be set as the owner of this contract, and use this contract's storage to
maintain data consistency between contract.

*/
contract TokenIO is Ownable, TokenIOStorage {

  /// @ntoice Use SafeMath Library to guard against uint overflow / underflow operations
  using SafeMath for uint;

  /// @dev ERC20 Transfer Event
  event Transfer(address indexed from, address indexed to, uint amount);

  /// @dev Transfer With Data
  event TransferWithData(address indexed from, address indexed to, uint amount, bytes data);

  /// @dev ERC20 Approval Event
  event Approval(address indexed owner, address indexed spender, uint amount);

  /**
  * @dev Withdraw Event emitted when approved authority (contract owner)
  * receives an out-of-bound request to withdraw funds from the contract by
  * an account holder.
  */
  event Withdraw(address indexed owner, uint amount);

  /**
  * @dev Deposit Event emitted when funds have been deposited by the contract
  * owner.
  */
  event Deposit(address indexed owner, uint amount);

  /**
  * @dev Forbid event emitted when approved authority (contract owner)
  * restricts access to the contract for a specific account.
  */
  event Forbid(address indexed account, bool isForbidden);

  /**
  * @notice Constructor method for TokenIO contract
  * @param authority     address Establish authority as contract owner;
  * @param feeAccount    address Establish account to send tx fees to;
  * @param tokenName     string  Name of the TokenIO contract;
  * @param tokenSymbol   string  Symbol of the TokenIO contract;
  * @param tokenTLA      string  Three letter abbreviated currency code;
  * @param tokenVersion  string  Semantic versioning of TokenIO contract;
  * @param tokenDecimals uint    Decimal place representation of values;
  */
  constructor(
    address authority,
    address feeAccount,
    string tokenName,
    string tokenSymbol,
    string tokenTLA,
    string tokenVersion,
    uint tokenDecimals
    ) public {

      /**
      * @dev Authority Address is Multi-Signature Contract in production
      */
      owner[authority] = true;

      /**
      * @notice DEVELOPMENT ONLY
      * @dev msg.sender to be deprecated from being listed as contract owner;
      */
      owner[msg.sender] = true;

      /// @dev Set Global Variables using storage setters;
      super.setString(keccak256('token.name'), tokenName);
      super.setString(keccak256('token.symbol'), tokenSymbol);
      super.setString(keccak256('token.currencyTLA'), tokenTLA);
      super.setString(keccak256('token.version'), tokenVersion);

      /**
      * @dev Decimal places for contract are 2
      * NOTE: Increase this back to millicent (5 decimals places)?
      * Will allow for bps fees to be set on values less than 3
      */
      super.setUint(keccak256('token.decimals'), tokenDecimals);

      /// @notice Total supply is 0; Increases when funds are deposited to contract
      super.setUint(keccak256('token.totalSupply'), 0);

      /**
      * @dev NOTE: Consider Removing; can be set externally;
      * super.setString(keccak256('globalMessage'), "");
      * super.setBool(keccak256('paused', address(this)), false);
      */

      /// @dev Send fees to feeAccount
      super.setAddress(keccak256('feeAccount'), feeAccount);

      /**
      * @dev Set global fee parameters
      * NOTE: Consider removing fee.min ?
      */
      super.setUint(keccak256('fee.min'), 0); // min fee 0 USD);
      super.setUint(keccak256('fee.max'), 100 * 10**tokenDecimals); // max fee 100 USD
      super.setUint(keccak256('fee.bps'), 2); // bps 0.02%
      super.setUint(keccak256('fee.flat'), 2); // $.02 USD flat fee;
    }

    /**
    * @notice Calculate fees based on amount value;
    * @dev Fee values are set in the constructor, but may be updated via storage
    * methods. `1 USD == 1 * 10**2`
    * @param  amount uint Amount represented in expanded decimal form
    * @return fees 	 uint Returns fees in expanded decimal form
    */
    function calculateFees(uint amount) public view returns (uint) {

      /// @dev Set upper limit on fees;
      uint maxFee = super.getUint(keccak256('fee.max'));

      /// @dev On values less than 3, bpsFee will round down to 0;
      uint bpsFee = super.getUint(keccak256('fee.bps'));

      /// @dev Provide flat fee for all values;
      uint flatFee = super.getUint(keccak256('fee.flat'));

      /// @dev Calculate basis point fees plus flat fee;
      uint fees = ((amount.mul(bpsFee)).div(10000)).add(flatFee);

      /// @dev Return maxFee if calculated fees exceed max value;
      if (fees > maxFee) {
        return maxFee;
        } else {
          return fees;
        }
      }

      /**
      * @notice The total supply of funds deposited to the contract;
      * @dev Total supply only increases when funds are deposited to the contract;
      * @dev ERC20 compliant method;
      * @return uint Return total supply;
      */
      function totalSupply() public view returns (uint) {
        /// @notice Return token total supply from storage getter;
        return super.getUint(keccak256('token.totalSupply'));
      }

      /**
      * @notice Name of the token contract
      * @return string Name of contract
      */
      function name() public view returns (string) {
        /// @dev Return token name from storage getter;
        return super.getString(keccak256('token.name'));
      }

      /**
      * @notice Symbol of the token contract
      * @return string Returns symbol
      */
      function symbol() public view returns (string) {
        /// @dev Return token symbol from storage getter;
        return super.getString(keccak256('token.symbol'));
      }

      /**
      * @notice Decimal representation for token
      * @dev Adjust values for decimal representation when displaying on UI
      * e.g. `decimals = 2; 1000 / 10**decimals == 10;`
      * @return uint Return token contract decimals
      */
      function decimals() public view returns (uint) {
        /// @dev Return token decimals from storage getter;
        return super.getUint(keccak256('token.decimals'));
      }

      /**
      * @notice Return allowance of spender for account;
      * @param  owner 	 address Ethereum address of owner account;
      * @param  spender address Ethereum address of spending account;
      * @return uint						 Return allowance of spender for owner account;
      */
      function allowance(address owner, address spender) public view returns (uint) {
        /// @dev Return allowance limit for spender from storage getter;
        return super.getUint(keccak256('allowance', owner, spender));
      }

      /**
      * @notice Return balance of account owner;
      * @param  owner address Ethereum address of account owner;
      * @return uint          Retun the balance of the account;
      */
      function balanceOf(address owner) public view returns (uint) {
        /// @dev Return balance of account from storage getter;
        return super.getUint(keccak256('balance', owner));
      }

      /**
      * @notice ISO 4217 Currency code for token
      * @return string Returns three-letter acronym (TLA) for currency
      */
      function currencyTLA() public view returns (string) {
        /// @dev Return token currency code from storage getter;
        return super.getString(keccak256('token.currencyTLA'));
      }

      /**
      * @notice ERC20 compliant `transfer` method;
      * @dev Standard ERC20 transfer interface using storage contract;
      * @dev NOTE: Consider adding `bytes data` param for ERC827 compliance;
      * @param  to 		address Ethereum address to transfer tokens to;
      * @param  amount uint 		Amount of tokens to transfer in expanded decimal form;
      * @return bool 					Returns true if transaction is successful;
      */
      function transfer(address to, uint amount)
      public
      /// @notice Only allowed if contract is not paused;
      /// @dev Consider adding `notDeprecated` modifier
      notPaused
      /// @notice Ensure account is not forbidden and has kyc;
      validateAccount(msg.sender)
      /// @notice Ensure account is not forbidden and has kyc;
      validateAccount(to)
      /// @dev Consider adding `onlyPayloadSize` modifier
      returns (bool)
      {

        /// @dev Ensure value is not being transferred to a null account;
        require(address(to) != 0x0);

        /// @notice Calculate Fees based on amount
        uint fees = calculateFees(amount);

        /// @dev Update the Sender's Balance in the storage contract;
        /// @dev Use internal `uIntStorage` mapping to set balance;
        /// @dev calling `setUint` storage method will fail due to msg.sender != contract owner;
        /// @notice Transaction will fail if user balance < amount + fees (SafeMath)
        /// @notice it is impossible to send the full balance of the account due to fees.
        uIntStorage[keccak256('balance', msg.sender)] =
        super.getUint(keccak256('balance', msg.sender)).sub(amount.add(fees));

        /// @dev Update the Receiver's Balance in the storage contract
        uIntStorage[keccak256('balance', to)] =
        super.getUint(keccak256('balance', to)).add(amount);

        /// @dev Update balance of the fee account
        address feeAccount = super.getAddress(keccak256('feeAccount'));
        uIntStorage[keccak256('balance', feeAccount)] =
        super.getUint(keccak256('balance', feeAccount)).add(fees);


        /// @dev Emit ERC20 Transfer Event
        emit Transfer(msg.sender, to, amount);

        return true;

      }

      /**
      * @notice ERC20 Standard transfer with arbitrary data;
      * @dev transfer interface using storage contract;
      * @dev NOTE: Consider adding `bytes data` param for ERC827 compliance;
      * @param  to 		 address Ethereum address to transfer tokens to;
      * @param  amount uint 	 Amount of tokens to transfer in expanded decimal form;
      * @param  data   bytes   Arbitrary data to send with transaction;
      * @return bool 					Returns true if transaction is successful;
      */
      function transfer(address to, uint amount, bytes data)
      public
      /// @notice Only allowed if contract is not paused;
      /// @dev Consider adding `notDeprecated` modifier
      notPaused
      /// @notice Ensure account is not forbidden and has kyc;
      validateAccount(msg.sender)
      /// @notice Ensure account is not forbidden and has kyc;
      validateAccount(to)
      /// @dev Consider adding `onlyPayloadSize` modifier
      returns (bool)
      {

        /// @dev Ensure value is not being transferred to a null account;
        require(address(to) != 0x0);

        /// @notice Calculate Fees based on amount
        uint fees = calculateFees(amount);

        /// @dev Update the Sender's Balance in the storage contract;
        /// @dev Use internal `uIntStorage` mapping to set balance;
        /// @dev calling `setUint` storage method will fail due to msg.sender != contract owner;
        /// @notice Transaction will fail if user balance < amount + fees (SafeMath)
        /// @notice it is impossible to send the full balance of the account due to fees.
        uIntStorage[keccak256('balance', msg.sender)] =
        super.getUint(keccak256('balance', msg.sender)).sub(amount.add(fees));

        /// @dev Update the Receiver's Balance in the storage contract
        uIntStorage[keccak256('balance', to)] =
        super.getUint(keccak256('balance', to)).add(amount);

        /// @dev Update balance of the fee account
        address feeAccount = super.getAddress(keccak256('feeAccount'));
        uIntStorage[keccak256('balance', feeAccount)] =
        super.getUint(keccak256('balance', feeAccount)).add(fees);


        /// @dev Emit ERC20 Transfer Event
        emit TransferWithData(msg.sender, to, amount, data);

        return true;

      }

      /**
      * @notice ERC20 Compliant `transferFrom` method;
      * @param  from 	address Ethereum address to transfer value from;
      * @param  to 		address Ethereum address to transfer value to;
      * @param  amount uint    Amount of tokens to transfer;
      * @return bool         	Return true if transaction is successful;
      */
      function transferFrom(address from, address to, uint amount)
      public
      /// @notice Only allowed if contract is not paused;
      /// @dev Consider adding `notDeprecated` modifier
      notPaused
      /// @notice Ensure account is not forbidden and has kyc;
      validateAccount(msg.sender)
      /// @notice Ensure account is not forbidden and has kyc;
      validateAccount(from)
      /// @notice Ensure account is not forbidden and has kyc;
      validateAccount(to)
      /// @dev Consider adding `onlyPayloadSize` modifier
      returns (bool)
      {

        /// @dev Ensure value is not being transferred to a null account;
        require(address(to) != 0x0);

        /// @notice Calculate Fees based on amount
        uint fees = calculateFees(amount);

        /// @dev Update the Sender's Balance in the storage contract
        /// @dev Use internal `uIntStorage` mapping to set balance;
        /// @notice Transaction will fail if user balance < amount + fees (SafeMath)
        /// @notice it is impossible to send the full balance of the account due to fees.
        uIntStorage[keccak256('balance', from)] =
        super.getUint(keccak256('balance', from)).sub(amount.add(fees));

        /// @dev Update the Receiver's Balance in the storage contract
        uIntStorage[keccak256('balance', to)] =
        super.getUint(keccak256('balance', to)).add(amount);

        /// @dev Update the spender allowance; msg.sender == spender
        /// @notice Transaction will fail if allowance is insufficient for account;
        uIntStorage[keccak256('allowance', from, msg.sender)] =
        super.getUint(keccak256('allowance', from, msg.sender)).sub(amount);

        /// @dev Send fees to feeAccount
        address feeAccount = super.getAddress(keccak256('feeAccount'));
        uIntStorage[keccak256('balance', feeAccount)] =
        super.getUint(keccak256('balance', feeAccount)).add(fees);

        /// @dev Emit ERC20 Transfer Event
        emit Transfer(from, to, amount);

        return true;
      }

      /**
      * @notice ERC20 Compliant `transferFrom` method with data;
      * @param  from 	address Ethereum address to transfer value from;
      * @param  to 		address Ethereum address to transfer value to;
      * @param  amount uint    Amount of tokens to transfer;
      * @param  data  bytes   Arbitrary data to send with transaction;
      * @return bool         	Return true if transaction is successful;
      */
      function transferFrom(address from, address to, uint amount, bytes data)
      public
      /// @notice Only allowed if contract is not paused;
      /// @dev Consider adding `notDeprecated` modifier
      notPaused
      /// @notice Ensure account is not forbidden and has kyc;
      validateAccount(msg.sender)
      /// @notice Ensure account is not forbidden and has kyc;
      validateAccount(from)
      /// @notice Ensure account is not forbidden and has kyc;
      validateAccount(to)
      /// @dev Consider adding `onlyPayloadSize` modifier
      returns (bool)
      {

        /// @dev Ensure value is not being transferred to a null account;
        require(address(to) != 0x0);

        /// @notice Calculate Fees based on amount
        uint fees = calculateFees(amount);

        /// @dev Update the Sender's Balance in the storage contract
        /// @dev Use internal `uIntStorage` mapping to set balance;
        /// @notice Transaction will fail if user balance < amount + fees (SafeMath)
        /// @notice it is impossible to send the full balance of the account due to fees.
        uIntStorage[keccak256('balance', from)] =
        super.getUint(keccak256('balance', from)).sub(amount.add(fees));

        /// @dev Update the Receiver's Balance in the storage contract
        uIntStorage[keccak256('balance', to)] =
        super.getUint(keccak256('balance', to)).add(amount);

        /// @dev Update the spender allowance; msg.sender == spender
        /// @notice Transaction will fail if allowance is insufficient for account;
        uIntStorage[keccak256('allowance', from, msg.sender)] =
        super.getUint(keccak256('allowance', from, msg.sender)).sub(amount);

        /// @dev Send fees to feeAccount
        address feeAccount = super.getAddress(keccak256('feeAccount'));
        uIntStorage[keccak256('balance', feeAccount)] =
        super.getUint(keccak256('balance', feeAccount)).add(fees);

        /// @dev Emit ERC20 Transfer Event
        emit TransferWithData(from, to, amount, data);

        return true;
      }

      /**
      * @notice ERC20 compliant `approve` method
      * @param  spender address Ethereum address of approved spender
      * @param  amount  uint    Amount of allowance to set in expanded decimal form
      * @return bool         	 Returns true if transaction is successful
      */
      function approve(address spender, uint amount)
      public
      /// @notice Only allowed if contract is not paused;
      /// @dev Consider adding `notDeprecated` modifier
      notPaused
      /// @notice Ensure account is not forbidden and has kyc;
      validateAccount(spender)
      returns (bool)
      {

        /// @dev Ensure initial allowance begins at 0 before setting allowance
        /// @dev or, allow amount to be set to 0 for resetting allowance;
        require(super.getUint(keccak256('allowance', msg.sender, spender)) == 0 || amount == 0);

        /// @dev Ensure cannot approve allowance greater than current balance;
        require(super.getUint(keccak256('balance', msg.sender)) >= amount);

        /// @dev Set the spender allowance
        uIntStorage[keccak256('allowance', msg.sender, spender)] = amount;

        /// @dev Emit ERC20 Approval Event
        emit Approval(msg.sender, spender, amount);

        return true;
      }

      /**
      * @notice Return the frozen balance of an account;
      * @param  owner address Ethereum address of account owner;
      * @return uint          Return frozen balance of account;
      */
      function frozenBalanceOf(address owner) public view returns (uint) {
        return super.getUint(keccak256('frozenBalance', owner));
      }

      /**
      * @notice Contract owner uses to approve deposit funds for account;
      * @param  owner  address Ethereum address of owner account to approve deposit for;
      * @param  amount uint    Amount to approve for deposit;
      * @return bool           Return true if contract transaction is successful;
      */
      function deposit(address owner, uint amount)
      public
      /// @notice Only the owner of the contract can approve deposits;
      onlyOwner
      /// @notice Only allowed if contract is not paused;
      /// @dev Consider adding `notDeprecated` modifier
      notPaused
      /// @notice Ensure account is not forbidden and has kyc;
      validateAccount(owner)
      returns (bool)
      {

        /// @dev Increase the balance of owner;
        uIntStorage[keccak256('balance', owner)] =
        super.getUint(keccak256('balance', owner)).add(amount);

        /// @dev Increase the total supply by the amount deposited;
        uIntStorage[keccak256('token.totalSupply')] =
        super.getUint(keccak256('token.totalSupply')).add(amount);

        /// @dev Emit Deposit event;
        /// @notice Alerts owner when amount has been deposited;
        emit Deposit(owner, amount);

        return true;
      }


      function withdraw(address owner, uint amount)
      public
      /// @notice Only the owner of the contract can withdraw funds for an account;
      onlyOwner
      /// @notice Only allowed if contract is not paused;
      /// @dev Consider adding `notDeprecated` modifier
      notPaused
      /// @notice Ensure account is not forbidden and has kyc;
      validateAccount(owner)
      returns (bool)
      {

        /// @dev Ensure the owner has greater than or equal to the withdraw amount.
        require(super.getUint(keccak256('balance', owner)) >= amount);

        /// @dev Decrease the balance of the owner account by amount to withdraw
        uIntStorage[keccak256('balance', owner)] =
        super.getUint(keccak256('balance', owner)).sub(amount);

        /// @dev Decrease the total supply by amount to withdraw
        uIntStorage[keccak256('token.totalSupply')] =
        super.getUint(keccak256('token.totalSupply')).sub(amount);

        /// @dev Emit Withdraw event;
        /// @notice Alerts owner when amount has been withdrawn;
        emit Withdraw(owner, amount);

        return true;
      }

      /**
      * @notice Contract owner can force transfer funds from an account if necessary;
      * @param  from   address Ethereum address of account to transfer funds from;
      * @param  to     address Ethereum address of account to transfer funds to;
      * @param  amount uint    Amount to transfer funds;
      * @param  data   bytes   Arbitrary data (e.g. reason) for force transfer
      * @return        bool    Transaction returns true if successful;
      */
      function forceTransfer(address from, address to, uint amount, bytes data)
      public
      /// @notice Only the owner of the contract can withdraw funds for an account;
      onlyOwner
      /// @notice Only allowed if contract is not paused;
      /// @dev Consider adding `notDeprecated` modifier
      notPaused
      returns (bool)
      {

        /// @dev Ensure value is not being transferred to a null account;
        require(address(to) != 0x0);
        require(amount > 0);

        /// @dev Ensure the amount is less than or equal to frozen funds balance
        require(super.getUint(keccak256('frozenBalance', from)) >= amount);

        /// @dev Update the Sender's Balance in the storage contract
        /// @notice Transaction will fail if user frozen balance < amount + fees
        /// @notice Account must have frozenBalance > 0 to forceTransfer;
        uIntStorage[keccak256('frozenBalance', from)] =
        super.getUint(keccak256('frozenBalance', from)).sub(amount);

        /// @dev Update the receiver's account balance in the storage contract
        uIntStorage[keccak256('balance', to)] =
        super.getUint(keccak256('balance', to)).add(amount);

        /// @dev Decrease total amount frozen;
        uIntStorage[keccak256('totalFrozen')] =
        super.getUint(keccak256('totalFrozen')).sub(amount);

        /// @dev Emit Transfer event on `forceTransfer`
        emit TransferWithData(from, to, amount, data);

        return true;
      }

      /**
      * @notice Authority may freeze specified amount of funds for an account owner;
      * @param  owner  address Ethereum address of account owner;
      * @param  amount uint    Amount of funds to freeze;
      * @return 				bool    Return true if transaction is successful;
      */
      function freeze(address owner, uint amount)
      public
      /// @notice Only the owner of the contract can withdraw funds for an account;
      onlyOwner
      /// @notice Only allowed if contract is not paused;
      /// @dev Consider adding `notDeprecated` modifier
      notPaused
      returns (bool)
      {

        /// @dev Ensure amount frozen is equal to or less than the balance of the account;
        require(super.getUint(keccak256('balance', owner)) >= amount);

        /// @dev Increase the frozenBalances of the owner account;
        uIntStorage[keccak256('frozenBalance', owner)] =
        super.getUint(keccak256('frozenBalance', owner)).add(amount);

        /// @dev Decrease the balance from the owner account on chain;
        uIntStorage[keccak256('balance', owner)] =
        super.getUint(keccak256('balance', owner)).sub(amount);

        /// @dev Increase global total amount frozen;
        uIntStorage[keccak256('totalFrozen')] =
        super.getUint(keccak256('totalFrozen')).add(amount);

        return true;
      }

      /**
      * @notice Authority may unfreeze specified amount of funds for an account owner;
      * @param  owner  address Ethereum address of account owner;
      * @param  amount uint    Amount of funds to unfreeze;
      * @return 				bool    Return true if transaction is successful;
      */
      function unfreeze(address owner, uint amount)
      public
      /// @notice Only the owner of the contract can withdraw funds for an account;
      onlyOwner
      /// @notice Only allowed if contract is not paused;
      /// @dev Consider adding `notDeprecated` modifier
      notPaused
      /// @notice Ensure account is not forbidden and has kyc;
      validateAccount(owner)
      returns (bool)
      {

        /// @dev Ensure amount to unfreeze is less than or equal to amount frozen;
        /// @notice this is also checked by SafeMath when subtracting amounts;
        require(super.getUint(keccak256('frozenBalance', owner)) <= amount);

        /// @dev Decrease the frozenBalances of the owner account;
        uIntStorage[keccak256('frozenBalance', owner)] =
        super.getUint(keccak256('frozenBalance', owner)).sub(amount);

        /// @dev Increase the balance from the owner account on chain;
        uIntStorage[keccak256('balance', owner)] =
        super.getUint(keccak256('balance', owner)).add(amount);

        /// @dev Decrease total amount frozen;
        uIntStorage[keccak256('totalFrozen')] =
        super.getUint(keccak256('totalFrozen')).sub(amount);

        return true;
      }

      /**
      * @notice Set forbidden status for account;
      * @param  account 		 address Ethereum account to set forbidden status for;
      * @param  isForbidden bool    Boolean to set/unset forbidden status;
      * @return 						 bool    Returns true if transaction is successful;
      */
      function forbid(address account, bool isForbidden)
      public
      /// @notice Only the owner of the contract can withdraw funds for an account;
      onlyOwner
      /// @notice Only allowed if contract is not paused;
      /// @dev Consider adding `notDeprecated` modifier
      notPaused
      /// @notice Ensure account is not forbidden and has kyc;
      returns (bool)
      {
        bytes32 fba = keccak256(abi.encodePacked('forbidden', account));
        super.setBool(fba, isForbidden);

        /// @dev Log Forbid event for account
        emit Forbid(account, isForbidden);
        return true;
      }

      /**
      * @notice Return forbidden status for account;
      * @param  account address Ethereum account to check status for;
      * @return 				 bool    Returns true if transaction is successful;
      */
      function checkForbidden(address account) public view returns (bool) {
        bytes32 fba = keccak256(abi.encodePacked('forbidden', account));
        return super.getBool(fba);
      }

      /**
      * @notice Authority may pause/unpause this contract;
      * @param  pause bool Pause or unpause this contract;
      * @return 			 bool Returns true is transaction is successful;
      */
      function pauseContract(bool pause)
      public
      /// @notice Only the owner of the contract can withdraw funds for an account;
      onlyOwner
      returns (bool)
      {
        /// @dev Subsequent contracts may also be paused via storage contract;
        /// @notice `keccak256('paused', <address>)` to pause multiple contracts;
        super.setBool(keccak256('paused', address(this)), pause);

        return true;
      }

      /**
      * @notice Return paused status of this contract;
      * @return bool Returns the paused boolean status of the contract;
      */
      function checkPaused() public view returns (bool) {
        return super.getBool(keccak256('paused', address(this)));
      }

      modifier notPaused() {
        /// @notice Throw transactions if contract is paused;
        require(!checkPaused());
        _;
      }

      modifier validateAccount(address account) {
        /// @notice Throw transactions if account is forbidden;
        bytes32 fba = keccak256(abi.encodePacked('forbidden', account));
        require(!super.getBool(fba));
        _;
      }

    }
