pragma solidity 0.4.23;


import "./SafeMath.sol";
import "./Ownable.sol";


contract Chargeable is Ownable {
    using SafeMath for uint;

    uint public maxFee = 20;
    uint public basisPointsRate = 125;
    bool public feeRequired = true;

    function setFeeParameters(
        uint _basisPointsRate,
        uint _maxFee,
        bool _feeRequired
    ) public onlyOwner returns (bool) {
        basisPointsRate = _basisPointsRate;
        maxFee = _maxFee;
        feeRequired = _feeRequired;
        return true;
    }

    function calculateFee(uint _amount) public returns (uint) {
        if (!feeRequired) {
            return 0;
        } else {
            uint fee = (_amount.mul(basisPointsRate)).div(10000);
            if (fee >= maxFee) {
                return maxFee;
            } else {
                return fee;
            }
        }
    }
}
