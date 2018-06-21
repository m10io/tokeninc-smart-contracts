pragma solidity 0.4.24;

import "./SafeMath.sol";
import "./TokenIOStorage.sol";


library TokenIOLib {

  using SafeMath for uint;

  struct Data {
    TokenIOStorage Storage;
  }

  event LogDeposit(string currency, address account, uint amount, string issuerFirm);

  event LogWithdraw(string currency, address account, uint amount, string issuerFirm);


  function setTokenName(Data storage self, string tokenName) internal returns (bool) {
    bytes32 id = keccak256(abi.encode('token.name', address(this)));
    self.Storage.setString(id, tokenName);
    return true;
  }

  function setTokenSymbol(Data storage self, string tokenSymbol) internal returns (bool) {
    bytes32 id = keccak256(abi.encode('token.symbol', address(this)));
    self.Storage.setString(id, tokenSymbol);
    return true;
  }

  function setTokenTLA(Data storage self, string tokenTLA) internal returns (bool) {
    bytes32 id = keccak256(abi.encode('token.tla', address(this)));
    self.Storage.setString(id, tokenTLA);
    return true;
  }

  function setTokenVersion(Data storage self, string tokenVersion) internal returns (bool) {
    bytes32 id = keccak256(abi.encode('token.version', address(this)));
    self.Storage.setString(id, tokenVersion);
    return true;
  }

  function setTokenDecimals(Data storage self, uint tokenDecimals) internal returns (bool) {
    bytes32 id = keccak256(abi.encode('token.decimals', address(this)));
    self.Storage.setUint(id, tokenDecimals);
    return true;
  }

  function setTokenFeeBPS(Data storage self, uint tokenFeeBPS) internal returns (bool) {
    bytes32 id = keccak256(abi.encode('token.fee.bps', address(this)));
    self.Storage.setUint(id, tokenFeeBPS);
    return true;
  }

  function setTokenFeeMin(Data storage self, uint tokenFeeMin) internal returns (bool) {
    bytes32 id = keccak256(abi.encode('token.fee.min', address(this)));
    self.Storage.setUint(id, tokenFeeMin);
    return true;
  }

  function setTokenFeeMax(Data storage self, uint tokenFeeMax) internal returns (bool) {
    bytes32 id = keccak256(abi.encode('token.fee.max', address(this)));
    self.Storage.setUint(id, tokenFeeMax);
    return true;
  }

  function setTokenFeeFlat(Data storage self, uint tokenFeeFlat) internal returns (bool) {
    bytes32 id = keccak256(abi.encode('token.fee.flat', address(this)));
    self.Storage.setUint(id, tokenFeeFlat);
    return true;
  }

  function setTokenFeeAccount(Data storage self, address tokenFeeAccount) internal returns (bool) {
    bytes32 id = keccak256(abi.encode('token.fee.account', address(this)));
    self.Storage.setAddress(id, tokenFeeAccount);
    return true;
  }

  function setTokenNameSpace(Data storage self, string currency) internal returns (bool) {
    bytes32 id = keccak256(abi.encode('token.namespace', currency));
    self.Storage.setAddress(id, address(this));
    return true;
  }

  function getTokenNameSpace(Data storage self, string currency) internal view returns (address) {
    bytes32 id = keccak256(abi.encode('token.namespace', currency));
    return self.Storage.getAddress(id);
  }

  function getTokenName(Data storage self, address contractAddress) internal view returns (string) {
    bytes32 id = keccak256(abi.encode('token.name', contractAddress));
    return self.Storage.getString(id);
  }

  function getTokenSymbol(Data storage self, address contractAddress) internal view returns (string) {
    bytes32 id = keccak256(abi.encode('token.symbol', contractAddress));
    return self.Storage.getString(id);
  }

  function getTokenTLA(Data storage self, address contractAddress) internal view returns (string) {
    bytes32 id = keccak256(abi.encode('token.tla', contractAddress));
    return self.Storage.getString(id);
  }

  function getTokenVersion(Data storage self, address contractAddress) internal view returns (string) {
    bytes32 id = keccak256(abi.encode('token.version', contractAddress));
    return self.Storage.getString(id);
  }

  function getTokenDecimals(Data storage self, address contractAddress) internal view returns (uint) {
    bytes32 id = keccak256(abi.encode('token.decimals', contractAddress));
    return self.Storage.getUint(id);
  }

  function getTokenFeeBPS(Data storage self, address contractAddress) internal view returns (uint) {
    bytes32 id = keccak256(abi.encode('token.fee.bps', contractAddress));
    return self.Storage.getUint(id);
  }

  function getTokenFeeMin(Data storage self, address contractAddress) internal view returns (uint) {
    bytes32 id = keccak256(abi.encode('token.fee.min', contractAddress));
    return self.Storage.getUint(id);
  }

  function getTokenFeeMax(Data storage self, address contractAddress) internal view returns (uint) {
    bytes32 id = keccak256(abi.encode('token.fee.max', contractAddress));
    return self.Storage.getUint(id);
  }

  function getTokenFeeFlat(Data storage self, address contractAddress) internal view returns (uint) {
    bytes32 id = keccak256(abi.encode('token.fee.flat', contractAddress));
    return self.Storage.getUint(id);
  }

  function getTokenFeeAccount(Data storage self, address contractAddress) internal view returns (address) {
    bytes32 id = keccak256(abi.encode('token.fee.account', contractAddress));
    return self.Storage.getAddress(id);
  }

  function getTokenSupply(Data storage self, address contractAddress) internal view returns (uint) {
    bytes32 id = keccak256(abi.encode('token.supply', contractAddress));
    return self.Storage.getUint(id);
  }

  function getAllowance(Data storage self, address contractAddress, address account, address spender) internal view returns (uint) {
    bytes32 id = keccak256(abi.encode('token.allowance', contractAddress, account, spender));
    return self.Storage.getUint(id);
  }

  function getBalance(Data storage self, address contractAddress, address account) internal view returns (uint) {
    bytes32 id = keccak256(abi.encode('token.balance', contractAddress, account));
    return self.Storage.getUint(id);
  }

  function getFrozenBalance(Data storage self, address contractAddress, address account) internal view returns (uint) {
    bytes32 id = keccak256(abi.encode('token.frozen', contractAddress, account));
    return self.Storage.getUint(id);
  }

//   function getTokenFirmIssued(Data storage self, address contractAddress) internal view returns (uint) {

//   }

//   function getTokenFirmIssuedBy(Data storage self, address contractAddress) internal view returns (uint) {

//   }


  function calculateFees(Data storage self, address contractAddress, uint amount) internal view returns (uint) {

    /// @dev Set upper limit on fees;
    uint maxFee = self.Storage.getUint(keccak256(abi.encode('token.fee.max', contractAddress)));

    /// @dev On values less than 3, bpsFee will round down to 0;
    uint bpsFee = self.Storage.getUint(keccak256(abi.encode('token.fee.bps', contractAddress)));

    /// @dev Provide flat fee for all values;
    uint flatFee = self.Storage.getUint(keccak256(abi.encode('token.fee.flat', contractAddress)));

    /// @dev Calculate basis point fees plus flat fee;
    uint fees = ((amount.mul(bpsFee)).div(10000)).add(flatFee);

    /// @dev Return maxFee if calculated fees exceed max value;
    if (fees > maxFee) {
      return maxFee;
      } else {
        return fees;
      }
    }


    function transferERC20(Data storage self, address from, address to, uint amount) internal returns (bool) {
      /// @dev Ensure value is not being transferred to a null account;
      require(address(to) != 0x0);

      /// @notice Calculate Fees based on amount
      uint fees = calculateFees(self, address(this), amount);

      bytes32 id_a = keccak256(abi.encode('token.balance', address(this), from));
      bytes32 id_b = keccak256(abi.encode('token.balance', address(this), to));
      bytes32 id_c = keccak256(abi.encode('token.balance', address(this), getTokenFeeAccount(self, address(this))));

      require(self.Storage.setUint(id_a, self.Storage.getUint(id_a).sub(amount.add(fees))));
      require(self.Storage.setUint(id_b, self.Storage.getUint(id_b).add(amount)));
      require(self.Storage.setUint(id_c, self.Storage.getUint(id_c).add(fees)));

      return true;
    }

    function transferFromERC20(Data storage self, address spender, address from, address to, uint amount) internal returns (bool) {
      /// @dev Ensure value is not being transferred to a null account;
      require(address(to) != 0x0);

      /// @notice Calculate Fees based on amount
      uint fees = calculateFees(self, address(this), amount);

      bytes32 id_a = keccak256(abi.encode('token.balance', address(this), from));
      bytes32 id_b = keccak256(abi.encode('token.balance', address(this), to));
      bytes32 id_c = keccak256(abi.encode('token.balance', address(this), getTokenFeeAccount(self, address(this))));
      bytes32 id_d = keccak256(abi.encode('token.allowance', address(this), from, spender));

      require(self.Storage.setUint(id_a, self.Storage.getUint(id_a).sub(amount.add(fees))));
      require(self.Storage.setUint(id_b, self.Storage.getUint(id_b).add(amount)));
      require(self.Storage.setUint(id_c, self.Storage.getUint(id_c).add(fees)));
      require(self.Storage.setUint(id_d, self.Storage.getUint(id_d).sub(amount)));

      return true;
    }

    function approveERC20(Data storage self, address account, address spender, uint amount) internal returns (bool) {
      bytes32 id_a = keccak256(abi.encode('token.allowance', address(this), account, spender));
      bytes32 id_b = keccak256(abi.encode('token.balance', address(this), account));

      require(self.Storage.getUint(id_a) == 0 || amount == 0);
      require(self.Storage.getUint(id_b) >= amount);

      require(self.Storage.setUint(id_a, amount));

      return true;
    }

    function deposit(Data storage self, address contractAddress, address account, uint amount, string issuerFirm) internal returns (bool) {
        bytes32 id_a = keccak256(abi.encode('token.balance', contractAddress, account));
        bytes32 id_b = keccak256(abi.encode('token.issued', contractAddress, issuerFirm));
        bytes32 id_c = keccak256(abi.encode('token.supply', contractAddress));


        require(self.Storage.setUint(id_a, self.Storage.getUint(id_a).add(amount)));
        require(self.Storage.setUint(id_b, self.Storage.getUint(id_b).add(amount)));
        require(self.Storage.setUint(id_c, self.Storage.getUint(id_c).add(amount)));

        emit LogDeposit(getTokenSymbol(self, contractAddress), account, amount, issuerFirm);

        return true;

    }

    function withdraw(Data storage self, address contractAddress, address account, uint amount, string issuerFirm) internal returns (bool) {
        bytes32 id_a = keccak256(abi.encode('token.balance', contractAddress, account));
        bytes32 id_b = keccak256(abi.encode('token.issued', contractAddress, issuerFirm)); // possible for issuer to go negative
        bytes32 id_c = keccak256(abi.encode('token.supply', contractAddress));


        require(self.Storage.setUint(id_a, self.Storage.getUint(id_a).sub(amount)));
        require(self.Storage.setUint(id_b, self.Storage.getUint(id_b).sub(amount)));
        require(self.Storage.setUint(id_c, self.Storage.getUint(id_c).sub(amount)));

        emit LogWithdraw(getTokenSymbol(self, contractAddress), account, amount, issuerFirm);

        return true;

    }

    function setRegisteredFirm(Data storage self, string _firmName, bool _authorized) internal returns (bool) {
        bytes32 id = keccak256(abi.encode('registered.firm', _firmName));
        require(self.Storage.setBool(id, _authorized));
        return true;
    }

    function setRegisteredAuthority(Data storage self, string _firmName, address _authority, bool _authorized) internal returns (bool) {
        require(isRegisteredFirm(self, _firmName));
        bytes32 id_a = keccak256(abi.encode('registered.authority', _firmName, _authority));
        bytes32 id_b = keccak256(abi.encode('registered.authority.firm', _authority));

        require(self.Storage.setBool(id_a, _authorized));
        require(self.Storage.setString(id_b, _firmName));

        return true;
    }

    function getFirmFromAuthority(Data storage self, address _authority) internal view returns (string) {
        bytes32 id = keccak256(abi.encode('registered.authority.firm', _authority));
        return self.Storage.getString(id);
    }

    function isRegisteredFirm(Data storage self, string _firmName) internal view returns (bool) {
        bytes32 id = keccak256(abi.encode('registered.firm', _firmName));
        return self.Storage.getBool(id);
    }

    function isRegisteredToFirm(Data storage self, string _firmName, address _authority) internal view returns (bool) {
        bytes32 id = keccak256(abi.encode('registered.authority', _firmName, _authority));
        return self.Storage.getBool(id);
    }

    function isRegisteredAuthority(Data storage self, address _authority) internal view returns (bool) {
        bytes32 id = keccak256(abi.encode('registered.authority', getFirmFromAuthority(self, _authority), _authority));
        return self.Storage.getBool(id);
    }


  }
