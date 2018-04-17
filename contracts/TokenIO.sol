pragma solidity 0.4.21;

import "./StorageInterface.sol";
import "./SafeMath.sol";


contract TokenIO {

    using SafeMath for uint;
    using SafeMath for uint[];

    StorageInterface public _storage;
    string _name;
    string _symbol;
    string _currencyTLA;

    event Transfer(address indexed owner, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    function TokenIO(StorageInterface storageContract) public {
        _storage = StorageInterface(storageContract);
        // Set Global Variables
        _name = "USD by token.io";
        _symbol = "USD+";
        _currencyTLA = "USD";
    }

    /** ERC20 Methods **/
    function totalSupply() public view returns (uint256) {
        return _storage.getUint(keccak256("token.supply"));
    }

    function decimals() public view returns (uint256) {
        return _storage.getUint(keccak256("token.decimals"));
    }

    function name() public view returns (string) {
        return _name;
    }

    function symbol() public view returns (string) {
        return _symbol;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _storage.getUint(keccak256("token.balance", owner));
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _storage.getUint(keccak256("token.allowance", owner, spender));
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        require(_storage.setUint(
            keccak256("token.balance", msg.sender),
            _storage.getUint(keccak256("token.balance", msg.sender)).sub(amount)
        ));
        require(_storage.setUint(
            keccak256("token.balance", to),
            _storage.getUint(keccak256("token.balance", to)).add(amount)
        ));
        Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address owner, address to, uint256 amount) public returns (bool) {
        require(_storage.setUint(
            keccak256("token.allowance", owner, msg.sender),
            _storage.getUint(keccak256("token.allowance", owner, msg.sender)).sub(amount)
        ));
        require(_storage.setUint(
            keccak256("token.balance", owner),
            _storage.getUint(keccak256("token.balance", owner)).sub(amount)
        ));
        require(_storage.setUint(
            keccak256("token.balance", to),
            _storage.getUint(keccak256("token.balance", to)).add(amount)
        ));
        Transfer(owner, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        /* Check if allowance is already set to zero before setting a new allowance */
        Approval(msg.sender, spender, amount);
        return _storage.setUint(keccak256("token.allowance", msg.sender, spender), amount);
    }



}
