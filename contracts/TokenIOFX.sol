pragma solidity 0.4.24;
pragma experimental ABIEncoderV2;

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
import "./TokenIOLib.sol";
import "./TokenIOStorage.sol";

contract TokenIOFX is Ownable {

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

  function swap(
    address requester,
    string symbolA,
    string symbolB,
    uint valueA,
    uint valueB,
    uint8 sigV,
    bytes32 sigR,
    bytes32 sigS,
    uint expiration
  ) public returns (bool) {

    require(lib.execSwap(requester, symbolA, symbolB, valueA, valueB, sigV, sigR, sigS, expiration));

    return true;
  }

}
