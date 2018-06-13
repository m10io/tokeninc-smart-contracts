pragma solidity 0.4.24;

import "./SafeMath.sol";
import "./TokenIOStorage.sol";


library TokenIOLib {

    using SafeMath for uint;

    struct Data {
      TokenIOStorage Storage;
    }

    function setTokenName(Data storage self, string _tokenName) internal returns (bool) {
        bytes32 id = keccak256(abi.encode('token.name', address(this)));
        self.Storage.setString(id, _tokenName);
        return true;
    }

    function setTokenSymbol(Data storage self, string _tokenSymbol) internal returns (bool) {
        bytes32 id = keccak256(abi.encode('token.symbol', address(this)));
        self.Storage.setString(id, _tokenSymbol);
        return true;
    }

    function setTokenTLA(Data storage self, string _tokenTLA) internal returns (bool) {
        bytes32 id = keccak256(abi.encode('token.tla', address(this)));
        self.Storage.setString(id, _tokenTLA);
        return true;
    }

    function setTokenVersion(Data storage self, string _tokenVersion) internal returns (bool) {
        bytes32 id = keccak256(abi.encode('token.version', address(this)));
        self.Storage.setString(id, _tokenVersion);
        return true;
    }

    function setTokenDecimals(Data storage self, uint _tokenDecimals) internal returns (bool) {
        bytes32 id = keccak256(abi.encode('token.decimals', address(this)));
        self.Storage.setUint(id, _tokenDecimals);
        return true;
    }

    function setTokenFeeBPS(Data storage self, uint _tokenFeeBPS) internal returns (bool) {
        bytes32 id = keccak256(abi.encode('token.fee.bps', address(this)));
        self.Storage.setUint(id, _tokenFeeBPS);
        return true;
    }

    function setTokenFeeMin(Data storage self, uint _tokenFeeMin) internal returns (bool) {
        bytes32 id = keccak256(abi.encode('token.fee.min', address(this)));
        self.Storage.setUint(id, _tokenFeeMin);
        return true;
    }

    function setTokenFeeMax(Data storage self, uint _tokenFeeMax) internal returns (bool) {
        bytes32 id = keccak256(abi.encode('token.fee.max', address(this)));
        self.Storage.setUint(id, _tokenFeeMax);
        return true;
    }

    function setTokenFeeFlat(Data storage self, uint _tokenFeeFlat) internal returns (bool) {
        bytes32 id = keccak256(abi.encode('token.fee.flat', address(this)));
        self.Storage.setUint(id, _tokenFeeFlat);
        return true;
    }

    function setTokenFeeAccount(Data storage self, address _tokenFeeAccount) internal returns (bool) {
        bytes32 id = keccak256(abi.encode('token.fee.account', address(this)));
        self.Storage.setAddress(id, _tokenFeeAccount);
        return true;
    }

    function getTokenName(Data storage self) internal view returns (string) {
      bytes32 id = keccak256(abi.encode('token.name', address(this)));
      return self.Storage.getString(id);
    }

    function getTokenSymbol(Data storage self) internal view returns (string) {
      bytes32 id = keccak256(abi.encode('token.symbol', address(this)));
      return self.Storage.getString(id);
    }

    function getTokenTLA(Data storage self) internal view returns (string) {
      bytes32 id = keccak256(abi.encode('token.tla', address(this)));
      return self.Storage.getString(id);
    }

    function getTokenVersion(Data storage self) internal view returns (string) {
      bytes32 id = keccak256(abi.encode('token.version', address(this)));
      return self.Storage.getString(id);
    }

    function getTokenDecimals(Data storage self) internal view returns (uint) {
      bytes32 id = keccak256(abi.encode('token.decimals', address(this)));
      return self.Storage.getUint(id);
    }

    function getTokenFeeBPS(Data storage self) internal view returns (uint) {
      bytes32 id = keccak256(abi.encode('token.fee.bps', address(this)));
      return self.Storage.getUint(id);
    }

    function getTokenFeeMin(Data storage self) internal view returns (uint) {
      bytes32 id = keccak256(abi.encode('token.fee.min', address(this)));
      return self.Storage.getUint(id);
    }

    function getTokenFeeMax(Data storage self) internal view returns (uint) {
      bytes32 id = keccak256(abi.encode('token.fee.max', address(this)));
      return self.Storage.getUint(id);
    }

    function getTokenFeeFlat(Data storage self) internal view returns (uint) {
      bytes32 id = keccak256(abi.encode('token.fee.flat', address(this)));
      return self.Storage.getUint(id);
    }

    function getTokenFeeAccount(Data storage self) internal view returns (address) {
      bytes32 id = keccak256(abi.encode('token.fee.account', address(this)));
      return self.Storage.getAddress(id);
    }

    function getTokenSupply(Data storage self) internal view returns (uint) {
      bytes32 id = keccak256(abi.encode('token.supply', address(this)));
      return self.Storage.getUint(id);
    }

    function getAllowance(Data storage self, address account, address spender) public view returns (uint) {
        bytes32 id = keccak256(abi.encode('token.allowance', address(this), account, spender));
        return self.Storage.getUint(id);
    }

    function getBalance(Data storage self, address account) public view returns (uint) {
        bytes32 id = keccak256(abi.encode('token.balance', address(this), account));
        return self.Storage.getUint(id);
    }


    function calculateFees(Data storage self, uint amount) public view returns (uint) {

      /// @dev Set upper limit on fees;
      uint maxFee = self.Storage.getUint(keccak256(abi.encode('token.fee.max', address(this))));

      /// @dev On values less than 3, bpsFee will round down to 0;
      uint bpsFee = self.Storage.getUint(keccak256(abi.encode('token.fee.bps', address(this))));

      /// @dev Provide flat fee for all values;
      uint flatFee = self.Storage.getUint(keccak256(abi.encode('token.fee.flat', address(this))));

      /// @dev Calculate basis point fees plus flat fee;
      uint fees = ((amount.mul(bpsFee)).div(10000)).add(flatFee);

      /// @dev Return maxFee if calculated fees exceed max value;
      if (fees > maxFee) {
        return maxFee;
      } else {
        return fees;
      }
    }


    function transfer(Data storage self, address from, address to, uint amount) internal returns (bool) {
      /// @dev Ensure value is not being transferred to a null account;
      require(address(to) != 0x0);

      /// @notice Calculate Fees based on amount
      uint fees = calculateFees(self, amount);

      bytes32 id_a = keccak256(abi.encode('token.balance', address(this), from));
      bytes32 id_b = keccak256(abi.encode('token.balance', address(this), to));
      bytes32 id_c = keccak256(abi.encode('token.balance', address(this), getTokenFeeAccount(self)));

      self.Storage.setUint(id_a, self.Storage.getUint(id_a).sub(amount.add(fees)));
      self.Storage.setUint(id_b, self.Storage.getUint(id_b).add(amount));
      self.Storage.setUint(id_c, self.Storage.getUint(id_c).add(fees));

      return true;
    }

    function transferFrom(Data storage self, address spender, address from, address to, uint amount) internal returns (bool) {
      /// @dev Ensure value is not being transferred to a null account;
      require(address(to) != 0x0);

      /// @notice Calculate Fees based on amount
      uint fees = calculateFees(self, amount);

      bytes32 id_a = keccak256(abi.encode('token.balance', address(this), from));
      bytes32 id_b = keccak256(abi.encode('token.balance', address(this), to));
      bytes32 id_c = keccak256(abi.encode('token.balance', address(this), getTokenFeeAccount(self)));
      bytes32 id_d = keccak256(abi.encode('token.allowance', address(this), from, spender));

      self.Storage.setUint(id_a, self.Storage.getUint(id_a).sub(amount.add(fees)));
      self.Storage.setUint(id_b, self.Storage.getUint(id_b).add(amount));
      self.Storage.setUint(id_c, self.Storage.getUint(id_c).add(fees));
      self.Storage.setUint(id_d, self.Storage.getUint(id_d).sub(amount));

      return true;
    }

    function approve(Data storage self, address account, address spender, uint amount) internal returns (bool) {
      bytes32 id_a = keccak256(abi.encode('token.allowance', address(this), account, spender));
      bytes32 id_b = keccak256(abi.encode('token.balance', address(this), account));

      require(self.Storage.getUint(id_a) == 0 || amount == 0);
      require(self.Storage.getUint(id_b) >= amount);

      self.Storage.setUint(id_a, amount);

      return true;
    }


}
