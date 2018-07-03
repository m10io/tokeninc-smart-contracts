* [TokenIOLib](#tokeniolib)
  * [getFxUSDAmount](#function-getfxusdamount)
  * [getFeeMin](#function-getfeemin)
  * [setTokenDecimals](#function-settokendecimals)
  * [setFeeMax](#function-setfeemax)
  * [getFirmFromAuthority](#function-getfirmfromauthority)
  * [getTokenTLA](#function-gettokentla)
  * [getFeeFlat](#function-getfeeflat)
  * [getTokenAllowance](#function-gettokenallowance)
  * [forceTransfer](#function-forcetransfer)
  * [getTokenDecimals](#function-gettokendecimals)
  * [isRegisteredAuthority](#function-isregisteredauthority)
  * [setAccountStatus](#function-setaccountstatus)
  * [isRegisteredToFirm](#function-isregisteredtofirm)
  * [deposit](#function-deposit)
  * [setTokenName](#function-settokenname)
  * [verifyAccount](#function-verifyaccount)
  * [setMasterFeeContract](#function-setmasterfeecontract)
  * [getTokenFrozenBalance](#function-gettokenfrozenbalance)
  * [getTokenVersion](#function-gettokenversion)
  * [verifyAccounts](#function-verifyaccounts)
  * [getAccountSpendingLimit](#function-getaccountspendinglimit)
  * [setDeprecatedContract](#function-setdeprecatedcontract)
  * [approveAllowance](#function-approveallowance)
  * [setForwardedAccount](#function-setforwardedaccount)
  * [getTokenName](#function-gettokenname)
  * [calculateFees](#function-calculatefees)
  * [setFeeBPS](#function-setfeebps)
  * [getKYCApproval](#function-getkycapproval)
  * [isRegisteredFirm](#function-isregisteredfirm)
  * [setFeeFlat](#function-setfeeflat)
  * [getTokenNameSpace](#function-gettokennamespace)
  * [getAccountSpendingRemaining](#function-getaccountspendingremaining)
  * [getAccountSpendingPeriod](#function-getaccountspendingperiod)
  * [getTokenBalance](#function-gettokenbalance)
  * [transfer](#function-transfer)
  * [setFxUSDBPSRate](#function-setfxusdbpsrate)
  * [setTokenSymbol](#function-settokensymbol)
  * [setTokenFrozenBalance](#function-settokenfrozenbalance)
  * [getFeeContract](#function-getfeecontract)
  * [isContractDeprecated](#function-iscontractdeprecated)
  * [setKYCApproval](#function-setkycapproval)
  * [setAccountSpendingPeriod](#function-setaccountspendingperiod)
  * [getFxUSDBPSRate](#function-getfxusdbpsrate)
  * [getTxStatus](#function-gettxstatus)
  * [getTokenSymbol](#function-gettokensymbol)
  * [updateAllowance](#function-updateallowance)
  * [getAccountStatus](#function-getaccountstatus)
  * [setRegisteredFirm](#function-setregisteredfirm)
  * [execSwap](#function-execswap)
  * [setTokenNameSpace](#function-settokennamespace)
  * [getAccountSpendingAmount](#function-getaccountspendingamount)
  * [setAccountSpendingLimit](#function-setaccountspendinglimit)
  * [setTokenVersion](#function-settokenversion)
  * [getMasterFeeContract](#function-getmasterfeecontract)
  * [getFeeMax](#function-getfeemax)
  * [setTokenTLA](#function-settokentla)
  * [withdraw](#function-withdraw)
  * [setFeeContract](#function-setfeecontract)
  * [transferFrom](#function-transferfrom)
  * [getForwardedAccount](#function-getforwardedaccount)
  * [setTxStatus](#function-settxstatus)
  * [setFeeMin](#function-setfeemin)
  * [updateAccountSpendingPeriod](#function-updateaccountspendingperiod)
  * [setRegisteredAuthority](#function-setregisteredauthority)
  * [getFeeBPS](#function-getfeebps)
  * [getTokenSupply](#function-gettokensupply)
  * [setAccountSpendingAmount](#function-setaccountspendingamount)
  * [LogApproval](#event-logapproval)
  * [LogDeposit](#event-logdeposit)
  * [LogWithdraw](#event-logwithdraw)
  * [LogTransfer](#event-logtransfer)
  * [LogKYCApproval](#event-logkycapproval)
  * [LogAccountStatus](#event-logaccountstatus)
  * [LogFxSwap](#event-logfxswap)
  * [LogAccountForward](#event-logaccountforward)
  * [LogNewAuthority](#event-lognewauthority)


---
# TokenIOLib


## *function* getFxUSDAmount

TokenIOLib.getFxUSDAmount(self, currency, fxAmount) `view` `14518dc3`

**Return the foreign currency USD exchanged amount**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *string* | currency | The TokenIO currency symbol (e.g. USDx, JPYx, GBPx) |
| *uint256* | fxAmount | Amount of foreign currency to exchange into USD |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | amount | Returns the foreign currency amount in USD |

## *function* getFeeMin

TokenIOLib.getFeeMin(self, contractAddress) `view` `1bd0c750`

**Get the minimum fee of the contract address; typically TokenIOFeeContract**

> | This method has an `internal` view

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | contractAddress | Contract address of the queryable interface |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | feeMin | Returns the minimum fees associated with the contract address |

## *function* setTokenDecimals

TokenIOLib.setTokenDecimals(self, currency, tokenDecimals) `nonpayable` `1cc0da1e`

**Set the token decimals for Token interfaces**

> This method must be set by the token interface's setParams() method| This method has an `internal` view This method is not set to the address of the contract, rather is maped to currencyTo derive decimal value, divide amount by 10^decimal representation (e.g. 10132 / 10**2 == 101.32)

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *string* | currency | TokenIO TSM currency symbol (e.g. USDx) |
| *uint256* | tokenDecimals | Decimal representation of the token contract unit amount |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully called from another contract |

## *function* setFeeMax

TokenIOLib.setFeeMax(self, feeMax) `nonpayable` `1fada8e2`

**Set maximum fee for contract interface**

> Transaction fees can be set by the TokenIOFeeContractFees vary by contract interface specified `feeContract`| This method has an `internal` view

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *uint256* | feeMax | Maximum fee for interface contract transactions |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully called from another contract |

## *function* getFirmFromAuthority

TokenIOLib.getFirmFromAuthority(self, authorityAddress) `view` `2268c026`

**Get the issuer firm registered to the authority Ethereum address**

> | Only one firm can be registered per authority

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | authorityAddress | Ethereum address of the firm authority to query |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *string* | issuerFirm | Name of the firm registered to authority |

## *function* getTokenTLA

TokenIOLib.getTokenTLA(self, contractAddress) `view` `26db6a78`

**Get the token Three letter abbreviation (TLA) for Token interfaces**

> This method must be set by the token interface's setParams() method| This method has an `internal` view

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | contractAddress | Contract address of the queryable interface |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *string* | tokenTLA | TLA of the token contract |

## *function* getFeeFlat

TokenIOLib.getFeeFlat(self, contractAddress) `view` `2bd67a0c`

**Get the flat fee of the contract address; typically TokenIOFeeContract**

> | This method has an `internal` view

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | contractAddress | Contract address of the queryable interface |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | feeFlat | Returns the flat fees associated with the contract address |

## *function* getTokenAllowance

TokenIOLib.getTokenAllowance(self, currency, account, spender) `view` `2c56a4c2`

**Get the token spender allowance for a given account**

> | This method has an `internal` view

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *string* | currency | undefined |
| *address* | account | Ethereum address of account holder |
| *address* | spender | Ethereum address of spender |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | allowance | Returns the allowance of a given spender for a given account |

## *function* forceTransfer

TokenIOLib.forceTransfer(self, currency, from, to, amount, data) `nonpayable` `30e67b59`

**Low-level transfer method**

> | This method has an `internal` view | This method does not include fees or approved allowances. | This method is only for authorized interfaces to use (e.g. TokenIOFX)

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *string* | currency | TokenIO TSM currency symbol (e.g. USDx) |
| *address* | from | Ethereum address of account to send currency amount from |
| *address* | to | Ethereum address of account to send currency amount to |
| *uint256* | amount | Value of currency to transfer |
| *bytes* | data | Arbitrary bytes data to include with the transaction |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Return true if successfully called from another contract |

## *function* getTokenDecimals

TokenIOLib.getTokenDecimals(self, currency) `view` `32ea20c7`

**Get the token decimals for Token interfaces**

> This method must be set by the token interface's setParams() method| This method has an `internal` view

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *string* | currency | TokenIO TSM currency symbol (e.g. USDx) |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | tokenDecimals | Decimals of the token contract |

## *function* isRegisteredAuthority

TokenIOLib.isRegisteredAuthority(self, authorityAddress) `view` `345f0f68`

**Return if an authority address is registered**

> | This also checks the status of the registered issuer firm

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | authorityAddress | Ethereum address of the firm authority to query |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | registered | Return if the authority is registered |

## *function* setAccountStatus

TokenIOLib.setAccountStatus(self, account, isAllowed, issuerFirm) `nonpayable` `36c954e0`

**Set the global approval status (true/false) for a given account**

> | This method has an `internal` view | Every account must be permitted to be able to use transfer() & transferFrom() methods | To gain approval for an account, register at https://tsm.token.io/sign-up

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | account | Ethereum address of account holder |
| *bool* | isAllowed | Boolean (true/false) global status for a given account |
| *string* | issuerFirm | Firm name for issuing approval |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully called from another contract |

## *function* isRegisteredToFirm

TokenIOLib.isRegisteredToFirm(self, issuerFirm, authorityAddress) `view` `36e5afc2`

**Return the boolean (true/false) status if an authority is registered to an issuer firm**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *string* | issuerFirm | Name of the issuer firm |
| *address* | authorityAddress | Ethereum address of the firm authority to query |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | registered | Return if the authority is registered with the issuer firm |

## *function* deposit

TokenIOLib.deposit(self, currency, account, amount, issuerFirm) `nonpayable` `36ead807`

**Deposit an amount of currency into the Ethereum account holder**

> | The total supply of the token increases only when new funds are deposited 1:1 | This method should only be called by authorized issuer firms

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *string* | currency | TokenIO TSM currency symbol (e.g. USDx) |
| *address* | account | Ethereum address of account holder to deposit funds for |
| *uint256* | amount | Value of currency to deposit for account |
| *string* | issuerFirm | Name of the issuing firm authorizing the deposit |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Return true if successfully called from another contract |

## *function* setTokenName

TokenIOLib.setTokenName(self, tokenName) `nonpayable` `3fc4e479`

**Set the token name for Token interfaces**

> This method must be set by the token interface's setParams() method| This method has an `internal` view

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *string* | tokenName | Name of the token contract |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully called from another contract |

## *function* verifyAccount

TokenIOLib.verifyAccount(self, account) `nonpayable` `496062fc`

**Verified KYC and global status for a single account and return true or throw if account is not verified**

> | This method has an `internal` view

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | account | Ethereum address of account holder to verify |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | verified | Returns true if account is successfully verified |

## *function* setMasterFeeContract

TokenIOLib.setMasterFeeContract(self, contractAddress) `nonpayable` `49a8539c`

**Set the master fee contract used as the default fee contract when none is provided**

> | This method has an `internal` view | This value is set in the TokenIOAuthority contract

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | contractAddress | Contract address of the queryable interface |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully called from another contract |

## *function* getTokenFrozenBalance

TokenIOLib.getTokenFrozenBalance(self, currency, account) `view` `4a63c263`

**Get the frozen token balance for a given account**

> | This method has an `internal` view

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *string* | currency | TokenIO TSM currency symbol (e.g. USDx) |
| *address* | account | Ethereum address of account holder |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | frozenBalance | Return the frozen balance of a given account for a specified currency |

## *function* getTokenVersion

TokenIOLib.getTokenVersion(self, contractAddress) `view` `4af2feaf`

**Get the token version for Token interfaces**

> This method must be set by the token interface's setParams() method| This method has an `internal` view

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | contractAddress | Contract address of the queryable interface |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *string* |  | undefined |

## *function* verifyAccounts

TokenIOLib.verifyAccounts(self, accountA, accountB) `nonpayable` `4dc61327`

**Verified KYC and global status for two accounts and return true or throw if either account is not verified**

> | This method has an `internal` view

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | accountA | Ethereum address of first account holder to verify |
| *address* | accountB | Ethereum address of second account holder to verify |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | verified | Returns true if both accounts are successfully verified |

## *function* getAccountSpendingLimit

TokenIOLib.getAccountSpendingLimit(self, account) `view` `4e88e91d`

**Get the account spending limit amount**

> | Each account has it's own daily spending limit

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | account | Ethereum address of the account holder |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | limit | Returns the account spending limit amount |

## *function* setDeprecatedContract

TokenIOLib.setDeprecatedContract(self, contractAddress) `nonpayable` `4f0dbac1`

**Deprecate a contract interface**

> | This is a low-level method to deprecate a contract interface. | This is useful if the interface needs to be updated or becomes out of date

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | contractAddress | Ethereum address of the contract interface |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true if successfully called from another contract |

## *function* approveAllowance

TokenIOLib.approveAllowance(self, spender, amount) `nonpayable` `51911edc`

**Low-level method to set the allowance for a spender**

> | This method is called inside the `approve()` ERC20 method | msg.sender == account holder

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | spender | Ethereum address of account spender |
| *uint256* | amount | Value to set for spender allowance |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Return true if successfully called from another contract |

## *function* setForwardedAccount

TokenIOLib.setForwardedAccount(self, originalAccount, forwardedAccount) `nonpayable` `552da950`

**Set a forwarded address for an account.**

> | This method has an `internal` view | Forwarded accounts must be set by an authority in case of account recovery; | Additionally, the original owner can set a forwarded account (e.g. add a new device, spouse, dependent, etc) | All transactions will be logged under the same KYC information as the original account holder;

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | originalAccount | Original registered Ethereum address of the account holder |
| *address* | forwardedAccount | Forwarded Ethereum address of the account holder |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully called from another contract |

## *function* getTokenName

TokenIOLib.getTokenName(self, contractAddress) `view` `640f855e`

**Get the token name for Token interfaces**

> This method must be set by the token interface's setParams() method| This method has an `internal` view

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | contractAddress | Contract address of the queryable interface |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *string* | tokenName | Name of the token contract |

## *function* calculateFees

TokenIOLib.calculateFees(self, contractAddress, amount) `view` `657e1746`

**Set the frozen token balance for a given account**

> | This method has an `internal` view

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | contractAddress | Contract address of the fee contract |
| *uint256* | amount | Transaction value |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | calculatedFees | Return the calculated transaction fees for a given amount and fee contract |

## *function* setFeeBPS

TokenIOLib.setFeeBPS(self, feeBPS) `nonpayable` `65dcb608`

**Set basis point fee for contract interface**

> Transaction fees can be set by the TokenIOFeeContractFees vary by contract interface specified `feeContract`| This method has an `internal` view

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *uint256* | feeBPS | Basis points fee for interface contract transactions |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully called from another contract |

## *function* getKYCApproval

TokenIOLib.getKYCApproval(self, account) `view` `6668d689`

**Get KYC approval status for the account holder**

> | This method has an `internal` view | All forwarded accounts will use the original account's status

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | account | Ethereum address of account holder |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | status | Returns the KYC approval status for an account holder |

## *function* isRegisteredFirm

TokenIOLib.isRegisteredFirm(self, issuerFirm) `view` `68487eef`

**Return the boolean (true/false) registration status for an issuer firm**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *string* | issuerFirm | Name of the issuer firm |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | registered | Return if the issuer firm has been registered |

## *function* setFeeFlat

TokenIOLib.setFeeFlat(self, feeFlat) `nonpayable` `69ff34d0`

**Set flat fee for contract interface**

> Transaction fees can be set by the TokenIOFeeContractFees vary by contract interface specified `feeContract`| This method has an `internal` view

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *uint256* | feeFlat | Flat fee for interface contract transactions |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully called from another contract |

## *function* getTokenNameSpace

TokenIOLib.getTokenNameSpace(self, currency) `view` `87a10738`

**Get the contract interface address associated with token symbol**

> | This method has an `internal` view

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *string* | currency | TokenIO TSM currency symbol (e.g. USDx) |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | contractAddress | Returns the contract interface address for a symbol |

## *function* getAccountSpendingRemaining

TokenIOLib.getAccountSpendingRemaining(self, account) `view` `9462fce1`

**Return the amount remaining during the current period**

> | Each account has it's own daily spending limit

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | account | Ethereum address of the account holder |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | remainingLimit | undefined |

## *function* getAccountSpendingPeriod

TokenIOLib.getAccountSpendingPeriod(self, account) `view` `9a9675b4`

**Get the Account Spending Period Limit as UNIX timestamp**

> | Each account has it's own daily spending limit | If the current spending period has expired, it will be set upon next `transfer()`  or `transferFrom()` request

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | account | Ethereum address of the account holder |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | period | Returns Unix timestamp of the current spending period |

## *function* getTokenBalance

TokenIOLib.getTokenBalance(self, currency, account) `view` `9d7af4a5`

**Get the token balance for a given account**

> | This method has an `internal` view

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *string* | currency | TokenIO TSM currency symbol (e.g. USDx) |
| *address* | account | Ethereum address of account holder |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | balance | Return the balance of a given account for a specified currency |

## *function* transfer

TokenIOLib.transfer(self, currency, to, amount, data) `nonpayable` `9ed0715b`

**Transfer an amount of currency token from msg.sender account to another specified account**

> This function is called by an interface that is accessible directly to the account holder| This method has an `internal` view | This method uses `forceTransfer()` low-level api

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *string* | currency | TokenIO TSM currency symbol (e.g. USDx) |
| *address* | to | Ethereum address of account to send currency amount to |
| *uint256* | amount | Value of currency to transfer |
| *bytes* | data | Arbitrary bytes data to include with the transaction |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Return true if successfully called from another contract |

## *function* setFxUSDBPSRate

TokenIOLib.setFxUSDBPSRate(self, currency, bpsRate) `nonpayable` `abe36a55`

**Set the foreign currency exchange rate to USD in basis points**

> | This value should always be relative to USD pair; e.g. JPY/USD, GBP/USD, etc.

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *string* | currency | The TokenIO currency symbol (e.g. USDx, JPYx, GBPx) |
| *uint256* | bpsRate | Basis point rate of foreign currency exchange rate to USD |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true if successfully called from another contract |

## *function* setTokenSymbol

TokenIOLib.setTokenSymbol(self, tokenSymbol) `nonpayable` `abec96da`

**Set the token symbol for Token interfaces**

> This method must be set by the token interface's setParams() method| This method has an `internal` view

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *string* | tokenSymbol | Symbol of the token contract |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully called from another contract |

## *function* setTokenFrozenBalance

TokenIOLib.setTokenFrozenBalance(self, currency, account, amount) `view` `acb19f53`

**Set the frozen token balance for a given account**

> | This method has an `internal` view

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *string* | currency | TokenIO TSM currency symbol (e.g. USDx) |
| *address* | account | Ethereum address of account holder |
| *uint256* | amount | Amount of tokens to freeze for account |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Return true if successfully called from another contract |

## *function* getFeeContract

TokenIOLib.getFeeContract(self, contractAddress) `view` `b4af3078`

**Get the fee contract set for a contract interface**

> | This method has an `internal` view | Custom fee pricing can be set by assigning a fee contract to transactional contract interfaces | If a fee contract has not been set by an interface contract, then the master fee contract will be returned

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | contractAddress | Contract address of the queryable interface |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | feeContract | Returns the fee contract associated with a contract interface |

## *function* isContractDeprecated

TokenIOLib.isContractDeprecated(self, contractAddress) `view` `b609663f`

**Return the deprecation status of a contract**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | contractAddress | Ethereum address of the contract interface |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | status | Return deprecation status (true/false) of the contract interface |

## *function* setKYCApproval

TokenIOLib.setKYCApproval(self, account, isApproved, issuerFirm) `nonpayable` `b8a7ab63`

**Set the KYC approval status (true/false) for a given account**

> | This method has an `internal` view | Every account must be KYC'd to be able to use transfer() & transferFrom() methods | To gain approval for an account, register at https://tsm.token.io/sign-up

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | account | Ethereum address of account holder |
| *bool* | isApproved | Boolean (true/false) KYC approval status for a given account |
| *string* | issuerFirm | Firm name for issuing KYC approval |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully called from another contract |

## *function* setAccountSpendingPeriod

TokenIOLib.setAccountSpendingPeriod(self, account, period) `nonpayable` `bf7d9b47`

**Set the Account Spending Period Limit as UNIX timestamp**

> | Each account has it's own daily spending limit

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | account | Ethereum address of the account holder |
| *uint256* | period | Unix timestamp of the spending period |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true is successfully called from a contract |

## *function* getFxUSDBPSRate

TokenIOLib.getFxUSDBPSRate(self, currency) `view` `c49046ab`

**Return the foreign currency USD exchanged amount in basis points**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *string* | currency | The TokenIO currency symbol (e.g. USDx, JPYx, GBPx) |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | bpsRate | undefined |

## *function* getTxStatus

TokenIOLib.getTxStatus(self, txHash) `view` `c8d34c7c`

**Return boolean transaction status if the transaction has been used**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *bytes32* | txHash | keccak256 ABI tightly packed encoded hash digest of tx params |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | txStatus | Returns true if the tx hash has already been set using `setTxStatus()` method |

## *function* getTokenSymbol

TokenIOLib.getTokenSymbol(self, contractAddress) `view` `c90fe5d1`

**Get the token symbol for Token interfaces**

> This method must be set by the token interface's setParams() method| This method has an `internal` view

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | contractAddress | Contract address of the queryable interface |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *string* | tokenSymbol | Symbol of the token contract |

## *function* updateAllowance

TokenIOLib.updateAllowance(self, currency, account, amount) `nonpayable` `cdaa590c`

**Low-level method to update spender allowance for account**

> | This method is called inside the `transferFrom()` method | msg.sender == spender address

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *string* | currency | TokenIO TSM currency symbol (e.g. USDx) |
| *address* | account | Ethereum address of account holder |
| *uint256* | amount | Value to reduce allowance by (i.e. the amount spent) |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Return true if successfully called from another contract |

## *function* getAccountStatus

TokenIOLib.getAccountStatus(self, account) `view` `d773b936`

**Get global approval status for the account holder**

> | This method has an `internal` view | All forwarded accounts will use the original account's status

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | account | Ethereum address of account holder |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | status | Returns the global approval status for an account holder |

## *function* setRegisteredFirm

TokenIOLib.setRegisteredFirm(self, issuerFirm, approved) `nonpayable` `d81ab4e8`

**Method for setting a registered issuer firm**

> | Only Token, Inc. and other authorized institutions may set a registered firm | The TokenIOAuthority.sol interface wraps this method | If the registered firm is unapproved; all authorized addresses of that firm will also be unapproved

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *string* | issuerFirm | Name of the firm to be registered |
| *bool* | approved | Approval status to set for the firm (true/false) |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Return true if successfully called from another contract |

## *function* execSwap

TokenIOLib.execSwap(self, requester, symbolA, symbolB, valueA, valueB, sigV, sigR, sigS, expiration) `nonpayable` `dc062c3d`

**Accepts a signed fx request to swap currency pairs at a given amount;**

> | This method can be called directly between peers | This method does not take transaction fees from the swap

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | requester | address Requester is the orginator of the offer and must match the signature of the payload submitted by the fulfiller |
| *string* | symbolA | Symbol of the currency desired |
| *string* | symbolB | Symbol of the currency offered |
| *uint256* | valueA | Amount of the currency desired |
| *uint256* | valueB | Amount of the currency offered |
| *uint8* | sigV | Ethereum secp256k1 signature V value; used by ecrecover() |
| *bytes32* | sigR | Ethereum secp256k1 signature R value; used by ecrecover() |
| *bytes32* | sigS | Ethereum secp256k1 signature S value; used by ecrecover() |
| *uint256* | expiration | Expiration of the offer; Offer is good until expired |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true if successfully called from another contract |

## *function* setTokenNameSpace

TokenIOLib.setTokenNameSpace(self, currency) `nonpayable` `dfd06cad`

**Set contract interface associated with a given TokenIO currency symbol (e.g. USDx)**

> | This should only be called once from a token interface contract; | This method has an `internal` view | This method is experimental and may be deprecated/refactored

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *string* | currency | TokenIO TSM currency symbol (e.g. USDx) |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully called from another contract |

## *function* getAccountSpendingAmount

TokenIOLib.getAccountSpendingAmount(self, account) `view` `e210824d`

**Return the amount spent during the current period**

> | Each account has it's own daily spending limit

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | account | Ethereum address of the account holder |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | amount | Returns the amount spent by the account during the current period |

## *function* setAccountSpendingLimit

TokenIOLib.setAccountSpendingLimit(self, account, limit) `nonpayable` `e349be5d`

**Set the account spending limit amount**

> | Each account has it's own daily spending limit

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | account | Ethereum address of the account holder |
| *uint256* | limit | Spending limit amount |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true is successfully called from a contract |

## *function* setTokenVersion

TokenIOLib.setTokenVersion(self, tokenVersion) `nonpayable` `e9723fc6`

**Set the token version for Token interfaces**

> This method must be set by the token interface's setParams() method| This method has an `internal` view

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *string* | tokenVersion | Semantic (vMAJOR.MINOR.PATCH | e.g. v0.1.0) version of the token contract |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully called from another contract |

## *function* getMasterFeeContract

TokenIOLib.getMasterFeeContract(self) `view` `eb6baba6`

**Get the master fee contract set via the TokenIOAuthority contract**

> | This method has an `internal` view

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | masterFeeContract | Returns the master fee contract set for TSM. |

## *function* getFeeMax

TokenIOLib.getFeeMax(self, contractAddress) `view` `ec27e7b2`

**Get the maximum fee of the contract address; typically TokenIOFeeContract**

> | This method has an `internal` view

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | contractAddress | Contract address of the queryable interface |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | feeMax | Returns the maximum fees associated with the contract address |

## *function* setTokenTLA

TokenIOLib.setTokenTLA(self, tokenTLA) `nonpayable` `ed04d5e3`

**Set the token three letter abreviation (TLA) for Token interfaces**

> This method must be set by the token interface's setParams() method| This method has an `internal` view

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *string* | tokenTLA | TLA of the token contract |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully called from another contract |

## *function* withdraw

TokenIOLib.withdraw(self, currency, account, amount, issuerFirm) `nonpayable` `ef3a5d37`

**Withdraw an amount of currency from the Ethereum account holder**

> | The total supply of the token decreases only when new funds are withdrawn 1:1 | This method should only be called by authorized issuer firms

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *string* | currency | TokenIO TSM currency symbol (e.g. USDx) |
| *address* | account | Ethereum address of account holder to deposit funds for |
| *uint256* | amount | Value of currency to withdraw for account |
| *string* | issuerFirm | Name of the issuing firm authorizing the withdraw |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Return true if successfully called from another contract |

## *function* setFeeContract

TokenIOLib.setFeeContract(self, feeContract) `nonpayable` `f07f6713`

**Set fee contract for a contract interface**

> feeContract must be a TokenIOFeeContract storage approved contractFees vary by contract interface specified `feeContract`| This method has an `internal` view | This must be called directly from the interface contract

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | feeContract | Set the fee contract for `this` contract address interface |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully called from another contract |

## *function* transferFrom

TokenIOLib.transferFrom(self, currency, from, to, amount, data) `nonpayable` `f2f23a5d`

**Transfer an amount of currency token from account to another specified account via an approved spender account**

> This function is called by an interface that is accessible directly to the account spender| This method has an `internal` view | Transactions will fail if the spending amount exceeds the daily limit | This method uses `forceTransfer()` low-level api | This method implements ERC20 transferFrom() method with approved spender behavior | msg.sender == spender; `updateAllowance()` reduces approved limit for account spender

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *string* | currency | TokenIO TSM currency symbol (e.g. USDx) |
| *address* | from | Ethereum address of account to send currency amount from |
| *address* | to | Ethereum address of account to send currency amount to |
| *uint256* | amount | Value of currency to transfer |
| *bytes* | data | Arbitrary bytes data to include with the transaction |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Return true if successfully called from another contract |

## *function* getForwardedAccount

TokenIOLib.getForwardedAccount(self, account) `view` `f379adad`

**Get the original address for a forwarded account**

> | This method has an `internal` view | Will return the registered account for the given forwarded account

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | account | Ethereum address of account holder |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | registeredAccount | Will return the original account of a forwarded account or the account itself if no account found |

## *function* setTxStatus

TokenIOLib.setTxStatus(self, txHash) `nonpayable` `f55f0287`

**Set transaction status if the transaction has been used**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *bytes32* | txHash | keccak256 ABI tightly packed encoded hash digest of tx params |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Return true if successfully called from another contract |

## *function* setFeeMin

TokenIOLib.setFeeMin(self, feeMin) `nonpayable` `fc9fcfdf`

**Set minimum fee for contract interface**

> Transaction fees can be set by the TokenIOFeeContractFees vary by contract interface specified `feeContract`| This method has an `internal` view

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *uint256* | feeMin | Minimum fee for interface contract transactions |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully called from another contract |

## *function* updateAccountSpendingPeriod

TokenIOLib.updateAccountSpendingPeriod(self, account) `nonpayable` `fd008852`

**Low-level API to ensure the account spending period is always current**

> | This method is internally called by `setAccountSpendingAmount()` to ensure  spending period is always the most current daily period.

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | account | Ethereum address of the account holder |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true is successfully called from a contract |

## *function* setRegisteredAuthority

TokenIOLib.setRegisteredAuthority(self, issuerFirm, authorityAddress, approved) `nonpayable` `fd1347dd`

**Method for setting a registered issuer firm authority**

> | Only Token, Inc. and other approved institutions may set a registered firm | The TokenIOAuthority.sol interface wraps this method | Authority can only be set for a registered issuer firm

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *string* | issuerFirm | Name of the firm to be registered to authority |
| *address* | authorityAddress | Ethereum address of the firm authority to be approved |
| *bool* | approved | Approval status to set for the firm authority (true/false) |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Return true if successfully called from another contract |

## *function* getFeeBPS

TokenIOLib.getFeeBPS(self, contractAddress) `view` `fd7c95ae`

**Get the basis points fee of the contract address; typically TokenIOFeeContract**

> | This method has an `internal` view

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | contractAddress | Contract address of the queryable interface |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | feeBps | Returns the basis points fees associated with the contract address |

## *function* getTokenSupply

TokenIOLib.getTokenSupply(self, currency) `view` `fdf5c005`

**Get the token supply for a given TokenIO TSM currency symbol (e.g. USDx)**

> | This method has an `internal` view

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *string* | currency | TokenIO TSM currency symbol (e.g. USDx) |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | supply | Returns the token supply of the given currency |

## *function* setAccountSpendingAmount

TokenIOLib.setAccountSpendingAmount(self, account, amount) `nonpayable` `fe9b1bb1`

**Set the account spending amount for the daily period**

> | Each account has it's own daily spending limit | This transaction will throw if the new spending amount is greater than the limit | This method is called in the `transfer()` and `transferFrom()` methods

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *TokenIOLib.Data storage* | self | Internal storage proxying TokenIOStorage contract |
| *address* | account | Ethereum address of the account holder |
| *uint256* | amount | Set the amount spent for the daily period |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true is successfully called from a contract |
## *event* LogApproval

TokenIOLib.LogApproval(owner, spender, amount) `c5c187f5`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *address* | owner | indexed |
| *address* | spender | indexed |
| *uint256* | amount | not indexed |

## *event* LogDeposit

TokenIOLib.LogDeposit(currency, account, amount, issuerFirm) `947a2d34`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *string* | currency | not indexed |
| *address* | account | indexed |
| *uint256* | amount | not indexed |
| *string* | issuerFirm | not indexed |

## *event* LogWithdraw

TokenIOLib.LogWithdraw(currency, account, amount, issuerFirm) `59c29e19`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *string* | currency | not indexed |
| *address* | account | indexed |
| *uint256* | amount | not indexed |
| *string* | issuerFirm | not indexed |

## *event* LogTransfer

TokenIOLib.LogTransfer(currency, from, to, amount, data) `704abf61`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *string* | currency | not indexed |
| *address* | from | indexed |
| *address* | to | indexed |
| *uint256* | amount | not indexed |
| *bytes* | data | not indexed |

## *event* LogKYCApproval

TokenIOLib.LogKYCApproval(account, status, issuerFirm) `25a5b7ea`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *address* | account | indexed |
| *bool* | status | not indexed |
| *string* | issuerFirm | not indexed |

## *event* LogAccountStatus

TokenIOLib.LogAccountStatus(account, status, issuerFirm) `0c55be7b`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *address* | account | indexed |
| *bool* | status | not indexed |
| *string* | issuerFirm | not indexed |

## *event* LogFxSwap

TokenIOLib.LogFxSwap(tokenASymbol, tokenBSymbol, tokenAValue, tokenBValue, expiration, transactionHash) `4dc9c027`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *string* | tokenASymbol | not indexed |
| *string* | tokenBSymbol | not indexed |
| *uint256* | tokenAValue | not indexed |
| *uint256* | tokenBValue | not indexed |
| *uint256* | expiration | not indexed |
| *bytes32* | transactionHash | not indexed |

## *event* LogAccountForward

TokenIOLib.LogAccountForward(originalAccount, forwardedAccount) `15c02f89`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *address* | originalAccount | indexed |
| *address* | forwardedAccount | indexed |

## *event* LogNewAuthority

TokenIOLib.LogNewAuthority(authority, issuerFirm) `d62464d6`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *address* | authority | indexed |
| *string* | issuerFirm | not indexed |


---
# TokenIOStorage

Ryan Tate <ryan.michael.tate@gmail.com>

## *function* deleteAddress

TokenIOStorage.deleteAddress(_key) `nonpayable` `0e14a376`

**Delete value for Address associated with bytes32 id key**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *bytes32* | _key | Pointer identifier for value in storage |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully called from another contract |

## *function* getAddress

TokenIOStorage.getAddress(_key) `view` `21f8a721`

**Get value for Address associated with bytes32 id key**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *bytes32* | _key | Pointer identifier for value in storage |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | _value | Returns the Address value associated with the id key |

## *function* deleteBool

TokenIOStorage.deleteBool(_key) `nonpayable` `2c62ff2d`

**Delete value for Bool associated with bytes32 id key**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *bytes32* | _key | Pointer identifier for value in storage |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully called from another contract |

## *function* setBytes

TokenIOStorage.setBytes(_key, _value) `nonpayable` `2e28d084`

**Set value for Bytes associated with bytes32 id key**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *bytes32* | _key | Pointer identifier for value in storage |
| *bytes* | _value | The Bytes value to be set |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully called from another contract |

## *function* setInt

TokenIOStorage.setInt(_key, _value) `nonpayable` `3e49bed0`

**Set value for Int associated with bytes32 id key**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *bytes32* | _key | Pointer identifier for value in storage |
| *int256* | _value | The Int value to be set |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully called from another contract |

## *function* allowOwnership

TokenIOStorage.allowOwnership(allowedAddress) `nonpayable` `4bbc142c`

> Allows interface contracts to access contract methods (e.g. Storage contract)

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | allowedAddress | The address of new owner |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully allowed ownership |

## *function* deleteBytes

TokenIOStorage.deleteBytes(_key) `nonpayable` `616b59f6`

**Delete value for Bytes associated with bytes32 id key**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *bytes32* | _key | Pointer identifier for value in storage |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully called from another contract |

## *function* owner

TokenIOStorage.owner() `view` `666e1b39`


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* |  | undefined |


## *function* setString

TokenIOStorage.setString(_key, _value) `nonpayable` `6e899550`

**Set value for String associated with bytes32 id key**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *bytes32* | _key | Pointer identifier for value in storage |
| *string* | _value | The String value to be set |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully called from another contract |

## *function* getBool

TokenIOStorage.getBool(_key) `view` `7ae1cfca`

**Get value for Bool associated with bytes32 id key**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *bytes32* | _key | Pointer identifier for value in storage |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | _value | Returns the Bool value associated with the id key |

## *function* deleteInt

TokenIOStorage.deleteInt(_key) `nonpayable` `8c160095`

**Delete value for Int associated with bytes32 id key**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *bytes32* | _key | Pointer identifier for value in storage |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully called from another contract |

## *function* getString

TokenIOStorage.getString(_key) `view` `986e791a`

**Get value for String associated with bytes32 id key**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *bytes32* | _key | Pointer identifier for value in storage |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *string* | _value | Returns the String value associated with the id key |

## *function* setBool

TokenIOStorage.setBool(_key, _value) `nonpayable` `abfdcced`

**Set value for Bool associated with bytes32 id key**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *bytes32* | _key | Pointer identifier for value in storage |
| *bool* | _value | The Bool value to be set |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully called from another contract |

## *function* getUint

TokenIOStorage.getUint(_key) `view` `bd02d0f5`

**Get value for Uint associated with bytes32 id key**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *bytes32* | _key | Pointer identifier for value in storage |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | _value | Returns the Uint value associated with the id key |

## *function* getBytes

TokenIOStorage.getBytes(_key) `view` `c031a180`

**Get value for Bytes associated with bytes32 id key**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *bytes32* | _key | Pointer identifier for value in storage |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bytes* | _value | Returns the Bytes value associated with the id key |

## *function* setAddress

TokenIOStorage.setAddress(_key, _value) `nonpayable` `ca446dd9`

**Set value for Address associated with bytes32 id key**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *bytes32* | _key | Pointer identifier for value in storage |
| *address* | _value | The Address value to be set |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully called from another contract |

## *function* getInt

TokenIOStorage.getInt(_key) `view` `dc97d962`

**Get value for Int associated with bytes32 id key**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *bytes32* | _key | Pointer identifier for value in storage |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *int256* | _value | Returns the Int value associated with the id key |

## *function* setUint

TokenIOStorage.setUint(_key, _value) `nonpayable` `e2a4853a`

**Set value for Uint associated with bytes32 id key**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *bytes32* | _key | Pointer identifier for value in storage |
| *uint256* | _value | The Uint value to be set |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully called from another contract |

## *function* deleteUint

TokenIOStorage.deleteUint(_key) `nonpayable` `e2b202bf`

**Delete value for Uint associated with bytes32 id key**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *bytes32* | _key | Pointer identifier for value in storage |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully called from another contract |

## *function* transferOwnership

TokenIOStorage.transferOwnership(newOwner) `nonpayable` `f2fde38b`

> Allows the current owner to transfer control of the contract to a newOwner.

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | newOwner | The address to transfer ownership to. |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully transferred ownership |

## *function* deleteString

TokenIOStorage.deleteString(_key) `nonpayable` `f6bb3cc4`

**Delete value for String associated with bytes32 id key**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *bytes32* | _key | Pointer identifier for value in storage |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully called from another contract |

## *event* LogOwnershipTransferred

TokenIOStorage.LogOwnershipTransferred(previousOwner, newOwner) `db6d05f3`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *address* | previousOwner | indexed |
| *address* | newOwner | indexed |

## *event* LogAllowOwnership

TokenIOStorage.LogAllowOwnership(allowedAddress) `5c65eb6a`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *address* | allowedAddress | indexed |


---
