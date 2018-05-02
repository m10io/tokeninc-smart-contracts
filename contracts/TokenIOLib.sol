pragma solidity 0.4.23;

import "./SafeMath.sol";


library TokenIOLib {

    using SafeMath for uint;

    enum AccountSummary {
        SpendingLimit,
        SpendingRemainder,
        SpendingPeriod,
        SpendingDuration,
        Balance,
        ChildBalance,
        CreditLimit,
        CreditDrawdown,
        FrozenBalance
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
    // NOTE:
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
        uint[9] summary;
        // uint[2] fee; // NOTE: Necessary as part of account structure, or just transaction?
        mapping(address => bool) allowed;
        bool approved; // NOTE: Approval comes from bank or CB;
        uint parentID;
        // uint firstSender; // NOTE: Is this typically the parent?
        bool[11] kyc;
        uint8 numKYCAttributes;
    }

    struct Data {
        uint totalSupply;
        uint decimals;
        uint accountNumbers;
        uint totalFrozen;
        string symbol;
        string name;
        string currencyTLA;
        address centralBank;
        mapping(address => uint) accountNumber;
        mapping(uint => Account) accountDetails;
        uint[5] durations;
        uint[9] feeValues;
    }

    function balanceOf(Data storage self, address account) internal view returns (uint) {
        Account storage user = self.accountDetails[self.accountNumber[account]];
        return user.summary[uint(AccountSummary.Balance)];
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

        uint drawdown = user.summary[uint(AccountSummary.CreditDrawdown)];

        // NOTE: Add Frozen balance to netBalanceOf method or add a second method just for frozen funds.
        uint totalBalance = user.summary[uint(AccountSummary.Balance)].add(user.summary[uint(AccountSummary.ChildBalance)]);

        if (drawdown > totalBalance) {
            return (int(drawdown.sub(totalBalance)) * -1);
        } else {
            return int(totalBalance.sub(drawdown));
        }
    }

    function creditLineDrawdownOf(Data storage self, address account) internal view returns (uint) {
        Account storage user = self.accountDetails[self.accountNumber[account]];
        return user.summary[uint(AccountSummary.CreditDrawdown)];
    }

    function updateCredit(Data storage self, address to, uint creditAmount) internal returns (bool) {
        Account storage receiver = self.accountDetails[self.accountNumber[to]];

        require(receiver.summary[uint(AccountSummary.CreditLimit)] > 0);

        require(receiver.summary[uint(AccountSummary.CreditDrawdown)].add(creditAmount) <= receiver.summary[uint(AccountSummary.CreditLimit)]);

        // Increase receiver creditLineDrawdown value;
        receiver.summary[uint(AccountSummary.CreditDrawdown)] = receiver.summary[uint(AccountSummary.CreditDrawdown)].add(creditAmount);

        return true;

    }

    function updateSpending(Data storage self, address from, uint amount) internal returns (bool) {
        Account storage sender = self.accountDetails[self.accountNumber[from]];

        // Spend limit must be non-zero to transfer any amount
        require(sender.summary[uint(AccountSummary.SpendingLimit)] > 0);

        // Check if the Spending Duration has expired
        if (
            now.sub(sender.summary[uint(AccountSummary.SpendingPeriod)]) >
            sender.summary[uint(AccountSummary.SpendingDuration)]
        ) {
            // Set the updated period to current time
            // TODO: Determine the new time to reset the period to.
            // See https://github.com/EmergentFinancial/tokeninc-smart-contracts/issues/2
            sender.summary[uint(AccountSummary.SpendingPeriod)] = now;

            // Reset Remainder balance back to limit;
            sender.summary[uint(AccountSummary.SpendingRemainder)] = sender.summary[uint(AccountSummary.SpendingLimit)];
        }

        // Ensure the Remainder amount is greater than or equal to the amount sending
        require(sender.summary[uint(AccountSummary.SpendingRemainder)] >= amount);

        // Decrease Spending Remainder
        sender.summary[uint(AccountSummary.SpendingRemainder)] =
            sender.summary[uint(AccountSummary.SpendingRemainder)].sub(amount);

        return true;
    }

    function transferCredit(Data storage self, address from, address to, uint amount) internal returns (bool) {
        Account storage sender = self.accountDetails[self.accountNumber[from]];
        // Account storage receiver = self.accountDetails[self.accountNumber[to]];

        // Ensure the sender has enough funds to extend credit
        require(sender.summary[uint(AccountSummary.Balance)] > amount);

        // Ensure the sender's parent has not exceeded credit line?

        // Ensure the receiver's credit limit is not exceeded;
        require(updateCredit(self, to, amount));

        // Ensure the sender's daily limit is not exceeded;
        require(updateSpending(self, from, amount));


        // Subtract equity from the sender's amount
        sender.summary[uint(AccountSummary.Balance)] = sender.summary[uint(AccountSummary.Balance)].sub(amount);

        // Add amount to sender's child balances
        sender.summary[uint(AccountSummary.ChildBalance)] = sender.summary[uint(AccountSummary.ChildBalance)].add(amount);

        return true;
    }

    function transferFunds(Data storage self, address from, address to, uint amount) internal returns (bool) {
        // Ensure receiver has an account established;
        require(self.accountNumber[to] != 0);

        Account storage sender = self.accountDetails[self.accountNumber[from]];
        Account storage receiver = self.accountDetails[self.accountNumber[to]];
        Account storage receiverParent = self.accountDetails[receiver.parentID];

        // Ensure sender has enough funds to transfer amount
        require(sender.summary[uint(AccountSummary.Balance)] > amount);

        // Ensure spending amounts are updated for sender
        require(updateSpending(self, from, amount));

        // TODO: Calculate fees; Transfer amount net of fees; Fees are held by the contract
        uint fee = calculateFeeAmount(self, from, to, amount);

        // NOTE: Fees should be sent to "first sender" or receiver parent address
        receiverParent.summary[uint(AccountSummary.Balance)] = receiverParent.summary[uint(AccountSummary.Balance)].add(fee);

        // Subtract equity from the sender's amount
        sender.summary[uint(AccountSummary.Balance)] = sender.summary[uint(AccountSummary.Balance)].sub(amount);

        // Add equity to the receiver's amount
        receiver.summary[uint(AccountSummary.Balance)] = receiver.summary[uint(AccountSummary.Balance)].add(amount.sub(fee));

        return true;
    }

    function setCreditLimit(Data storage self, address admin, address account, uint limit) internal returns (bool) {
        Account storage sender = self.accountDetails[self.accountNumber[account]];
        // Account storage parent = self.accountDetails[sender.parentID];

        // Ensure admin is allowed for the account;
        require(sender.allowed[admin]);

        // Ensure the parent credit limit is greater than the child limit ?
        // require(parent.summary[uint(AccountSummary.CreditLimit)] > limit);

        // Ensure the limit set is not lower than the current credit drawdown; ?
        require(sender.summary[uint(AccountSummary.CreditDrawdown)] < limit);

        //
        sender.summary[uint(AccountSummary.CreditLimit)] = limit;

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

    function newAccount(Data storage self, address parentAccount, address accountAddress, bool isAdmin) internal returns (bool) {
        // Ensure the account does not already exist
        require(self.accountNumber[accountAddress] == 0);

        // Ensure Parent Account Exists if not admin
        if (!isAdmin) {
            require(self.accountNumber[parentAccount] != 0);
        }

        // Increment the account number for the new account;
        self.accountNumber[accountAddress] = ++self.accountNumbers;

        // Create the account structure
        Account storage account = self.accountDetails[self.accountNumber[accountAddress]];

        // Set the parentID of the account to the admin's accountNumber
        account.parentID = self.accountNumber[parentAccount];

        // account.firstSender = self.accountNumber[admin]; Could just be parent?

        // Ensure the admin is allowed to make changes for the account;
        account.allowed[parentAccount] = true;

        if (isAdmin) {
            // Initially Set Approved to true if new account is Admin; defaults to false;
            account.approved = true;
        }

        // Initially Establish that KYC is required & attributes are 0
        account.kyc[uint(KYC.Required)] = true;
        account.numKYCAttributes = 0;

        // Establish an Initial Spending Limit
        account.summary[uint(AccountSummary.SpendingLimit)] = 5000 * 10**self.decimals;

        // Emit LogNewAccount Event To Alert

        return true;
    }

    function approveAccount(Data storage self, address admin, address accountAddress) internal returns (bool) {
        Account storage account = self.accountDetails[self.accountNumber[accountAddress]];

        // Require the approval comes from an allowed admin;
        require(account.allowed[admin]);

        // Ensure the account is currently not approved;
        require(!account.approved);

        account.approved = true;

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
            } else if (account.numKYCAttributes < 7) {
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
        return account.summary[uint(AccountSummary.SpendingLimit)];
    }



}
