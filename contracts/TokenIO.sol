pragma solidity 0.4.23;

import "./TokenIOLib.sol";
import "./SafeMath.sol";

contract TokenIO {

    using SafeMath for uint;

    using TokenIOLib for TokenIOLib.Account;
    using TokenIOLib for TokenIOLib.Data;
    using TokenIOLib for TokenIOLib.Spending;
    using TokenIOLib for TokenIOLib.Credit;
    using TokenIOLib for TokenIOLib.Durations;
    using TokenIOLib for TokenIOLib.Fees;
    using TokenIOLib for TokenIOLib.KYC;

    TokenIOLib.Data tokenIO;

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


        uint[4] memory spending;
        spending[uint(TokenIOLib.Spending.Limit)] = initDailyLimit;
        spending[uint(TokenIOLib.Spending.Remainder)] = initDailyLimit;
        spending[uint(TokenIOLib.Spending.Period)] = now;
        spending[uint(TokenIOLib.Spending.Duration)] =
            tokenIO.durations[uint(TokenIOLib.Durations.Day)];


        uint[2] memory credit;
        credit[uint(TokenIOLib.Credit.Limit)] = 0;
        credit[uint(TokenIOLib.Credit.Drawdown)] = 0;


        // Establish contract as the first Account holder; This is not CB, this is contract itself
        require(tokenIO.newAccount(msg.sender, address(this)));

        // Set new account and CB equal to self
        require(tokenIO.newAccount(msg.sender, msg.sender));

        tokenIO.accountNumber[msg.sender] = tokenIO.accountNumber[msg.sender]; // Msg.sender is CB, CB == 1

        TokenIOLib.Account storage CB = tokenIO.accountDetails[tokenIO.accountNumber[msg.sender]];

        // Set initial values for CB;
        CB.equity = tokenIO.totalSupply;
        CB.credit = credit;
        CB.spending = spending;
        CB.parentID = tokenIO.accountNumber[msg.sender];
        CB.childBalances = 0;
        CB.firstSender = tokenIO.accountNumber[msg.sender];
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

    function newAccount(address account) public returns (bool) {
        return tokenIO.newAccount(msg.sender, account);
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
