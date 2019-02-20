pragma solidity 0.5.2;

import "./Ownable.sol";
import "./UpgradableProxy.sol";

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

contract TokenIOCurrencyAuthorityProxy is Ownable, UpgradableProxy {

    constructor(address _tokenIOCurrencyAuthorityImpl, bytes memory _data) UpgradableProxy(_tokenIOCurrencyAuthorityImpl, _data) public {
    }

    function upgradeTo(address _newTokenIOCurrencyAuthorityImpl) external {
      _upgradeTo(_newTokenIOCurrencyAuthorityImpl);
    }
  
    function getTokenBalance(string memory currency, address account) public view returns (uint balance) {
      return TokenIOCurrencyAuthorityI(_implementation()).getTokenBalance(currency, account);
    }

    function getTokenSupply(string memory currency) public view returns (uint supply) {
      return TokenIOCurrencyAuthorityI(_implementation()).getTokenSupply(currency);
    }

    function freezeAccount(address account, bool isAllowed, string memory issuerFirm) public returns (bool success) {
        require(
          TokenIOCurrencyAuthorityI(_implementation()).freezeAccount(account, isAllowed, issuerFirm, msg.sender),
          "Unable to execute freezeAccount"
        );
        return true;
    }

    function approveKYC(address account, bool isApproved, uint limit, string memory issuerFirm) public returns (bool success) {
        require(
          TokenIOCurrencyAuthorityI(_implementation()).approveKYC(account, isApproved, limit, issuerFirm, msg.sender),
          "Unable to execute approveKYC"
        );

        return true;
    }

    function approveKYCAndDeposit(string memory currency, address account, uint amount, uint limit, string memory issuerFirm) public returns (bool success) {
        require(
          TokenIOCurrencyAuthorityI(_implementation()).approveKYCAndDeposit(currency, account, amount, limit, issuerFirm, msg.sender),
          "Unable to execute approveKYCAndDeposit"
        );

        return true;
    }

    function setAccountSpendingLimit(address account, uint limit, string memory issuerFirm) public returns (bool success) {
      require(
        TokenIOCurrencyAuthorityI(_implementation()).setAccountSpendingLimit(account, limit, issuerFirm, msg.sender),
        "Unable to execute setAccountSpendingLimit"
      );
      return true;
    }

    function getAccountSpendingRemaining(address account) public view returns (uint spendingRemaining) {
      return TokenIOCurrencyAuthorityI(_implementation()).getAccountSpendingRemaining(account);
    }

    function getAccountSpendingLimit(address account) public view returns (uint spendingLimit) {
      return TokenIOCurrencyAuthorityI(_implementation()).getAccountSpendingLimit(account);
    }

    function setFxBpsRate(string memory currency, uint bpsRate, string memory issuerFirm) public returns (bool success) {
      require(
        TokenIOCurrencyAuthorityI(_implementation()).setFxBpsRate(currency, bpsRate, issuerFirm, msg.sender),
        "Unable to execute setFxBpsRate"
      );
      return true;
    }

    function getFxUSDAmount(string memory currency, uint fxAmount) public view returns (uint usdAmount) {
      return TokenIOCurrencyAuthorityI(_implementation()).getFxUSDAmount(currency, fxAmount);
    }

    function approveForwardedAccount(address originalAccount, address updatedAccount, string memory issuerFirm) public returns (bool success) {
        require(
          TokenIOCurrencyAuthorityI(_implementation()).approveForwardedAccount(originalAccount, updatedAccount, issuerFirm, msg.sender),
          "Unable to execute approveForwardedAccount"
        );
        return true;
    }

    function deposit(string memory currency, address account, uint amount, string memory issuerFirm) public returns (bool success) {
        require(
          TokenIOCurrencyAuthorityI(_implementation()).deposit(currency, account, amount, issuerFirm, msg.sender),
          "Unable to execute deposit"
        );
        return true;
    }

    function withdraw(string memory currency, address account, uint amount, string memory issuerFirm) public returns (bool success) {
        require(
          TokenIOCurrencyAuthorityI(_implementation()).withdraw(currency, account, amount, issuerFirm, msg.sender),
          "Unable to execute withdraw"
        );
        return true;
    }
}
