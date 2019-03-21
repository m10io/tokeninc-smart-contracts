pragma solidity 0.5.2;

import "./Ownable.sol";

interface TokenIOMerchantI {
  function setParams(address feeContract) external returns (bool success);

  function getFeeParams() external view returns (uint bps, uint min, uint max, uint flat, bytes memory feeMsg, address feeAccount);

  function calculateFees(uint amount) external view returns (uint fees);

  function pay(string calldata currency, address merchant, uint amount, bool merchantPaysFees, bytes calldata data, address sender) external returns (bool success);
}

contract TokenIOMerchantProxy is Ownable {

    address implementationInstance;

    constructor(address _tokenIOMerchantImpl) public {
      implementationInstance = _tokenIOMerchantImpl;
    }

    function upgradeTo(address _newImplementationInstance) onlyOwner external {
      require(_newImplementationInstance != address(0));
      implementationInstance = _newImplementationInstance;
    }

    function staticCall(bytes calldata payload) external view returns(bytes memory) {
      (bool res, bytes memory result) = implementationInstance.staticcall(payload);
      return result;
    }

    function call(bytes calldata payload) external {
      (bool res, bytes memory result) = implementationInstance.call(payload);
      require(res);
    }
  
    function setParams(address feeContract) public onlyOwner returns (bool success) {
      require(TokenIOMerchantI(implementationInstance).setParams(feeContract),
        "Unable to execute setParams");
      
      return true;
    }

    function getFeeParams() public view returns (uint bps, uint min, uint max, uint flat, bytes memory feeMsg, address feeAccount) {
      return TokenIOMerchantI(implementationInstance).getFeeParams();
    }

    function calculateFees(uint amount) public view returns (uint fees) {
      return TokenIOMerchantI(implementationInstance).calculateFees(amount);
    }

    function pay(string memory currency, address merchant, uint amount, bool merchantPaysFees, bytes memory data) public returns (bool success) {
      require(TokenIOMerchantI(implementationInstance).pay(currency, merchant, amount, merchantPaysFees, data, msg.sender),
        "Unable to execute pay");

      return true;
    }

}
