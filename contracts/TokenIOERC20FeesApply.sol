pragma solidity 0.4.24;

import "./Ownable.sol";
import "./TokenIOStorage.sol";
import "./TokenIOLib.sol";
import "./SafeMath.sol";


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



contract TokenIOERC20FeesApply is Ownable {

  using SafeMath for uint;

  //// @dev Set reference to TokenIOLib interface which proxies to TokenIOStorage
  using TokenIOLib for TokenIOLib.Data;
  TokenIOLib.Data lib;

  event Transfer(address indexed from, address indexed to, uint256 amount);

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
      require(lib.setTokenParams(_name, _symbol, _tla, _version, _decimals, _feeContract, _fxUSDBPSRate),
        "Error: Unable to set token params. Please check arguments.");
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
      feeAccount = lib.getFeeContract(address(this));
      (max, min, bps, flat) = lib.getFees(feeAccount);
      feeMsg = lib.getFeeMsg(feeAccount);
    }

    /**
    * @notice Calculates fee of a given transfer amount
    * @param amount Amount to calculcate fee value
    * @return {"fees": "Returns the calculated transaction fees based on the fee contract parameters"}
    */
    function calculateFees(uint amount) external view returns (uint fees) {
      return calculateFees(lib.getFeeContract(address(this)), amount);
    }

    function calculateFees(address feeContract, uint amount) internal view returns (uint fees) {
      return lib.calculateFees(feeContract, amount);
    }

    /**
    * @notice transfers 'amount' from msg.sender to a receiving account 'to'
    * @param to Receiving address
    * @param amount Transfer amount
    * @return {"success" : "Returns true if transfer succeeds"}
    */
    function transfer(address to, uint amount) public notDeprecated returns (bool success) {
        address feeContract = lib.getFeeContract(address(this));
        string memory currency = lib.getTokenSymbol(address(this));
        uint fees = calculateFees(feeContract, amount);

        address[3] memory addresses = [lib.getForwardedAccount(msg.sender), lib.getForwardedAccount(to), lib.getForwardedAccount(feeContract)];
        uint[3] memory balances = [lib.Storage.getBalance(addresses[0], currency), lib.Storage.getBalance(addresses[1], currency), lib.Storage.getBalance(addresses[2], currency)];

        require(
            lib.Storage.setBalance(addresses[0], currency, balances[0].sub(amount.add(fees))),
            "Error: Unable to set storage value. Please ensure contract has allowed permissions with storage contract."
        );

        require(
            lib.Storage.setBalance(addresses[1], currency, balances[1].add(amount)),
            "Error: Unable to set storage value. Please ensure contract has allowed permissions with storage contract."
        );

        require(
            lib.Storage.setBalance(addresses[2], currency, balances[2].add(fees)),
            "Error: Unable to set storage value. Please ensure contract has allowed permissions with storage contract."
        );
        
        emit Transfer(msg.sender, to, amount);
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
      address feeContract = lib.getFeeContract(address(this));
      string memory currency = lib.getTokenSymbol(address(this));
      uint fees = calculateFees(feeContract, amount);

      address[3] memory addresses = [lib.getForwardedAccount(from), lib.getForwardedAccount(to), lib.getForwardedAccount(feeContract)];
      uint[3] memory balances = [lib.Storage.getBalance(addresses[0], currency), lib.Storage.getBalance(addresses[1], currency), lib.Storage.getBalance(addresses[2], currency)];

      require(
        lib.Storage.setBalance(addresses[0], currency, balances[0].sub(amount.add(fees))),
        "Error: Unable to set storage value. Please ensure contract has allowed permissions with storage contract."
      );

      require(
        lib.Storage.setBalance(addresses[1], currency, balances[1].add(amount)),
        "Error: Unable to set storage value. Please ensure contract has allowed permissions with storage contract."
      );

      require(
        lib.Storage.setBalance(addresses[2], currency, balances[2].add(fees)),
        "Error: Unable to set storage value. Please ensure contract has allowed permissions with storage contract."
      );

      /// @notice This transaction will fail if the msg.sender does not have an approved allowance.
      require(
        lib.updateAllowance(lib.getTokenSymbol(address(this)), from, amount.add(fees)),
        "Error: Unable to update allowance for spender."
      );

      emit Transfer(from, to, amount);
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
