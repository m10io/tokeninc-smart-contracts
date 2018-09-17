* [TokenIOStorage](#tokeniostorage)
  * [deleteAddress](#function-deleteaddress)
  * [getAddress](#function-getaddress)
  * [deleteBool](#function-deletebool)
  * [setBytes](#function-setbytes)
  * [setInt](#function-setint)
  * [allowOwnership](#function-allowownership)
  * [deleteBytes](#function-deletebytes)
  * [owner](#function-owner)
  * [setString](#function-setstring)
  * [getBool](#function-getbool)
  * [deleteInt](#function-deleteint)
  * [getString](#function-getstring)
  * [setBool](#function-setbool)
  * [getUint](#function-getuint)
  * [getBytes](#function-getbytes)
  * [setAddress](#function-setaddress)
  * [getInt](#function-getint)
  * [setUint](#function-setuint)
  * [deleteUint](#function-deleteuint)
  * [transferOwnership](#function-transferownership)
  * [deleteString](#function-deletestring)
  * [LogOwnershipTransferred](#event-logownershiptransferred)
  * [LogAllowOwnership](#event-logallowownership)


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
