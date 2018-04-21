pragma solidity 0.4.23;

import "./TokenIOLib.sol";
import "./SafeMath.sol";

contract TokenIO {

    using SafeMath for uint;

    using TokenIOLib for TokenIOLib.Account;
    using TokenIOLib for TokenIOLib.Data;
    using TokenIOLib for TokenIOLib.DailySpending;
    using TokenIOLib for TokenIOLib.Credit;
    TokenIOLib.Data tokenIO;

    constructor() public {

        // 1,000,000,000,000 => 1 Trillion USD
        tokenIO.totalSupply = 1000000000000 * 10**5;

        // Initial Daily Limit .001% of totalSupply, represented as basis points
        uint initDailyLimit = (tokenIO.totalSupply.mul(1)).div(10000);

        uint accNum = 1;

        uint[3] memory dailyValues;
        dailyValues[uint(TokenIOLib.DailySpending.Limit)] = initDailyLimit;
        dailyValues[uint(TokenIOLib.DailySpending.Remainder)] = initDailyLimit;
        dailyValues[uint(TokenIOLib.DailySpending.Period)] = now;

        uint[2] memory creditValues;
        creditValues[uint(TokenIOLib.Credit.Limit)] = 0;
        creditValues[uint(TokenIOLib.Credit.Drawdown)] = 0;

        tokenIO.accountNumber[msg.sender] = accNum; // Msg.sender is CB, CB == 1
        tokenIO.accountDetails[accNum] = TokenIOLib.Account({
            equity: tokenIO.totalSupply,
            creditValues: creditValues,
            dailyValues: dailyValues,
            parentID: accNum, // CB has no parents; set to itself;
            childBalances: 0, // CB has not extended any credit balances to children
            firstSender: accNum
        });
    }

    function transfer(address to, uint value) public returns (bool) {
        return tokenIO.transferFunds(msg.sender, to, value);
    }

    function transferCredit(address to, uint value) public returns (bool) {
        return tokenIO.transferCredit(msg.sender, to, value);
    }

    function netBalanceOf(address account) public view returns (int) {
        return tokenIO.netBalanceOf(account);
    }

    function balanceOf(address account) public view returns (uint) {
        return tokenIO.balanceOf(account);
    }

    function creditLineDrawdownOf(address account) public view returns (uint) {
        return tokenIO.creditLineDrawdownOf(account);
    }

}
