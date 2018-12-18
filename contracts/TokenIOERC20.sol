pragma solidity 0.4.24;

import "./Ownable.sol";
import "./TokenIOStorage.sol";
import "./TokenIOLib.sol";



/*
COPYRIGHT 2018 Token, Inc.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

@title ERC20 Compliant Smart Contract for Token, Inc.

@author Ryan Tate <ryan.tate@token.io>, Sean Pollock <sean.pollock@token.io>

@notice Contract uses generalized storage contract, `TokenIOStorage`, for
upgradeability of interface contract.

@dev In the event that the main contract becomes deprecated, the upgraded contract
will be set as the owner of this contract, and use this contract's storage to
maintain data consistency between contract.
*/



contract TokenIOERC20 is Ownable {
  //// @dev Set reference to TokenIOLib interface which proxies to TokenIOStorage
  using TokenIOLib for TokenIOLib.Data;
  TokenIOLib.Data lib;

  /**
  * @notice Constructor method for ERC20 contract
  * @param _storageContract     address of TokenIOStorage contract
  */
  constructor(address _storageContract) public {
    //// @dev Set the storage contract for the interface
    //// @dev This contract will be unable to use the storage constract until
    //// @dev contract address is authorized with the storage contract
    //// @dev Once authorized, Use the `setParams` method to set storage values
    lib.Storage = TokenIOStorage(_storageContract);

    //// @dev set owner to contract initiator
    owner[msg.sender] = true;
  }


  /**
  @notice Sets erc20 globals and fee paramters
  @param _name Full token name  'USD by token.io'
  @param _symbol Symbol name 'USDx'
  @param _tla Three letter abbreviation 'USD'
  @param _version Release version 'v0.0.1'
  @param _decimals Decimal precision
  @param _feeContract Address of fee contract
  @return { "success" : "Returns true if successfully called from another contract"}
  */
  function setParams(
    string _name,
    string _symbol,
    string _tla,
    string _version,
    uint _decimals,
    address _feeContract,
    uint _fxUSDBPSRate
    ) onlyOwner public returns (bool success) {
      require(lib.setTokenName(_name),
        "Error: Unable to set token name. Please check arguments.");
      require(lib.setTokenSymbol(_symbol),
        "Error: Unable to set token symbol. Please check arguments.");
      require(lib.setTokenTLA(_tla),
        "Error: Unable to set token TLA. Please check arguments.");
      require(lib.setTokenVersion(_version),
        "Error: Unable to set token version. Please check arguments.");
      require(lib.setTokenDecimals(_symbol, _decimals),
        "Error: Unable to set token decimals. Please check arguments.");
      require(lib.setFeeContract(_feeContract),
        "Error: Unable to set fee contract. Please check arguments.");
      require(lib.setFxUSDBPSRate(_symbol, _fxUSDBPSRate),
        "Error: Unable to set fx USD basis points rate. Please check arguments.");
      return true;
    }

    /**
    * @notice Gets name of token
    * @return {"_name" : "Returns name of token"}
    */
    function name() public view returns (string _name) {
      return lib.getTokenName(address(this));
    }

    /**
    * @notice Gets symbol of token
    * @return {"_symbol" : "Returns symbol of token"}
    */
    function symbol() public view returns (string _symbol) {
      return lib.getTokenSymbol(address(this));
    }

    /**
    * @notice Gets three-letter-abbreviation of token
    * @return {"_tla" : "Returns three-letter-abbreviation of token"}
    */
    function tla() public view returns (string _tla) {
      return lib.getTokenTLA(address(this));
    }

    /**
    * @notice Gets version of token
    * @return {"_version" : "Returns version of token"}
    */
    function version() public view returns (string _version) {
      return lib.getTokenVersion(address(this));
    }

    /**
    * @notice Gets decimals of token
    * @return {"_decimals" : "Returns number of decimals"}
    */
    function decimals() public view returns (uint _decimals) {
      return lib.getTokenDecimals(lib.getTokenSymbol(address(this)));
    }

    /**
    * @notice Gets total supply of token
    * @return {"supply" : "Returns current total supply of token"}
    */
    function totalSupply() public view returns (uint supply) {
      return lib.getTokenSupply(lib.getTokenSymbol(address(this)));
    }

    /**
    * @notice Gets allowance that spender has with approver
    * @param account Address of approver
    * @param spender Address of spender
    * @return {"amount" : "Returns allowance of given account and spender"}
    */
    function allowance(address account, address spender) public view returns (uint amount) {
      return lib.getTokenAllowance(lib.getTokenSymbol(address(this)), account, spender);
    }

    /**
    * @notice Gets balance of account
    * @param account Address for balance lookup
    * @return {"balance" : "Returns balance amount"}
    */
    function balanceOf(address account) public view returns (uint balance) {
      return lib.getTokenBalance(lib.getTokenSymbol(address(this)), account);
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
    function getFeeParams() public view returns (uint bps, uint min, uint max, uint flat, bytes feeMsg, address feeAccount) {
      address feeContract = lib.getFeeContract(address(this));
      (max, min, bps, flat) = lib.getFees(feeContract);
      feeMsg = lib.getFeeMsg(feeContract);
      feeAccount = feeContract;
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
    * @notice transfers 'amount' from msg.sender to a receiving account 'to'
    * @param to Receiving address
    * @param amount Transfer amount
    * @return {"success" : "Returns true if transfer succeeds"}
    */
    function transfer(address to, uint amount) public notDeprecated returns (bool success) {
      /// @notice send transfer through library
      /// @dev !!! mutates storage state
      require(
        lib.transfer(lib.getTokenSymbol(address(this)), to, amount, "0x0"),
        "Error: Unable to transfer funds. Please check your parameters."
      );
      return true;
    }

    /**
    * @notice spender transfers from approvers account to the reciving account
    * @param from Approver's address
    * @param to Receiving address
    * @param amount Transfer amount
    * @return {"success" : "Returns true if transferFrom succeeds"}
    */
    function transferFrom(address from, address to, uint amount) public notDeprecated returns (bool success) {
      /// @notice sends transferFrom through library
      /// @dev !!! mutates storage state
      require(
        lib.transferFrom(lib.getTokenSymbol(address(this)), from, to, amount, "0x0"),
        "Error: Unable to transfer funds. Please check your parameters and ensure the spender has the approved amount of funds to transfer."
      );
      return true;
    }

    /**
    * @notice approves spender a given amount
    * @param spender Spender's address
    * @param amount Allowance amount
    * @return {"success" : "Returns true if approve succeeds"}
    */
    function approve(address spender, uint amount) public notDeprecated returns (bool success) {
      /// @notice sends approve through library
      /// @dev !!! mtuates storage states
      require(
        lib.approveAllowance(spender, amount),
        "Error: Unable to approve allowance for spender. Please ensure spender is not null and does not have a frozen balance."
      );
      return true;
    }

    /**
    * @notice gets currency status of contract
    * @return {"deprecated" : "Returns true if deprecated, false otherwise"}
    */
    function deprecateInterface() public onlyOwner returns (bool deprecated) {
      require(lib.setDeprecatedContract(address(this)),
        "Error: Unable to deprecate contract!");
      return true;
    }

    modifier notDeprecated() {
      /// @notice throws if contract is deprecated
      require(!lib.isContractDeprecated(address(this)),
        "Error: Contract has been deprecated, cannot perform operation!");
      _;
    }

  }
