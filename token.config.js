const USDx = {
  // Ensure these values are ordered in the object for the respective param list
  // index in the erc20 contract setPrams() method.
  tokenName: 'Token USD', // tokenName
  tokenSymbol: 'USDx', // tokenSymbol
  tokenTLA: 'USD', // tokenTLA
  tokenVersion: 'v0.1.3', // tokenVersion
  tokenDecimals: 2, // tokenDecimals
  feeContract: "0x0", // fee account
  fxBPSRate: 10000
}

const MXNx = {
  // Ensure these values are ordered in the object for the respective param list
  // index in the erc20 contract setPrams() method.
  tokenName: 'Token MXN', // tokenName
  tokenSymbol: 'MXNx', // tokenSymbol
  tokenTLA: 'MXN', // tokenTLA
  tokenVersion: 'v0.1.3', // tokenVersion
  tokenDecimals: 2, // tokenDecimals
  feeContract: "0x0", // fee account
  fxBPSRate: 510
}

const GBPx = {
  // Ensure these values are ordered in the object for the respective param list
  // index in the erc20 contract setPrams() method.
  tokenName: 'Token GBP', // tokenName
  tokenSymbol: 'GBPx', // tokenSymbol
  tokenTLA: 'GBP', // tokenTLA
  tokenVersion: 'v0.1.3', // tokenVersion
  tokenDecimals: 2, // tokenDecimals
  feeContract: "0x0", // fee account
  fxBPSRate: 13200
}

const JPYx = {
  // Ensure these values are ordered in the object for the respective param list
  // index in the erc20 contract setPrams() method.
  tokenName: 'Token JPY', // tokenName
  tokenSymbol: 'JPYx', // tokenSymbol
  tokenTLA: 'JPY', // tokenTLA
  tokenVersion: 'v0.1.3', // tokenVersion
  tokenDecimals: 0, // tokenDecimals
  feeContract: "0x0", // fee account
  fxBPSRate: 90
}

const EURx = {
  // Ensure these values are ordered in the object for the respective param list
  // index in the erc20 contract setPrams() method.
  tokenName: 'Token EUR', // tokenName
  tokenSymbol: 'EURx', // tokenSymbol
  tokenTLA: 'EUR', // tokenTLA
  tokenVersion: 'v0.1.3', // tokenVersion
  tokenDecimals: 2, // tokenDecimals
  feeContract: "0x0", // fee account
  fxBPSRate: 11700
}

const AUTHORITY_DETAILS = {
  firmName: "Token, Inc.",
  authorityAddress: "0x8cb2cebb0070b231d4ba4d3b747acaebdfbbd142"
}

const FEE_PARAMS = {
    feeBps: 2, // bps fee
    feeMin: 0, // min fee
    feeMax: 100, // max fee
    feeFlat: 2, // flat fee
    feeMsg: "0x547846656573"
}

module.exports = {
  mode: 'development',
  development: {
    TOKEN_DETAILS: [
        USDx,
        MXNx,
        GBPx,
        JPYx,
        EURx,
    ],
    AUTHORITY_DETAILS,
    FEE_PARAMS
  },
  production: {
    TOKEN_DETAILS: [
        USDx,
        MXNx,
        GBPx,
        JPYx,
        EURx,
    ],
    AUTHORITY_DETAILS,
    FEE_PARAMS
  }
}


// "Token USD",
// "USDx",
// "USD",
// "v0.1.2",
// 2,
// "0x310bd4225ecef15ba21bab3fce87289ee6568f4f",
// 10000
