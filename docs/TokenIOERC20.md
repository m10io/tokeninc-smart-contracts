* [TokenIOERC20](#tokenioerc20)
  * [name](#function-name)
  * [approve](#function-approve)
  * [totalSupply](#function-totalsupply)
  * [transferFrom](#function-transferfrom)
  * [decimals](#function-decimals)
  * [allowOwnership](#function-allowownership)
  * [calculateFees](#function-calculatefees)
  * [version](#function-version)
  * [owner](#function-owner)
  * [tla](#function-tla)
  * [balanceOf](#function-balanceof)
  * [symbol](#function-symbol)
  * [transfer](#function-transfer)
  * [getFeeParams](#function-getfeeparams)
  * [allowance](#function-allowance)
  * [setParams](#function-setparams)
  * [deprecateInterface](#function-deprecateinterface)
  * [transferOwnership](#function-transferownership)
  * [LogOwnershipTransferred](#event-logownershiptransferred)
  * [LogAllowOwnership](#event-logallowownership)


---
# TokenIOERC20


## *function* name

TokenIOERC20.name() `view` `06fdde03`

**Gets name of token**




Outputs

| **type** | **name** | **description** |
|-|-|-|
| *string* | _name | Returns name of token |

## *function* approve

TokenIOERC20.approve(spender, amount) `nonpayable` `095ea7b3`

**approves spender a given amount**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | spender | Spender's address |
| *uint256* | amount | Allowance amount |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true if approve succeeds |

## *function* totalSupply

TokenIOERC20.totalSupply() `view` `18160ddd`

**Gets total supply of token**




Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | supply | Returns current total supply of token |

## *function* transferFrom

TokenIOERC20.transferFrom(from, to, amount) `nonpayable` `23b872dd`

**spender transfers from approvers account to the reciving account**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | from | Approver's address |
| *address* | to | Receiving address |
| *uint256* | amount | Transfer amount |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true if transferFrom succeeds |

## *function* decimals

TokenIOERC20.decimals() `view` `313ce567`

**Gets decimals of token**




Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | _decimals | Returns number of decimals |

## *function* allowOwnership

TokenIOERC20.allowOwnership(allowedAddress) `nonpayable` `4bbc142c`

> Allows interface contracts to access contract methods (e.g. Storage contract)

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | allowedAddress | The address of new owner |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully allowed ownership |

## *function* calculateFees

TokenIOERC20.calculateFees(amount) `view` `52238fdd`

**Calculates fee of a given transfer amount**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | amount | Amount to calculcate fee value |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | fees | Returns the calculated transaction fees based on the fee contract parameters |

## *function* version

TokenIOERC20.version() `view` `54fd4d50`

**Gets version of token**




Outputs

| **type** | **name** | **description** |
|-|-|-|
| *string* | _version | Returns version of token |

## *function* owner

TokenIOERC20.owner() `view` `666e1b39`


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* |  | undefined |


## *function* tla

TokenIOERC20.tla() `view` `6b0235a0`

**Gets three-letter-abbreviation of token**




Outputs

| **type** | **name** | **description** |
|-|-|-|
| *string* | _tla | Returns three-letter-abbreviation of token |

## *function* balanceOf

TokenIOERC20.balanceOf(account) `view` `70a08231`

**Gets balance of account**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | account | Address for balance lookup |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | balance | Returns balance amount |

## *function* symbol

TokenIOERC20.symbol() `view` `95d89b41`

**Gets symbol of token**




Outputs

| **type** | **name** | **description** |
|-|-|-|
| *string* | _symbol | Returns symbol of token |

## *function* transfer

TokenIOERC20.transfer(to, amount) `nonpayable` `a9059cbb`

**transfers 'amount' from msg.sender to a receiving account 'to'**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | to | Receiving address |
| *uint256* | amount | Transfer amount |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true if transfer succeeds |

## *function* getFeeParams

TokenIOERC20.getFeeParams() `view` `be6fc181`

**Gets fee parameters**




Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | bps | Fee amount as a mesuare of basis points |
| *uint256* | min | Minimum fee amount |
| *uint256* | max | Maximum fee amount |
| *uint256* | flat | Flat fee amount |
| *address* | feeAccount | undefined |

## *function* allowance

TokenIOERC20.allowance(account, spender) `view` `dd62ed3e`

**Gets allowance that spender has with approver**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | account | Address of approver |
| *address* | spender | Address of spender |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *uint256* | amount | Returns allowance of given account and spender |

## *function* setParams

TokenIOERC20.setParams(_name, _symbol, _tla, _version, _decimals, _feeContract, _fxUSDBPSRate) `nonpayable` `e052f0c8`

**Sets erc20 globals and fee paramters**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *string* | _name | Full token name  'USD by token.io' |
| *string* | _symbol | Symbol name 'USDx' |
| *string* | _tla | Three letter abbreviation 'USD' |
| *string* | _version | Release version 'v0.0.1' |
| *uint256* | _decimals | Decimal precision |
| *address* | _feeContract | Address of fee contract |
| *uint256* | _fxUSDBPSRate | undefined |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true if successfully called from another contract |

## *function* deprecateInterface

TokenIOERC20.deprecateInterface() `nonpayable` `ebe6ba07`

**gets currency status of contract**




Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | deprecated | Returns true if deprecated, false otherwise |

## *function* transferOwnership

TokenIOERC20.transferOwnership(newOwner) `nonpayable` `f2fde38b`

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

TokenIOERC20.LogOwnershipTransferred(previousOwner, newOwner) `db6d05f3`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *address* | previousOwner | indexed |
| *address* | newOwner | indexed |

## *event* LogAllowOwnership

TokenIOERC20.LogAllowOwnership(allowedAddress) `5c65eb6a`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *address* | allowedAddress | indexed |
