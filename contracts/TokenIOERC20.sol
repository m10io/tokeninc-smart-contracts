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


import "./Ownable.sol";
import "./TokenIOStorage.sol";
import "./TokenIOLib.sol";

contract TokenIOERC20 is Ownable {

    using TokenIOLib for TokenIOLib.Data;
    TokenIOLib.Data lib;


    constructor(address _storageContract) public {
        // Set the storage contract for the interface
        // This contract will be unable to use the storage constract until
        // contract address is authorized with the storage contract
        // Once authorized, Use the `init` method to set storage values;
        lib.Storage = TokenIOStorage(_storageContract);

        owner[msg.sender] = true;
    }

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
        require(lib.setTokenNameSpace(_symbol));

        return true;
    }

    function name() public view returns (string) {
        return lib.getTokenName(address(this));
    }

    function symbol() public view returns (string) {
        return lib.getTokenSymbol(address(this));
    }

    function tla() public view returns (string) {
        return lib.getTokenTLA(address(this));
    }

    function version() public view returns (string) {
        return lib.getTokenVersion(address(this));
    }

    function decimals() public view returns (uint) {
        return lib.getTokenDecimals(address(this));
    }

    function totalSupply() public view returns (uint) {
      return lib.getTokenSupply(lib.getTokenSymbol(address(this)));
    }

    function allowance(address account, address spender) public view returns (uint) {
      return lib.getTokenAllowance(lib.getTokenSymbol(address(this)), account, spender);
    }

    function balanceOf(address account) public view returns (uint) {
      return lib.getTokenBalance(lib.getTokenSymbol(address(this)), account);
    }

    function getFeeParams() public view returns (uint bps, uint min, uint max, uint flat, address feeAccount) {
        return (
            lib.getFeeBPS(lib.getFeeContract(address(this))),
            lib.getFeeMin(lib.getFeeContract(address(this))),
            lib.getFeeMax(lib.getFeeContract(address(this))),
            lib.getFeeFlat(lib.getFeeContract(address(this))),
            lib.getFeeContract(address(this))
        );
    }

    function calculateFees(uint amount) public view returns (uint) {
      return lib.calculateFees(lib.getFeeContract(address(this)), amount);
    }

    function transfer(address to, uint amount) public notDeprecated returns (bool) {
      require(lib.verifyAccounts(msg.sender, to));
      require(lib.transfer(to, amount, "0x0"));
      return true;
    }

    function transferFrom(address from, address to, uint amount) public notDeprecated returns (bool) {
        require(lib.verifyAccounts(from, to));
        require(lib.transferFrom(from, to, amount));
        return true;
    }

    function approve(address spender, uint amount) public notDeprecated returns (bool) {
        require(lib.verifyAccounts(msg.sender, spender));
        require(lib.approve(spender, amount));
        return true;
    }

    function deprecateInterface(bool isDeprecated) public onlyOwner returns (bool) {
      require(lib.setDeprecatedContract(address(this), isDeprecated));
      return true;
    }

    modifier notDeprecated() {
      require(!lib.isContractDeprecated(address(this)));
      _;
    }

}
