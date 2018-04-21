pragma solidity 0.4.23;

import "./SafeMath.sol";

library TokenIOLib {

    using SafeMath for uint;

    enum Spending {
        Limit, // Does not change
        Remainder, // Updated during each daily period
        Period,
        Duration
    }

    enum Credit {
        Limit,
        Drawdown
    }

    struct Account {
        uint equity;
        uint[2] creditValues;
        uint[4] spendingValues;
        uint parentID;
        uint childBalances;
        uint firstSender;
    }


    struct Data {
        uint totalSupply;
        mapping(address => uint) accountNumber;
        mapping(uint => Account) accountDetails;
    }

    function balanceOf(Data storage self, address account) internal view returns (uint) {
        Account storage user = self.accountDetails[self.accountNumber[account]];
        return user.equity;
    }

    function netBalanceOf(Data storage self, address account) internal view returns (int) {
        Account storage user = self.accountDetails[self.accountNumber[account]];

        // NOTE: Converting from uint => int introduces possibility of range limit error
        // Ex: uint(5-8) == 115792089237316195423570985008687907853269984665640564039457584007913129639933
        // See: https://ethereum.stackexchange.com/questions/6947/math-operation-between-int-and-uint
        //
        // NOTE: SafeMath Library does not cover int type;
        // TODO: Add int math functions.
        //
        // Return the equity + liabity of account
        // equity == checking/saving/deposit/money accounts
        // liability == credit line / auto

        if (user.creditValues[uint(Credit.Drawdown)] > user.equity.add(user.childBalances)) {
            return (int(user.creditValues[uint(Credit.Drawdown)].sub(user.equity.add(user.childBalances))) * -1);
        } else {
            return int(user.equity.add(user.childBalances).sub(user.creditValues[uint(Credit.Drawdown)]));
        }
    }

    function creditLineDrawdownOf(Data storage self, address account) internal view returns (uint) {
        Account storage user = self.accountDetails[self.accountNumber[account]];
        return user.creditValues[uint(Credit.Drawdown)];
    }

    function updateCredit(Data storage self, address to, uint creditAmount) internal returns (bool) {
        Account storage receiver = self.accountDetails[self.accountNumber[to]];

        if (receiver.creditValues[uint(Credit.Limit)] != 0) {
            require(receiver.creditValues[uint(Credit.Drawdown)].add(creditAmount) < receiver.creditValues[uint(Credit.Limit)]);
            // Increase receiver creditLineDrawdown value;
            receiver.creditValues[uint(Credit.Drawdown)] = receiver.creditValues[uint(Credit.Drawdown)].add(creditAmount);
            return true;
        } else {
            // Credit Limit must be non-zero to accept credit.
            return false;
        }
    }

    function updateDailySpending(Data storage self, address from, uint amount) internal returns (bool) {
        Account storage sender = self.accountDetails[self.accountNumber[from]];

        // If the user has a daily spend limit, require sender to have greater
        // than or equal to daily remaining limit;
        if (sender.spendingValues[uint(Spending.Limit)] > 0) {

            // Check if the Daily Spending Period has expired
            if (
                now.sub(sender.spendingValues[uint(Spending.Period)]) >
                sender.spendingValues[uint(Spending.Duration)]
            ) {
                // Reset Remainder balance back to limit;
                sender.spendingValues[uint(Spending.Remainder)] = sender.spendingValues[uint(Spending.Limit)];
            }

            // Ensure the Remainder amount is greater than or equal to the amount sending
            require(sender.spendingValues[uint(Spending.Remainder)] >= amount);

            // Decrease Daily Spending Remainder
            sender.spendingValues[uint(Spending.Remainder)] =
                sender.spendingValues[uint(Spending.Remainder)].sub(amount);

            return true;

        } else {
            // Daily spend limit must be non-zero to transfer any amount
            return false;
        }
    }

    function transferCredit(Data storage self, address from, address to, uint amount) internal returns (bool) {
        Account storage sender = self.accountDetails[self.accountNumber[from]];
        Account storage receiver = self.accountDetails[self.accountNumber[to]];


        // Ensure the sender has enough funds to extend credit
        require(sender.equity > amount);

        // Ensure the receiver's credit limit is not exceeded;
        require(updateCredit(self, to, amount));

        // Ensure the receiver's daily limit is not exceeded;
        require(updateDailySpending(self, to, amount));


        // Set first sender if new account
        if (receiver.firstSender == 0) {
            receiver.firstSender = self.accountNumber[from];
        }

        // Ensure receiver has not exceeded credit limit for account
        // after adding the amount to the beginning creditLineDrawdown
        // require(receiver.creditLineDrawdown.add(amount) < receiver.creditLimit);

        // Subtract equity from the sender's amount
        sender.equity = sender.equity.sub(amount);

        // Add amount to sender's child balances
        sender.childBalances = sender.childBalances.add(amount);



        return true;
    }

    function transferFunds(Data storage self, address from, address to, uint amount) internal returns (bool) {
        Account storage sender = self.accountDetails[self.accountNumber[from]];
        Account storage receiver = self.accountDetails[self.accountNumber[to]];

        // Ensure sender has enough funds to transfer amount
        require(sender.equity > amount);
        require(updateDailySpending(self, from, amount));

        // Set first sender if new account
        if (receiver.firstSender == 0) {
            receiver.firstSender = self.accountNumber[from];
        }

        // Subtract equity from the sender's amount
        sender.equity = sender.equity.sub(amount);
        // Add equity to the receiver's amount
        receiver.equity = receiver.equity.add(amount);

        return true;
    }




}
