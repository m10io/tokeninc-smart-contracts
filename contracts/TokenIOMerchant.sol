pragma solidity ^0.4.24;

/*
COPYRIGHT 2018 Token, Inc.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


/**
@title TokenIOMerchant - Merchant Interface Smart Contract for Token, Inc.

@author Ryan Tate <ryan.tate@token.io>, Sean Pollock <sean.pollock@token.io>

@notice Contract uses generalized storage contract, `TokenIOStorage`, for
upgradeability of interface contract.
*/

import "./Ownable.sol";
import "./TokenIOStorage.sol";
import "./TokenIOLib.sol";

contract TokenIOMerchant is Ownable {

    /// @dev Set reference to TokenIOLib interface which proxies to TokenIOStorage
    using TokenIOLib for TokenIOLib.Data;
    TokenIOLib.Data lib;

    /**
     * @notice Constructor method for Authority contract
     * @param _storageContract Ethereum Address of TokenIOStorage contract
     */
    constructor(address _storageContract) public {
        /*
         * @notice Set the storage contract for the interface
         * @dev This contract will be unable to use the storage constract until
         * @dev contract address is authorized with the storage contract
         * @dev Once authorized, you can setRegisteredFirm and setRegisteredAuthority
        */
        lib.Storage = TokenIOStorage(_storageContract);

        /// @dev set owner to contract initiator
        owner[msg.sender] = true;
    }

    /**
    @notice Sets Merchant globals and fee paramters
    @param feeContract Address of fee contract
    @return { "success" : "Returns true if successfully called from another contract"}
    */
    function setParams(
      address feeContract
    ) onlyOwner public returns (bool success) {
      require(lib.setFeeContract(feeContract));
      return true;
    }

    /**
    * @notice Gets fee parameters
    * @return {
    "bps":"Fee amount as a mesuare of basis points",
    "min":"Minimum fee amount",
    "max":"Maximum fee amount",
    "flat":"Flat fee amount",
    "contract":"Address of fee contract"
    }
    */
    function getFeeParams() public view returns (uint bps, uint min, uint max, uint flat, address feeAccount) {
      return (
        lib.getFeeBPS(lib.getFeeContract(address(this))),
        lib.getFeeMin(lib.getFeeContract(address(this))),
        lib.getFeeMax(lib.getFeeContract(address(this))),
        lib.getFeeFlat(lib.getFeeContract(address(this))),
        lib.getFeeContract(address(this))
      );
    }

    /**
    * @notice Calculates fee of a given transfer amount
    * @param amount Amount to calculcate fee value
    * @return {"fees": "Returns the calculated transaction fees based on the fee contract parameters"}
    */
    function calculateFees(uint amount) public view returns (uint fees) {
      return lib.calculateFees(lib.getFeeContract(address(this)), amount);
    }

    /**
     * @notice Pay method for merchant interface
     * @param  currency Currency symbol of the token (e.g. USDx, JYPx, GBPx)
     * @param  merchant Ethereum address of merchant
     * @param  amount Amount of currency to send to merchant
     * @param  merchantPaysFees Provide option for merchant to pay the transaction fees
     * @param  data Optional data to be included when paying the merchant (e.g. item receipt)
     * @return { "success" : "Returns true if successfully called from another contract"}
     */
    function pay(string currency, address merchant, uint amount, bool merchantPaysFees, bytes data) public returns (bool success) {
      uint fees = calculateFees(amount);

      /// @dev note the spending amount limit is gross of fees
      require(lib.setAccountSpendingAmount(msg.sender, lib.getFxUSDAmount(currency, amount)));
      require(lib.forceTransfer(currency, msg.sender, merchant, amount, data));

      address feeContract = lib.getFeeContract(address(this));
      /// @dev If merchantPaysFees == true, the merchant will pay the fees to the fee contract;
      /// @dev "0x547846656573" == "TxFees"
      if (merchantPaysFees) {
        require(lib.forceTransfer(currency, merchant, feeContract, fees, "0x547846656573"));
      } else {
        require(lib.forceTransfer(currency, msg.sender, feeContract, fees, "0x547846656573"));
      }

      return true;
    }

}
