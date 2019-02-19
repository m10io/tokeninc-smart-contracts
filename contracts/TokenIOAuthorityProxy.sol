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

    TokenIOAuthorityI tokenIOAuthorityImpl;

    constructor(address _tokenIOAuthorityImpl) public {
      tokenIOAuthorityImpl = TokenIOAuthorityI(_tokenIOAuthorityImpl);
    }

    function upgradeTokenImplamintation(address _newTokenIOAuthorityImpl) onlyOwner external {
      require(_newTokenIOAuthorityImpl != address(0));
      tokenIOAuthorityImpl = TokenIOAuthorityI(_newTokenIOAuthorityImpl);
    }
  
    function setRegisteredFirm(string memory firmName, bool _authorized) public returns (bool success) {
        require(
          tokenIOAuthorityImpl.setRegisteredFirm(firmName, _authorized, msg.sender),
          "Unable to execute setRegisteredFirm"
        );
        return true;
    }

    function setRegisteredAuthority(string memory firmName, address authority, bool _authorized) public returns (bool success) {
        require(
          tokenIOAuthorityImpl.setRegisteredAuthority(firmName, authority, _authorized, msg.sender),
          "Unable to execute setRegisteredFirm"
        );
        return true;
    }

    function getFirmFromAuthority(address authority) public view returns (string memory firm) {
        return tokenIOAuthorityImpl.getFirmFromAuthority(authority);
    }

    function isRegisteredFirm(string memory firmName) public view returns (bool status) {
        return tokenIOAuthorityImpl.isRegisteredFirm(firmName);
    }

    function isRegisteredToFirm(string memory firmName, address authority) public view returns (bool registered) {
        return tokenIOAuthorityImpl.isRegisteredToFirm(firmName, authority);
    }

    function isRegisteredAuthority(address authority) public view returns (bool registered) {
        return tokenIOAuthorityImpl.isRegisteredAuthority(authority);
    }

    function setMasterFeeContract(address feeContract) public onlyOwner returns (bool success) {
        require(
          tokenIOAuthorityImpl.setMasterFeeContract(feeContract),
          "Unable to execute setMasterFeeContract"
        );
        return true;
    }

}
