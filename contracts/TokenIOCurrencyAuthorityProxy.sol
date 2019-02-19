pragma solidity 0.5.2;

import "./Ownable.sol";

interface TokenIOCurrencyAuthorityI {
  function getTokenBalance(string calldata currency, address account) external view returns (uint balance);

  function getTokenSupply(string calldata currency) external view returns (uint supply);

  function freezeAccount(address account, bool isAllowed, string calldata issuerFirm, address sender) external returns (bool success);

  function approveKYC(address account, bool isApproved, uint limit, string calldata issuerFirm, address sender) external returns (bool success);

  function approveKYCAndDeposit(string calldata currency, address account, uint amount, uint limit, string calldata issuerFirm, address sender) external returns (bool success);

  function setAccountSpendingLimit(address account, uint limit, string calldata issuerFirm, address sender) external returns (bool success);

  function getAccountSpendingRemaining(address account) external view returns (uint spendingRemaining);

  function getAccountSpendingLimit(address account) external view returns (uint spendingLimit);

  function setFxBpsRate(string calldata currency, uint bpsRate, string calldata issuerFirm, address sender) external returns (bool success);

  function getFxUSDAmount(string calldata currency, uint fxAmount) external view returns (uint usdAmount);

  function approveForwardedAccount(address originalAccount, address updatedAccount, string calldata issuerFirm, address sender) external returns (bool success);

  function deposit(string calldata currency, address account, uint amount, string calldata issuerFirm, address sender) external returns (bool success);

  function withdraw(string calldata currency, address account, uint amount, string calldata issuerFirm, address sender) external returns (bool success);
}

contract TokenIOCurrencyAuthorityProxy is Ownable {

    TokenIOCurrencyAuthorityI tokenIOCurrencyAuthorityImpl;

    constructor(address _tokenIOCurrencyAuthorityImpl) public {
      tokenIOCurrencyAuthorityImpl = TokenIOCurrencyAuthorityI(_tokenIOCurrencyAuthorityImpl);
    }

    function upgradeTokenImplamintation(address _newTokenIOCurrencyAuthorityImpl) onlyOwner external {
      require(_newTokenIOCurrencyAuthorityImpl != address(0));
      tokenIOCurrencyAuthorityImpl = TokenIOCurrencyAuthorityI(_newTokenIOCurrencyAuthorityImpl);
    }
  
    function getTokenBalance(string memory currency, address account) public view returns (uint balance) {
      return tokenIOCurrencyAuthorityImpl.getTokenBalance(currency, account);
    }

    function getTokenSupply(string memory currency) public view returns (uint supply) {
      return tokenIOCurrencyAuthorityImpl.getTokenSupply(currency);
    }

    function freezeAccount(address account, bool isAllowed, string memory issuerFirm) public returns (bool success) {
        require(
          tokenIOCurrencyAuthorityImpl.freezeAccount(account, isAllowed, issuerFirm, msg.sender),
          "Unable to execute freezeAccount"
        );
        return true;
    }

    function approveKYC(address account, bool isApproved, uint limit, string memory issuerFirm) public returns (bool success) {
        require(
          tokenIOCurrencyAuthorityImpl.approveKYC(account, isApproved, limit, issuerFirm, msg.sender),
          "Unable to execute approveKYC"
        );

        return true;
    }

    function approveKYCAndDeposit(string memory currency, address account, uint amount, uint limit, string memory issuerFirm) public returns (bool success) {
        require(
          tokenIOCurrencyAuthorityImpl.approveKYCAndDeposit(currency, account, amount, limit, issuerFirm, msg.sender),
          "Unable to execute approveKYCAndDeposit"
        );

        return true;
    }

    function setAccountSpendingLimit(address account, uint limit, string memory issuerFirm) public returns (bool success) {
      require(
        tokenIOCurrencyAuthorityImpl.setAccountSpendingLimit(account, limit, issuerFirm, msg.sender),
        "Unable to execute setAccountSpendingLimit"
      );
      return true;
    }

    function getAccountSpendingRemaining(address account) public view returns (uint spendingRemaining) {
      return tokenIOCurrencyAuthorityImpl.getAccountSpendingRemaining(account);
    }

    function getAccountSpendingLimit(address account) public view returns (uint spendingLimit) {
      return tokenIOCurrencyAuthorityImpl.getAccountSpendingLimit(account);
    }

    function setFxBpsRate(string memory currency, uint bpsRate, string memory issuerFirm) public returns (bool success) {
      require(
        tokenIOCurrencyAuthorityImpl.setFxBpsRate(currency, bpsRate, issuerFirm, msg.sender),
        "Unable to execute setFxBpsRate"
      );
      return true;
    }

    function getFxUSDAmount(string memory currency, uint fxAmount) public view returns (uint usdAmount) {
      return tokenIOCurrencyAuthorityImpl.getFxUSDAmount(currency, fxAmount);
    }

    function approveForwardedAccount(address originalAccount, address updatedAccount, string memory issuerFirm) public returns (bool success) {
        require(
          tokenIOCurrencyAuthorityImpl.approveForwardedAccount(originalAccount, updatedAccount, issuerFirm, msg.sender),
          "Unable to execute approveForwardedAccount"
        );
        return true;
    }

    function deposit(string memory currency, address account, uint amount, string memory issuerFirm) public returns (bool success) {
        require(
          tokenIOCurrencyAuthorityImpl.deposit(currency, account, amount, issuerFirm, msg.sender),
          "Unable to execute deposit"
        );
        return true;
    }

    function withdraw(string memory currency, address account, uint amount, string memory issuerFirm) public returns (bool success) {
        require(
          tokenIOCurrencyAuthorityImpl.withdraw(currency, account, amount, issuerFirm, msg.sender),
          "Unable to execute withdraw"
        );
        return true;
    }
}
