pragma solidity 0.5.2;

import "./Ownable.sol";

interface TokenIOAuthorityI {
  function setRegisteredFirm(string calldata firmName, bool _authorized, address sender) external returns (bool success);

  function setRegisteredAuthority(string calldata firmName, address authority, bool _authorized, address sender) external returns (bool success);

  function getFirmFromAuthority(address authority) external view returns (string memory firm);

  function isRegisteredFirm(string calldata firmName) external view returns (bool status);

  function isRegisteredToFirm(string calldata firmName, address authority) external view returns (bool registered);

  function isRegisteredAuthority(address authority) external view returns (bool registered);

  function setMasterFeeContract(address feeContract) external returns (bool success);
}

contract TokenIOAuthorityProxy is Ownable {

    address implementationInstance;

    constructor(address _tokenIOAuthorityImpl) public {
      implementationInstance = _tokenIOAuthorityImpl;
    }

    function upgradeTo(address _newTokenIOAuthorityImpl) onlyOwner external {
      require(_newTokenIOAuthorityImpl != address(0));
      implementationInstance = _newTokenIOAuthorityImpl;
    }

    function staticCall(bytes calldata payload) external view returns(bytes memory) {
      (bool res, bytes memory result) = implementationInstance.staticcall(payload);
      return result;
    }

    function call(bytes calldata payload) external {
      (bool res, bytes memory result) = implementationInstance.call(payload);
      require(res);
    }
  
    function setRegisteredFirm(string memory firmName, bool _authorized) public returns (bool success) {
        require(
          TokenIOAuthorityI(implementationInstance).setRegisteredFirm(firmName, _authorized, msg.sender),
          "Unable to execute setRegisteredFirm"
        );
        return true;
    }

    function setRegisteredAuthority(string memory firmName, address authority, bool _authorized) public returns (bool success) {
        require(
          TokenIOAuthorityI(implementationInstance).setRegisteredAuthority(firmName, authority, _authorized, msg.sender),
          "Unable to execute setRegisteredFirm"
        );
        return true;
    }

    function getFirmFromAuthority(address authority) public view returns (string memory firm) {
        return TokenIOAuthorityI(implementationInstance).getFirmFromAuthority(authority);
    }

    function isRegisteredFirm(string memory firmName) public view returns (bool status) {
        return TokenIOAuthorityI(implementationInstance).isRegisteredFirm(firmName);
    }

    function isRegisteredToFirm(string memory firmName, address authority) public view returns (bool registered) {
        return TokenIOAuthorityI(implementationInstance).isRegisteredToFirm(firmName, authority);
    }

    function isRegisteredAuthority(address authority) public view returns (bool registered) {
        return TokenIOAuthorityI(implementationInstance).isRegisteredAuthority(authority);
    }

    function setMasterFeeContract(address feeContract) public onlyOwner returns (bool success) {
        require(
          TokenIOAuthorityI(implementationInstance).setMasterFeeContract(feeContract),
          "Unable to execute setMasterFeeContract"
        );
        return true;
    }

}
