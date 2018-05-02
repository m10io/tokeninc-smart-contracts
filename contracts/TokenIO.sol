pragma solidity 0.4.23;

import "./TokenIOLib.sol";
import "./SafeMath.sol";

contract TokenIO {

    using SafeMath for uint;

    using TokenIOLib for TokenIOLib.Account;
    using TokenIOLib for TokenIOLib.Data;
    using TokenIOLib for TokenIOLib.AccountSummary;
    using TokenIOLib for TokenIOLib.Durations;
    using TokenIOLib for TokenIOLib.Fees;
    using TokenIOLib for TokenIOLib.KYC;

    TokenIOLib.Data tokenIO;

    event LogNewAccount(address parentAddress, address accountAddress, bool isAdmin);

    constructor() public {


        tokenIO.name = "USD by token.io";
        tokenIO.symbol = "USD+";
        tokenIO.currencyTLA = "USD";
        tokenIO.decimals = 5;
        tokenIO.totalSupply = 23432 * 10**tokenIO.decimals;

        // Initial Daily Limit .001% of totalSupply, represented as basis points
        uint initDailyLimit = (tokenIO.totalSupply.mul(1000)).div(10000);

        // Set durations in seconds
        tokenIO.durations[uint(TokenIOLib.Durations.Day)] = 86400;
        tokenIO.durations[uint(TokenIOLib.Durations.Week)] = 604800;
        tokenIO.durations[uint(TokenIOLib.Durations.Month)] = 2419200;
        tokenIO.durations[uint(TokenIOLib.Durations.Quarter)] = 7257600;
        tokenIO.durations[uint(TokenIOLib.Durations.Year)] = 29030400;

        // All "Core" fees are denominated in terms of basis points
        tokenIO.feeValues[uint(TokenIOLib.Fees.CoreMin)] = 25;
        tokenIO.feeValues[uint(TokenIOLib.Fees.CoreMax)] = 500;
        tokenIO.feeValues[uint(TokenIOLib.Fees.CoreBps)] = 250; // What should Bps Be?

        // Absolute Fee for Core Flat -- Is this a max fee?
        tokenIO.feeValues[uint(TokenIOLib.Fees.Flat)] = 50 * 10**tokenIO.decimals; // $50

        // Fee Multiplier Values
        tokenIO.feeValues[uint(TokenIOLib.Fees.MultiplierHigh)] = 4;
        tokenIO.feeValues[uint(TokenIOLib.Fees.MultiplierMedium)] = 2;
        tokenIO.feeValues[uint(TokenIOLib.Fees.MultiplierLow)] = 1;

        // Fees for KYC, Linking Account (Denominated in absolute cents)
        tokenIO.feeValues[uint(TokenIOLib.Fees.LinkAccount)] = 50 * 10**(tokenIO.decimals - 2); // $.50
        tokenIO.feeValues[uint(TokenIOLib.Fees.AddKYC)] = 25 * 10**(tokenIO.decimals - 2); // $.25


        uint[9] memory summary;
        summary[uint(TokenIOLib.AccountSummary.SpendingLimit)] = initDailyLimit;
        summary[uint(TokenIOLib.AccountSummary.SpendingRemainder)] = initDailyLimit;
        summary[uint(TokenIOLib.AccountSummary.SpendingPeriod)] = now;
        summary[uint(TokenIOLib.AccountSummary.SpendingDuration)] =
            tokenIO.durations[uint(TokenIOLib.Durations.Day)];

        summary[uint(TokenIOLib.AccountSummary.CreditLimit)] = 0;
        summary[uint(TokenIOLib.AccountSummary.CreditDrawdown)] = 0;

        summary[uint(TokenIOLib.AccountSummary.Balance)] = tokenIO.totalSupply;
        summary[uint(TokenIOLib.AccountSummary.ChildBalance)] = 0;
        summary[uint(TokenIOLib.AccountSummary.FrozenBalance)] = 0;


        // Establish contract as the first Account holder; This is not CB, this is contract itself
        require(tokenIO.newAccount(msg.sender, address(this), true));

        // Set new account and CB equal to self
        require(tokenIO.newAccount(msg.sender, msg.sender, true));

        // Set Global Central Bank Address to msg.sender;
        tokenIO.centralBank = msg.sender;

        tokenIO.accountNumber[msg.sender] = tokenIO.accountNumber[msg.sender]; // Msg.sender is CB, CB == 1

        TokenIOLib.Account storage CB = tokenIO.accountDetails[tokenIO.accountNumber[msg.sender]];

        CB.summary = summary;
        CB.parentID = tokenIO.accountNumber[msg.sender];
        /* CB.childBalances = 0; */
        // CB.firstSender = tokenIO.accountNumber[msg.sender];
        CB.kyc[uint(TokenIOLib.KYC.Required)] = false;
    }

    function transfer(address to, uint value) public returns (bool) {
        return tokenIO.transferFunds(msg.sender, to, value);
    }

    function transferCredit(address to, uint value) public returns (bool) {
        return tokenIO.transferCredit(msg.sender, to, value);
    }

    function setCreditLimit(address account, uint limit) public returns (bool) {
        return tokenIO.setCreditLimit(msg.sender, account, limit);
    }

    function newAccount(address parentAddress, address accountAddress) public returns (bool) {
        require(tokenIO.newAccount(parentAddress, accountAddress, false));
        emit LogNewAccount(parentAddress, accountAddress, false);
        return true;
    }

    function approveAccount(address accountAddress) public returns (bool) {
        return tokenIO.approveAccount(msg.sender, accountAddress);
    }

    function addKYCAttribute(address account, TokenIOLib.KYC attribute) public returns (bool) {
        return tokenIO.addKYCAttribute(msg.sender, account, attribute);
    }

    function linkAccount(address accountAddress, address newAccountAddress) public returns (bool) {
        return tokenIO.linkAccount(msg.sender, accountAddress, newAccountAddress);
    }

    function totalSupply() public view returns (uint) {
        return tokenIO.totalSupply;
    }

    function name() public view returns (string) {
        return tokenIO.name;
    }

    function currencyTLA() public view returns (string) {
        return tokenIO.currencyTLA;
    }

    function decimals() public view returns (uint) {
        return tokenIO.decimals;
    }

    function centralBank() public view returns (address) {
        return tokenIO.centralBank;
    }

    /*  */

    function netBalanceOf(address account) public view returns (int) {
        return tokenIO.netBalanceOf(account);
    }

    function balanceOf(address account) public view returns (uint) {
        return tokenIO.balanceOf(account);
    }

    function creditLineDrawdownOf(address account) public view returns (uint) {
        return tokenIO.creditLineDrawdownOf(account);
    }

    function getAccountNumber(address account) public view returns (uint) {
        return tokenIO.accountNumber[account];
    }

    function calculateFeeAmount(address to, uint amount) public view returns (uint) {
        return tokenIO.calculateFeeAmount(msg.sender, to, amount);
    }

    function getFeeSchedule(address account) public view returns (uint) {
        return tokenIO.getFeeSchedule(account);
    }

    function getSpendingLimit(address account) public view returns (uint) {
        return tokenIO.getSpendingLimit(account);
    }



}
