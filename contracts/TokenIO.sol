pragma solidity 0.4.23;


import "./SafeMath.sol";
import "./TokenIOStorage.sol";


contract TokenIO is TokenIOStorage {

    using SafeMath for uint;

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
    event Withdraw(address indexed owner, uint amount);
    event Deposit(address indexed owner, uint amount);
    event Forbid(address indexed account, bool isForbidden);

    constructor() public {
        // Set Global Variables;
        require(setString(keccak256('token.name'), "USD by token.io"));
        require(setString(keccak256('token.symbol'), "USD+"));
        require(setString(keccak256('token.currencyTLA'), "USD"));
        require(setString(keccak256('token.version'), "v0.0.1"));
        require(setString(keccak256('globalMessage'), "Hello, World!"));

        require(setUint(keccak256('token.decimals'), 5));
        require(setUint(keccak256('token.totalSupply'), 0));

        require(setBool(keccak256('paused', address(this)), false));

        // Set value for if contract becomes deprecated
        require(setBool(keccak256('deprecated', address(this)), false));

        // Set the default contract
        require(setAddress(keccak256('defaultContract'), address(this)));


        // Send fees to feeAccount
        require(setAddress(keccak256('feeAccount'), msg.sender));

        require(setUint(keccak256('fee.min'), 0)); // min fee 0 USD); Keep?
        require(setUint(keccak256('fee.max'), 100 * 10**5)); // max fee 100 USD ?
        require(setUint(keccak256('fee.bps'), 20)); // bps 0.2%
        require(setUint(keccak256('fee.flat'), 2 * 10**3)); // $.02 USD flat fee;
    }

    function calculateFees(uint amount) public view returns (uint) {
        uint flatFee = getUint(keccak256('fee.flat'));
        uint maxFee = getUint(keccak256('fee.max'));
        uint bpsFee = getUint(keccak256('fee.bps'));
        uint fees = ((amount.mul(bpsFee)).div(10000)).add(flatFee);

        if (fees > maxFee) {
            return maxFee;
        } else {
            return fees;
        }
    }

    function totalSupply() public view returns (uint) {
        return getUint(keccak256('token.totalSupply'));
    }

    function name() public view returns (string) {
        return getString(keccak256('token.name'));
    }

    function symbol() public view returns (string) {
        return getString(keccak256('token.symbol'));
    }

    function currencyTLA() public view returns (string) {
        return getString(keccak256('token.currencyTLA'));
    }

    function decimals() public view returns (uint) {
        return getUint(keccak256('token.decimals'));
    }


    function transfer(address to, uint amount) public notPaused validateAccount(to) returns (bool) {
        // Handle logic locally;
        // Ensure value is not being transferred to a null account;
        require(address(to) != 0x0);

        // Calculate Fees based on amount
        uint fees = calculateFees(amount);

        // Update the Sender's Balance in the storage contract
        // Transaction will fail if user balance < amount + fees
        require(setUint(keccak256('balance', msg.sender),
        getUint(keccak256('balance', msg.sender)).sub(amount.add(fees))));

        // Update the Receiver's Balance in the storage contract
        require(setUint(keccak256('balance', to),
        getUint(keccak256('balance', to)).add(amount)));

        // Send fees to feeAccount
        address feeAccount = getAddress(keccak256('feeAccount'));
        require(setUint(keccak256('balance', feeAccount),
        getUint(keccak256('balance', feeAccount)).add(fees)));

        emit Transfer(msg.sender, to, amount);

        return true;

    }

    function transferFrom(address from, address to, uint amount) public notPaused validateAccount(from) validateAccount(to) returns (bool) {
        // Handle logic locally;
        // Ensure value is not being transferred to a null account;
        require(address(to) != 0x0);

        // Calculate Fees based on amount
        uint fees = calculateFees(amount);

        // Update the Sender's Balance in the storage contract
        require(setUint(keccak256('balance', from),
        getUint(keccak256('balance', from)).sub(amount.add(fees))));

        // Update the Receiver's Balance in the storage contract
        require(setUint(keccak256('balance', to),
        getUint(keccak256('balance', to)).add(amount)));

        // Update the "Spender's" allowance; msg.sender == spender
        // Transaction will fail if allowance is not set for account;
        require(setUint(keccak256('allowance', from, msg.sender),
        getUint(keccak256('allowance', from, msg.sender)).sub(amount)));

        // Send fees to feeAccount
        address feeAccount = getAddress(keccak256('feeAccount'));
        require(setUint(keccak256('balance', feeAccount),
        getUint(keccak256('balance', feeAccount)).add(fees)));


        emit Transfer(from, to, amount);
        return true;
    }

    function approve(address spender, uint amount) public notPaused validateAccount(spender) returns (bool) {

        // Ensure initial allowance begins at 0 before setting allowance or allow
        // amount to be set to 0 for resetting allowance;
        require(getUint(keccak256('allowance', msg.sender, spender)) == 0 || amount == 0);

        // Ensure cannot approve greater than current balance;
        require(getUint(keccak256('balance', msg.sender)) >= amount);

        require(setUint(keccak256('allowance', msg.sender, spender),
            getUint(keccak256('allowance', msg.sender, spender)).add(amount)));

        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint) {
        return getUint(keccak256('allowance', owner, spender));
    }

    function balanceOf(address owner) public view returns (uint) {
        return getUint(keccak256('balance', owner));
    }

    function frozenBalanceOf(address owner) public view returns (uint) {
        return getUint(keccak256('frozenBalance', owner));
    }

    function requestedFundsOf(address owner) public view returns (uint) {
        return getUint(keccak256('requestedFunds', owner));
    }


    function deposit(uint amount) public notPaused validateAccount(msg.sender) returns (bool) {


        // Ensure any prior requested funds have been settled;
        require(getUint(keccak256('requestedFunds', msg.sender)) == 0);

        require(setUint(keccak256('allowedUntil', msg.sender), now.add(1)));

        // Increase the requested funds amount; Will be transferred to balance after approved.
        require(setUint(keccak256('requestedFunds', msg.sender),
        getUint(keccak256('requestedFunds', msg.sender)).add(amount)));

        emit Deposit(msg.sender, amount);
        return true;
    }

    function approveDeposit(address owner, uint amount) public onlyOwner notPaused validateAccount(owner) returns (bool) {

        // Ensure approval is for amount requested;
        require(getUint(keccak256('requestedFunds', owner)) == amount);

        // Reduce Requested Funds Amount
        require(setUint(keccak256('requestedFunds', owner),
        getUint(keccak256('requestedFunds', owner)).sub(amount)));

        // Increase Balance of owner
        require(setUint(keccak256('balance', owner),
        getUint(keccak256('balance', owner)).add(amount)));

        // Increase the total supply by the amount withdrawn
        require(setUint(keccak256('token.totalSupply'),
        getUint(keccak256('token.totalSupply')).add(amount)));

        return true;
    }


    function withdraw(address owner, uint amount) public onlyOwner notPaused validateAccount(owner) returns (bool) {

        // Ensure the owner has greater than or equal to the amount being deposited off chain.
        require(getUint(keccak256('balance', owner)) >= amount);

        require(setUint(keccak256('balance', owner),
            getUint(keccak256('balance', owner)).sub(amount)));

        // Decrease the total supply by the amount deposited
        require(setUint(keccak256('token.totalSupply'),
            getUint(keccak256('token.totalSupply')).sub(amount)));

        emit Withdraw(owner, amount);

        return true;
    }

    function forceTransfer(address from, address to, uint amount) public onlyOwner returns (bool) {

        // Handle logic locally;
        // Ensure value is not being transferred to a null account;
        require(address(to) != 0x0);

        // Update the Sender's Balance in the storage contract
        // Transaction will fail if user balance < amount + fees
        require(setUint(keccak256('balance', from),
        getUint(keccak256('balance', from)).sub(amount)));

        // Update the Receiver's Balance in the storage contract
        require(setUint(keccak256('balance', to),
        getUint(keccak256('balance', to)).add(amount)));

        emit Transfer(from, to, amount);
        return true;
    }

    function freeze(address owner, uint amount) public onlyOwner notPaused returns (bool) {

        // Ensure amount frozen is equal to or less than the balance of the account;
        require(getUint(keccak256('balance', owner)) >= amount);

        // Increase the frozenBalances of the owner account;
        require(setUint(keccak256('frozenBalance', owner),
            getUint(keccak256('frozenBalance', owner)).add(amount)));

        // Decrease the balance from the owner account on chain;
        require(setUint(keccak256('balance', owner),
            getUint(keccak256('balance', owner)).sub(amount)));

        // Increase total amount frozen;
        require(setUint(keccak256('totalFrozen'),
            getUint(keccak256('totalFrozen')).add(amount)));

        return true;
    }

    function unfreeze(address owner, uint amount) public onlyOwner notPaused validateAccount(owner) returns (bool) {

        // Ensure amount to unfreeze is less than or equal to amount frozen;
        // NOTE: this is also checked by SafeMath when subtracting amounts;
        require(getUint(keccak256('frozenBalance', owner)) <= amount);

        // Decrease the frozenBalances of the owner account;
        require(setUint(keccak256('frozenBalance', owner),
            getUint(keccak256('frozenBalance', owner)).sub(amount)));

        // Increase the balance from the owner account on chain;
        require(setUint(keccak256('balance', owner),
            getUint(keccak256('balance', owner)).add(amount)));

        // Decrease total amount frozen;
        require(setUint(keccak256('totalFrozen'),
            getUint(keccak256('totalFrozen')).sub(amount)));

        return true;
    }

    function forbid(address account, bool isForbidden) public onlyOwner notPaused returns (bool) {
        require(setBool(keccak256('forbidden', account), isForbidden));

        // Log Forbid event for account
        emit Forbid(account, isForbidden);
        return true;
    }

    function checkForbidden(address account) public view returns (bool) {
        return getBool(keccak256('forbidden', account));
    }

    function setPaused(bool isPaused) public returns (bool) {
        require(setBool(keccak256('paused'), isPaused));

        return true;
    }

    function checkPaused() public view returns (bool) {
        return getBool(keccak256('paused', address(this)));
    }

    modifier notPaused() {
        require(!getBool(keccak256('paused', address(this))));
        _;
    }

    modifier validateAccount(address account) {
        require(!getBool(keccak256('forbidden', account)));
        _;
    }

}
