* [TokenIOCurrencyAuthority](#tokeniocurrencyauthority)
  * [approveKYCAndDeposit](#function-approvekycanddeposit)
  * [getAccountSpendingRemaining](#function-getaccountspendingremaining)
  * [getTokenBalance](#function-gettokenbalance)
  * [setFxBpsRate](#function-setfxbpsrate)
  * [approveKYC](#function-approvekyc)
  * [allowOwnership](#function-allowownership)
  * [deposit](#function-deposit)
  * [getAccountSpendingLimit](#function-getaccountspendinglimit)
  * [owner](#function-owner)
  * [withdraw](#function-withdraw)
  * [setAccountSpendingLimit](#function-setaccountspendinglimit)
  * [getTokenSupply](#function-gettokensupply)
  * [freezeAccount](#function-freezeaccount)
  * [approveForwardedAccount](#function-approveforwardedaccount)
  * [getFxUSDAmount](#function-getfxusdamount)
  * [transferOwnership](#function-transferownership)
  * [LogOwnershipTransferred](#event-logownershiptransferred)
  * [LogAllowOwnership](#event-logallowownership)


---
# TokenIOCurrencyAuthority


## *function* approveKYCAndDeposit

TokenIOCurrencyAuthority.approveKYCAndDeposit(currency, account, amount, limit, issuerFirm) `nonpayable` `28e53bb2`

**Approves account and deposits specified amount of given currency**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *string* | currency | Currency symbol of amount to be deposited; |
| *address* | account | Ethereum address of account holder; |
| *uint256* | amount | Deposit amount for account holder; |
| *uint256* | limit | undefined |
| *string* | issuerFirm | Name of the issuer firm with authority on account holder; |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true if successfully called from another contract |

## *function* getAccountSpendingRemaining

TokenIOCurrencyAuthority.getAccountSpendingRemaining(account) `view` `29db8ec4`

**Returns the periodic remaining spending amount for an account**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | account | Ethereum address of account holder; |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | spendingRemaining | Returns the remaining spending amount for the account |

## *function* getTokenBalance

TokenIOCurrencyAuthority.getTokenBalance(currency, account) `view` `3cdb9762`

**Gets balance of sepcified account for a given currency**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *string* | currency | Currency symbol 'USDx' |
| *address* | account | Sepcified account address |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | balance | Returns account balance |

## *function* setFxBpsRate

TokenIOCurrencyAuthority.setFxBpsRate(currency, bpsRate, issuerFirm) `nonpayable` `44890014`

**Set the foreign currency exchange rate to USD in basis points**

> NOTE: This value should always be relative to USD pair; e.g. JPY/USD, GBP/USD, etc.

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *string* | currency | The TokenIO currency symbol (e.g. USDx, JPYx, GBPx) |
| *uint256* | bpsRate | Basis point rate of foreign currency exchange rate to USD |
| *string* | issuerFirm | Firm setting the foreign currency exchange |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true if successfully called from another contract |

## *function* approveKYC

TokenIOCurrencyAuthority.approveKYC(account, isApproved, limit, issuerFirm) `nonpayable` `46e06634`

**Sets approval status of specified account**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | account | Sepcified account address |
| *bool* | isApproved | Frozen status |
| *uint256* | limit | undefined |
| *string* | issuerFirm | Name of the issuer firm with authority on account holder; |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true if successfully called from another contract |

## *function* allowOwnership

TokenIOCurrencyAuthority.allowOwnership(allowedAddress) `nonpayable` `4bbc142c`

> Allows interface contracts to access contract methods (e.g. Storage contract)

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | allowedAddress | The address of new owner |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully allowed ownership |

## *function* deposit

TokenIOCurrencyAuthority.deposit(currency, account, amount, issuerFirm) `nonpayable` `5d586bfd`

**Issues a specified account to recipient account of a given currency**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *string* | currency | [string] currency symbol |
| *address* | account | undefined |
| *uint256* | amount | [uint] issuance amount |
| *string* | issuerFirm | Name of the issuer firm with authority on account holder; |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true if successfully called from another contract |

## *function* getAccountSpendingLimit

TokenIOCurrencyAuthority.getAccountSpendingLimit(account) `view` `61e7662b`

**Return the spending limit for an account**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | account | Ethereum address of account holder |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | spendingLimit | Returns the remaining daily spending limit of the account |

## *function* owner

TokenIOCurrencyAuthority.owner() `view` `666e1b39`


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* |  | undefined |


## *function* withdraw

TokenIOCurrencyAuthority.withdraw(currency, account, amount, issuerFirm) `nonpayable` `79662bd5`

**Withdraws a specified amount of tokens of a given currency**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *string* | currency | Currency symbol |
| *address* | account | Ethereum address of account holder |
| *uint256* | amount | Issuance amount |
| *string* | issuerFirm | Name of the issuer firm with authority on account holder |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true if successfully called from another contract |

## *function* setAccountSpendingLimit

TokenIOCurrencyAuthority.setAccountSpendingLimit(account, limit, issuerFirm) `nonpayable` `8a8f1f25`

**Sets the spending limit for a given account**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | account | Ethereum address of account holder; |
| *uint256* | limit | Spending limit amount for account; |
| *string* | issuerFirm | Name of the issuer firm with authority on account holder; |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true if successfully called from another contract |

## *function* getTokenSupply

TokenIOCurrencyAuthority.getTokenSupply(currency) `view` `a0776a59`

**Gets total supply of specified currency**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *string* | currency | Currency symbol 'USDx' |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | supply | Returns total supply of currency |

## *function* freezeAccount

TokenIOCurrencyAuthority.freezeAccount(account, isAllowed, issuerFirm) `nonpayable` `e354a3f2`

**Updates account status. false: frozen, true: un-frozen**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | account | Sepcified account address |
| *bool* | isAllowed | Frozen status |
| *string* | issuerFirm | Name of the issuer firm with authority on account holder; |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true if successfully called from another contract |

## *function* approveForwardedAccount

TokenIOCurrencyAuthority.approveForwardedAccount(originalAccount, updatedAccount, issuerFirm) `nonpayable` `e6562fe1`

**Updates to new forwarded account**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | originalAccount | [address] |
| *address* | updatedAccount | [address] |
| *string* | issuerFirm | Name of the issuer firm with authority on account holder; |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true if successfully called from another contract |

## *function* getFxUSDAmount

TokenIOCurrencyAuthority.getFxUSDAmount(currency, fxAmount) `view` `f2de12fc`

**Return the foreign currency USD exchanged amount**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *string* | currency | The TokenIO currency symbol (e.g. USDx, JPYx, GBPx) |
| *uint256* | fxAmount | Amount of foreign currency to exchange into USD |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | usdAmount | Returns the foreign currency amount in USD |

## *function* transferOwnership

TokenIOCurrencyAuthority.transferOwnership(newOwner) `nonpayable` `f2fde38b`

> Allows the current owner to transfer control of the contract to a newOwner.

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | newOwner | The address to transfer ownership to. |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully transferred ownership |

## *event* LogOwnershipTransferred

TokenIOCurrencyAuthority.LogOwnershipTransferred(previousOwner, newOwner) `db6d05f3`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *address* | previousOwner | indexed |
| *address* | newOwner | indexed |

## *event* LogAllowOwnership

TokenIOCurrencyAuthority.LogAllowOwnership(allowedAddress) `5c65eb6a`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *address* | allowedAddress | indexed |
