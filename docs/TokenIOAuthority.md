* [TokenIOAuthority](#tokenioauthority)
  * [isRegisteredAuthority](#function-isregisteredauthority)
  * [isRegisteredToFirm](#function-isregisteredtofirm)
  * [setRegisteredFirm](#function-setregisteredfirm)
  * [allowOwnership](#function-allowownership)
  * [owner](#function-owner)
  * [getFirmFromAuthority](#function-getfirmfromauthority)
  * [isRegisteredFirm](#function-isregisteredfirm)
  * [setMasterFeeContract](#function-setmasterfeecontract)
  * [transferOwnership](#function-transferownership)
  * [setRegisteredAuthority](#function-setregisteredauthority)
  * [LogOwnershipTransferred](#event-logownershiptransferred)
  * [LogAllowOwnership](#event-logallowownership)


---
# TokenIOAuthority


## *function* isRegisteredAuthority

TokenIOAuthority.isRegisteredAuthority(authority) `view` `339282b7`

**Gets status of authority registration**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | authority | Address of authority account |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | registered | Returns true if account is a registered authority |

## *function* isRegisteredToFirm

TokenIOAuthority.isRegisteredToFirm(firmName, authority) `view` `339e2c45`

**Checks if an authority account is registered to a given firm**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *string* | firmName | Name of firm |
| *address* | authority | Address of authority account |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | registered | Returns status of account registration to firm |

## *function* setRegisteredFirm

TokenIOAuthority.setRegisteredFirm(firmName, _authorized) `nonpayable` `41ade6b7`

**Registers a firm as authorized true/false**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *string* | firmName | Name of firm |
| *bool* | _authorized | Authorization status |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true if lib.setRegisteredFirm succeeds |

## *function* allowOwnership

TokenIOAuthority.allowOwnership(allowedAddress) `nonpayable` `4bbc142c`

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

TokenIOAuthority.owner() `view` `666e1b39`


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* |  | undefined |


## *function* getFirmFromAuthority

TokenIOAuthority.getFirmFromAuthority(authority) `view` `acca2c24`

**Gets firm asoociated with an authority address**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | authority | Address of authority account |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *string* | firm | name of firm |

## *function* isRegisteredFirm

TokenIOAuthority.isRegisteredFirm(firmName) `view` `ee5493b6`

**Gets status of firm registration**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *string* | firmName | Name of firm |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | status | Returns status of firm registration |

## *function* setMasterFeeContract

TokenIOAuthority.setMasterFeeContract(feeContract) `nonpayable` `f03529c3`

**Sets contract which specifies fee parameters**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | feeContract | Address of the fee contract |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true if lib.setMasterFeeContract succeeds |

## *function* transferOwnership

TokenIOAuthority.transferOwnership(newOwner) `nonpayable` `f2fde38b`

> Allows the current owner to transfer control of the contract to a newOwner.

Inputs

| **type** | **name** | **description** |
|-|-|-|
| *address* | newOwner | The address to transfer ownership to. |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true when successfully transferred ownership |

## *function* setRegisteredAuthority

TokenIOAuthority.setRegisteredAuthority(firmName, authority, _authorized) `nonpayable` `f3f969a0`

**Registers an authority asoociated with the given firm as true/false**


Inputs

| **type** | **name** | **description** |
|-|-|-|
| *string* | firmName | Name of firm |
| *address* | authority | Address of authority account |
| *bool* | _authorized | Authorization status |

Outputs

| **type** | **name** | **description** |
|-|-|-|
| *bool* | success | Returns true if lib.setRegisteredAuthority succeeds |

## *event* LogOwnershipTransferred

TokenIOAuthority.LogOwnershipTransferred(previousOwner, newOwner) `db6d05f3`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *address* | previousOwner | indexed |
| *address* | newOwner | indexed |

## *event* LogAllowOwnership

TokenIOAuthority.LogAllowOwnership(allowedAddress) `5c65eb6a`

Arguments

| **type** | **name** | **description** |
|-|-|-|
| *address* | allowedAddress | indexed |
