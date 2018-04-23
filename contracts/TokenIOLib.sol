pragma solidity 0.4.23;

import "./SafeMath.sol";


library TokenIOLib {

    using SafeMath for uint;

    enum Spending {
        Limit, // Does not change, unless set by admin
        Remainder, // Updated during each daily period
        Period,
        Duration
    }

    enum Credit {
        Limit,
        Drawdown
    }

    enum Durations {
        Day, // 86400 seconds
        Week, // 604800 seconds
        Month, // 2419200 seconds
        Quarter, // 7257600 seconds
        Year // 29030400 seconds
    }

    enum Fees {
        CoreMin,
        CoreMax,
        CoreBps,
        Flat,
        MultiplierHigh, // Core Rate x4
        MultiplierMedium, // Core Rate x2
        MultiplierLow, // Core Rate x1
        LinkAccount,
        AddKYC
    }

    // NOTE: Discuss which attributes should be documented
    enum KYC {
        Name,
        Phone,
        Email,
        PrimaryAddress,
        SecondaryAddress,
        SSN, // Too U.S. Centric? Maybe NationalIdentification
        Passport, //
        PhotoID, // Driver's License
        License, // Business Licenses, etc.
        Required
    }

    struct Account {
        uint equity;
        uint[2] credit;
        uint[4] spending;
        // uint[2] fee; // NOTE: Necessary as part of account structure, or just transaction?
        mapping(address => bool) allowed;
        uint parentID;
        uint childBalances;
        uint firstSender;
        bool[11] kyc;
        uint8 numKYCAttributes;
    }

    struct Data {
        uint totalSupply;
        uint decimals;
        uint accountNumbers;
        string symbol;
        string name;
        string currencyTLA;
        mapping(address => uint) accountNumber;
        mapping(uint => Account) accountDetails;
        uint[5] durations;
        uint[9] feeValues;
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

        if (user.credit[uint(Credit.Drawdown)] > user.equity.add(user.childBalances)) {
            return (int(user.credit[uint(Credit.Drawdown)].sub(user.equity.add(user.childBalances))) * -1);
        } else {
            return int(user.equity.add(user.childBalances).sub(user.credit[uint(Credit.Drawdown)]));
        }
    }

    function creditLineDrawdownOf(Data storage self, address account) internal view returns (uint) {
        Account storage user = self.accountDetails[self.accountNumber[account]];
        return user.credit[uint(Credit.Drawdown)];
    }

    function updateCredit(Data storage self, address to, uint creditAmount) internal returns (bool) {
        Account storage receiver = self.accountDetails[self.accountNumber[to]];

        require(receiver.credit[uint(Credit.Limit)] > 0);

        require(receiver.credit[uint(Credit.Drawdown)].add(creditAmount) <= receiver.credit[uint(Credit.Limit)]);

        // Increase receiver creditLineDrawdown value;
        receiver.credit[uint(Credit.Drawdown)] = receiver.credit[uint(Credit.Drawdown)].add(creditAmount);

        return true;

    }

    function updateSpending(Data storage self, address from, uint amount) internal returns (bool) {
        Account storage sender = self.accountDetails[self.accountNumber[from]];

        // Spend limit must be non-zero to transfer any amount
        require(sender.spending[uint(Spending.Limit)] > 0);

        // Check if the Spending Duration has expired
        if (
            now.sub(sender.spending[uint(Spending.Period)]) >
            sender.spending[uint(Spending.Duration)]
        ) {
            // Set the updated period to current time
            sender.spending[uint(Spending.Period)] = now;

            // Reset Remainder balance back to limit;
            sender.spending[uint(Spending.Remainder)] = sender.spending[uint(Spending.Limit)];
        }

        // Ensure the Remainder amount is greater than or equal to the amount sending
        require(sender.spending[uint(Spending.Remainder)] >= amount);

        // Decrease Spending Remainder
        sender.spending[uint(Spending.Remainder)] =
            sender.spending[uint(Spending.Remainder)].sub(amount);

        return true;
    }

    function transferCredit(Data storage self, address from, address to, uint amount) internal returns (bool) {
        Account storage sender = self.accountDetails[self.accountNumber[from]];
        // Account storage receiver = self.accountDetails[self.accountNumber[to]];

        // Ensure the sender has enough funds to extend credit
        require(sender.equity > amount);

        // Ensure the sender's parent has not exceeded credit line?

        // Ensure the receiver's credit limit is not exceeded;
        require(updateCredit(self, to, amount));

        // Ensure the sender's daily limit is not exceeded;
        require(updateSpending(self, from, amount));


        // Subtract equity from the sender's amount
        sender.equity = sender.equity.sub(amount);

        // Add amount to sender's child balances
        sender.childBalances = sender.childBalances.add(amount);

        return true;
    }

    function transferFunds(Data storage self, address from, address to, uint amount) internal returns (bool) {
        // Ensure receiver has an account established;
        require(self.accountNumber[to] != 0);

        Account storage sender = self.accountDetails[self.accountNumber[from]];
        Account storage receiver = self.accountDetails[self.accountNumber[to]];
        Account storage vault = self.accountDetails[self.accountNumber[address(this)]];

        // Ensure sender has enough funds to transfer amount
        require(sender.equity > amount);

        // Ensure spending amounts are updated for sender
        require(updateSpending(self, from, amount));

        // TODO: Calculate fees; Transfer amount net of fees; Fees are held by the contract
        uint fee = calculateFeeAmount(self, from, to, amount);

        // Send Fees to this contract's (vault) address
        vault.equity = vault.equity.add(fee);

        // Subtract equity from the sender's amount
        sender.equity = sender.equity.sub(amount);

        // Add equity to the receiver's amount
        receiver.equity = receiver.equity.add(amount.sub(fee));

        return true;
    }

    function setCreditLimit(Data storage self, address admin, address account, uint limit) internal returns (bool) {
        Account storage sender = self.accountDetails[self.accountNumber[account]];
        // Account storage parent = self.accountDetails[sender.parentID];

        // Ensure admin is allowed for the account;
        require(sender.allowed[admin]);

        // Ensure the parent credit limit is greater than the child limit ?
        // require(parent.credit[uint(Credit.Limit)] > limit);

        // Ensure the limit set is not lower than the current credit drawdown; ?
        require(sender.credit[uint(Credit.Drawdown)] < limit);

        //
        sender.credit[uint(Credit.Limit)] = limit;

        return true;
    }

    function linkAccount(Data storage self, address admin, address accountAddress, address newAccountAddress) internal returns (bool) {
        Account storage account = self.accountDetails[self.accountNumber[accountAddress]];

        // Ensure only the admin of this account can link to another account;
        require(account.allowed[admin]);

        // Link new account address with existing account number
        self.accountNumber[newAccountAddress] = self.accountNumber[accountAddress];

        // Add Fee for Linking Account; Pay to admin?
        uint fee = self.feeValues[uint(Fees.LinkAccount)];
        require(transferFunds(self, accountAddress, admin, fee));

        return true;
    }

    function newAccount(Data storage self, address admin, address accountAddress) internal returns (bool) {
        // Ensure the account does not already exist
        require(self.accountNumber[accountAddress] == 0);

        // Increment the account number for the new account;
        self.accountNumber[accountAddress] = ++self.accountNumbers;

        // Create the account structure
        Account storage account = self.accountDetails[self.accountNumber[accountAddress]];

        // Set the parentID of the account to the admin's accountNumber
        account.parentID = self.accountNumber[admin];

        // account.firstSender = self.accountNumber[admin]; Could just be parent?

        // Ensure the admin is allowed to make changes for the account;
        account.allowed[admin] = true;

        // Initially Establish that KYC is required & attributes are 0
        account.kyc[uint(KYC.Required)] = true;
        account.numKYCAttributes = 0;

        // Establish an Initial Spending Limit
        account.spending[uint(Spending.Limit)] = 5000 * 10**5;

        return true;
    }

    function addKYCAttribute(Data storage self, address admin, address accountAddress, KYC attribute) internal returns (bool) {
        Account storage account = self.accountDetails[self.accountNumber[accountAddress]];

        require(account.allowed[admin]);

        account.kyc[uint(attribute)] = true;
        account.numKYCAttributes += 1;

        return true;
    }

    // Note the fee Schedule is represented as Basis Points
    function getFeeSchedule(Data storage self, address accountAddress) internal view returns (uint basisPoints) {
        Account storage account = self.accountDetails[self.accountNumber[accountAddress]];

        if (!account.kyc[uint(KYC.Required)] && account.parentID != 0) {
            // Flat fee for accounts where KYC is not required
            return self.feeValues[uint(Fees.CoreMin)];
        } else {
            // Determine fee schedule based on KYC attributes
            if (account.numKYCAttributes == 0) {
                return self.feeValues[uint(Fees.CoreMax)];
            } else if(account.numKYCAttributes < 7) {
                return self.feeValues[uint(Fees.CoreBps)];
            } else {
                return self.feeValues[uint(Fees.CoreMin)];
            }
        }
    }

    function getFeeMultiplier(Data storage self, address from, address to) internal view returns (uint) {
        Account storage sender = self.accountDetails[self.accountNumber[from]];
        Account storage receiver = self.accountDetails[self.accountNumber[to]];

        if (sender.numKYCAttributes == 0 && receiver.numKYCAttributes == 0) {
            return self.feeValues[uint(Fees.MultiplierHigh)];
        } else if ((sender.numKYCAttributes == 0 && receiver.numKYCAttributes > 0) ||
            (sender.numKYCAttributes > 0 && receiver.numKYCAttributes == 0)) {
            return self.feeValues[uint(Fees.MultiplierMedium)];
        } else {
            return self.feeValues[uint(Fees.MultiplierLow)];
        }
    }


    function calculateFeeAmount(Data storage self, address from, address to, uint amount) internal view returns (uint) {
        uint feesBPS = (getFeeSchedule(self, from).add(getFeeSchedule(self, to))).div(2);
        uint multiplier = getFeeMultiplier(self, from, to);

        uint fees = (amount.mul(feesBPS.mul(multiplier))).div(10000);

        return fees;

    }

    function getSpendingLimit(Data storage self, address accountAddress) internal view returns (uint) {
        Account storage account = self.accountDetails[self.accountNumber[accountAddress]];
        return account.spending[uint(Spending.Limit)];
    }



}
