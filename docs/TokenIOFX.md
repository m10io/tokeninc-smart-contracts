* [TokenIOFX](#tokeniofx)
  * [allowOwnership](#function-allowownership)
  * [owner](#function-owner)
  * [swap](#function-swap)
  * [transferOwnership](#function-transferownership)
  * [LogOwnershipTransferred](#event-logownershiptransferred)
  * [LogAllowOwnership](#event-logallowownership)

---
# TokenIOFX

Ryan Tate <ryan.michael.tate@gmail.com>, Sean Pollock <seanpollock3344@gmail.com>

## *function* allowOwnership

TokenIOFX.allowOwnership(allowedAddress) `nonpayable` `4bbc142c`

> Allows interface contracts to access contract methods (e.g. Storage contract)

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | allowedAddress | The address of new owner |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully allowed ownership |

## *function* owner

TokenIOFX.owner() `view` `666e1b39`


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* |  | undefined |


## *function* swap

TokenIOFX.swap(requester, symbolA, symbolB, valueA, valueB, sigV, sigR, sigS, expiration) `nonpayable` `987c6b9d`

**Accepts a signed fx request to swap currency pairs at a given amount;**

> This method can be called directly between peers.

Inputs

| **type** | **name** | **description** |
|-|-|-|
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

## *function* transferOwnership

TokenIOFX.transferOwnership(newOwner) `nonpayable` `f2fde38b`

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

TokenIOFX.LogOwnershipTransferred(previousOwner, newOwner) `db6d05f3`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *address* | previousOwner | indexed |
| *address* | newOwner | indexed |

## *event* LogAllowOwnership

TokenIOFX.LogAllowOwnership(allowedAddress) `5c65eb6a`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *address* | allowedAddress | indexed |
