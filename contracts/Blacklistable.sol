pragma solidity 0.4.23;


import "./SafeMath.sol";
import "./Ownable.sol";


contract Blacklistable is Ownable {

    mapping(address => bool) public isBlacklisted;

    event Blacklist(address indexed account, bool blocked);

    function blacklistAccount(address account, bool status) public onlyOwner returns (bool) {
        isBlacklisted[account] = status;
        emit Blacklist(account, status);
        return true;
    }
}
