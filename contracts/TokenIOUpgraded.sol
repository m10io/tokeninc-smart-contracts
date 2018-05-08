pragma solidity 0.4.23;


import "./TokenIO.sol";
import "./SafeMath.sol";


contract TokenIOUpgraded {

    /* using SafeMath for uint;

    TokenIO public defaultToken;

    event Transfer(address indexed from, address indexed to, uint amount);

    constructor(address _defaultToken) public {
        defaultToken = TokenIO(_defaultToken);
    }


    function transfer(address to, uint amount) public returns (bool) {
        // Handle logic locally;
        // Ensure value is not being transferred to a null account;
        require(address(to) != 0x0);

        // Calculate Fees based on amount
        uint fees = defaultToken.calculateFees(amount);

        // Update the Sender's Balance in the storage contract
        // Transaction will fail if user balance < amount + fees
        require(defaultToken.setUint(keccak256('balance', msg.sender),
        defaultToken.getUint(keccak256('balance', msg.sender)).sub(amount.add(fees))));

        // Update the Receiver's Balance in the storage contract
        require(defaultToken.setUint(keccak256('balance', to),
        defaultToken.getUint(keccak256('balance', to)).add(amount)));

        // Send fees to feeAccount
        address feeAccount = defaultToken.getAddress(keccak256('feeAccount'));
        require(defaultToken.setUint(keccak256('balance', feeAccount),
        defaultToken.getUint(keccak256('balance', feeAccount)).add(fees)));

        emit Transfer(msg.sender, to, amount);

        return true;

    } */

}
