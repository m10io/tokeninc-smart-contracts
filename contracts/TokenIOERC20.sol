pragma solidity ^0.4.24;

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

    @author Ryan Tate <ryan.michael.tate@gmail.com>, Sean Pollock <seanpollock3344@gmail.com>

    @notice Contract uses generalized storage contract, `TokenIOStorage`, for
    upgradeability of interface contract.

    @dev In the event that the main contract becomes deprecated, the upgraded contract
    will be set as the owner of this contract, and use this contract's storage to
    maintain data consistency between contract.
*/



contract TokenIOERC20 is Ownable {
    /// @dev Set reference to TokenIOLib interface which proxies to TokenIOStorage
    using TokenIOLib for TokenIOLib.Data;
    TokenIOLib.Data lib;

    /**
    * @notice Constructor method for ERC20 contract
    * @param _storageContract     address of TokenIOStorage contract
    */
    constructor(address _storageContract) public {
        /// @dev Set the storage contract for the interface
        /// @dev This contract will be unable to use the storage constract until
        /// @dev contract address is authorized with the storage contract
        /// @dev Once authorized, Use the `setParams` method to set storage values
        lib.Storage = TokenIOStorage(_storageContract);

        /// @dev set owner to contract initiator
        owner[msg.sender] = true;
    }


    /*
     * @notice Sets erc20 globals and fee paramters
     * @param _name [string] full token name  'USD by token.io'
     * @param _symbol [string] symbol name 'USDx'
     * @param _tla [string] three letter abbreviation 'USD'
     * @param _version [string] release version 'v0.0.1'
     * @param _decimals [uint] how many supply uints equal 1 token '2'
     * @param _feeContract [address] address of fee interface '0x0...'
     * @return [bool] true if setters pass
     */
     // Ex: "USDx by token.io", "USDx", "USD", "0.1.2", 2, 2, 0, 100, 2, "0xca35b7d915458ef540ade6068dfe2f44e8fa733c"
    function setParams(
        string _name,
        string _symbol,
        string _tla,
        string _version,
        uint _decimals,
        address _feeContract
    ) onlyOwner public returns (bool) {
        require(lib.setTokenName(_name));
        require(lib.setTokenSymbol(_symbol));
        require(lib.setTokenTLA(_tla));
        require(lib.setTokenVersion(_version));
        require(lib.setTokenDecimals(_decimals));
        require(lib.setFeeContract(_feeContract));

        return true;
    }

    /* @notice Gets name of token
     * @return [string]
     */
    function name() public view returns (string) {
        return lib.getTokenName(address(this));
    }

    /* @notice Gets symbol of token
     * @return [string]
     */
    function symbol() public view returns (string) {
        return lib.getTokenSymbol(address(this));
    }

    /* @notice Gets three-letter-abbreviation of token
     * @return [string]
     */
    function tla() public view returns (string) {
        return lib.getTokenTLA(address(this));
    }

    /* @notice Gets version of token
     * @return [string]
     */
    function version() public view returns (string) {
        return lib.getTokenVersion(address(this));
    }

    /* @notice Gets decimals of token
     * @return [uint]
     */
    function decimals() public view returns (uint) {
        return lib.getTokenDecimals(address(this));
    }

    /* @notice Gets total supply of token
     * @return [uint]
     */
    function totalSupply() public view returns (uint) {
      return lib.getTokenSupply(lib.getTokenSymbol(address(this)));
    }

    /* @notice Gets allowance that spender has with approver
     * @param account [address] address of approver
     * @param spender [address] address of spender
     * @return [uint] allowance amount
     */
    function allowance(address account, address spender) public view returns (uint) {
      return lib.getTokenAllowance(lib.getTokenSymbol(address(this)), account, spender);
    }

    /* @notice Gets balance of account
     * @param account [address] account address for balance lookup
     * @return [uint] balance amount
     */
    function balanceOf(address account) public view returns (uint) {
      return lib.getTokenBalance(lib.getTokenSymbol(address(this)), account);
    }

     /* @notice Gets fee parameters
     * @return [tuple] (uint, uint, uint, uint, address)
     *    bps [uint] fee amount as a mesuare of basis points
     *    min [uint] minimum fee amount
     *    max [uint] maximum fee amount
     *    flat [uint] flat fee amount
     *    contract [address] fee contract address
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

    /* @notice Calculates fee of a given transfer amount
     * @param amount [uint] transfer amount
     * @return [uint] fee amount
     */
    function calculateFees(uint amount) public view returns (uint) {
      return lib.calculateFees(lib.getFeeContract(address(this)), amount);
    }

    /* @notice transfers 'amount' from msg.sender to a receiving account 'to'
     * @param to [address] receiving address
     * @param amount [uint] transfer amount
     * @return [bool] true if transfer succeeds
     */
    function transfer(address to, uint amount) public notDeprecated returns (bool) {
      // @notice check that receiving account is verified
      require(lib.verifyAccounts(msg.sender, to));
      // @notice send transfer through library
      // @dev !!! mutates storage state
      require(lib.transfer(to, amount, "0x0"));
      return true;
    }

    /* @notice spender transfers from approvers account to the reciving account
     * @param from [address] approver's address
     * @param to [address] receiving address
     * @param amount [uint] transfer amount
     * @return [bool] true if transfer succeeds
     */
    function transferFrom(address from, address to, uint amount) public notDeprecated returns (bool) {
        // @ notice checks from and to accounts are verified
        require(lib.verifyAccounts(from, to));
        // @notice sends transferFrom through library
        // @dev !!! mutates storage state
        require(lib.transferFrom(from, to, amount));
        return true;
    }

    /* @notice approves spender a given amount
     * @param spender [address] spender's address
     * @param amount [uint] allowance amount
     * @return [bool] true if approval succeeds
     */
    function approve(address spender, uint amount) public notDeprecated returns (bool) {
        // @notice checks approver and spenders accounts are verified
        require(lib.verifyAccounts(msg.sender, spender));
        // @notice sends approve through library
        // @dev !!! mtuates storage states
        require(lib.approve(spender, amount));
        return true;
    }

    /* @notice gets currency status of contract
     * @return [bool] isDeprececated statement true/false
     */
    function deprecateInterface() public onlyOwner returns (bool) {
      require(lib.setDeprecatedContract(address(this)));
      return true;
    }

    modifier notDeprecated() {
      // @notice throws if contract is deprecated
      require(!lib.isContractDeprecated(address(this)));
      _;
    }

}
