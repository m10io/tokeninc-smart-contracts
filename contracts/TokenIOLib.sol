pragma solidity 0.4.23;

import "./SafeMath.sol";


library TokenIOLib {

    using SafeMath for uint;

    struct Data {
        uint totalSupply;
        uint decimals;
        uint totalFrozen;
        string symbol;
        string name;
        string currencyTLA;
        mapping(address => bool) forbidden;
        mapping(address => uint) balances;
        mapping(address => uint) frozenBalances;
        mapping(address => mapping(address => uint)) allowances;
        mapping(address => uint) requestedFunds;
    }

    function allowance(Data storage self, address owner, address spender) internal view returns (uint) {
        return self.allowances[owner][spender];
    }

    function transfer(Data storage self, address from, address to, uint amount)
        internal validateAccount(self, from) validateAccount(self, to) returns (bool)
    {
        // Ensure value is not being transferred to a null account;
        require(address(to) != 0x0);

        // SafeMath will throw is the balance is less than the amount being sent.
        self.balances[from] = self.balances[from].sub(amount);
        self.balances[to] = self.balances[to].add(amount);

        // Log Transfer event in the parent contract
        return true;
    }

    function transferFrom(
        Data storage self,
        address spender,
        address from,
        address to,
        uint amount
    )
        // NOTE: This may interfere with forceTransfer method if account is forbidden;
        internal validateAccount(self, from)
        validateAccount(self, to) returns (bool)
    {
        // Ensure value is not being transferred to a null account;
        require(address(to) != 0x0);

        // SafeMath will throw is the balance is less than the amount being sent.
        self.balances[from] = self.balances[from].sub(amount);
        self.balances[to] = self.balances[to].add(amount);

        // Reduce allowance of spender
        self.allowances[from][spender] = self.allowances[from][spender].sub(amount);

        // Log Transfer event in the parent contract
        return true;
    }

    /*
    * NOTE: Open-Zeppelin Security Note, "Beware that changing an allowance with
    * this method brings the risk that someone may use both the old
    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729"
    */
    function approve(Data storage self, address owner, address spender, uint amount)
        internal  validateAccount(self, owner) returns (bool)
    {
        // Ensure initial allowance begins at 0 before setting allowance or allow
        // amount to be set to 0 for resetting allowance;
        require(self.allowances[owner][spender] == 0 || amount == 0);

        // Ensure cannot approve greater than current balance;
        require(self.balances[owner] >= amount);

        self.allowances[owner][spender] = amount;

        // Log Approval event in parent contract;
        return true;
    }

    // Withdraw funds from the private chain; Sent by owner of account;
    function withdraw(Data storage self, address owner, uint amount)
        internal  validateAccount(self, owner) returns (bool)
    {

        // Ensure any prior requested funds have been settled;
        require(self.requestedFunds[owner] == 0);

        // Increase the requested funds amount; Will be transferred to balance after approved.
        self.requestedFunds[owner] = self.requestedFunds[owner].add(amount);

        // Log Withdraw event in the parent contract;
        return true;
    }

    // Destory the funds on the private chain, i.e. increase total supply on chain
    function approveWithdraw(Data storage self, address owner, uint amount)
        internal  validateAccount(self, owner) returns (bool)
    {
        // Ensure approval is for amount requested;
        require(self.requestedFunds[owner] == amount);

        self.requestedFunds[owner] = self.requestedFunds[owner].sub(amount);
        self.balances[owner] = self.balances[owner].add(amount);

        // Increase the total supply by the amount withdrawn
        self.totalSupply = self.totalSupply.add(amount);

        return true;
    }

    // Deposit funds to account, destroy funds on public chain, i.e. reduce total supply on chain
    function deposit(Data storage self, address owner, uint amount)
        internal  validateAccount(self, owner) returns (bool)
    {

        // Ensure the owner has greater than or equal to the amount being deposited off chain.
        require(self.balances[owner] >= amount);

        // Remove the balance from the owner account on chain;
        self.balances[owner] = self.balances[owner].sub(amount);

        // Decrease the total supply by the amount deposited
        self.totalSupply = self.totalSupply.sub(amount);

        return true;

    }

    function freeze(Data storage self, address owner, uint amount) internal returns (bool) {

        // Ensure amount frozen is equal to or less than the balance of the account;
        require(self.balances[owner] >= amount);

        // Increase the frozenBalances of the owner account;
        self.frozenBalances[owner] = self.frozenBalances[owner].add(amount);

        // Decrease the balance from the owner account on chain;
        self.balances[owner] = self.balances[owner].sub(amount);

        // Increase total amount frozen;
        self.totalFrozen = self.totalFrozen.add(amount);

        return true;
    }

    function unfreeze(Data storage self, address owner, uint amount)
        internal validateAccount(self, owner) returns (bool)
    {

        // Ensure amount to unfreeze is less than or equal to amount frozen;
        // NOTE: this is also checked by SafeMath when subtracting amounts;
        require(self.frozenBalances[owner] <= amount);

        // Decrease the frozenBalances of the owner account;
        self.frozenBalances[owner] = self.frozenBalances[owner].sub(amount);

        // Increase the balance from the owner account on chain;
        self.balances[owner] = self.balances[owner].add(amount);

        // Decrease total amount frozen;
        self.totalFrozen = self.totalFrozen.sub(amount);

        return true;

    }

    modifier validateAccount(Data storage self, address account) {
        require(!self.forbidden[account]);
        _;
    }

}
