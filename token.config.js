const USDx = [
  'USD by token.io', // tokenName
  'USDx', // tokenSymbol
  'USD', // tokenTLA
  'v0.1.3', // tokenVersion
  2, // tokenDecimals
  2, // bps fee
  0, // min fee
  100, // max fee
  2, // flat fee
  "0x8cb2cebb0070b231d4ba4d3b747acaebdfbbd142" // fee account
]

const AUTHORITY_DETAILS = {
  firmName: "Token, Inc.",
  authorityAddress: "0x8cb2cebb0070b231d4ba4d3b747acaebdfbbd142"
}

module.exports = {
  mode: 'development',
  development: {
    TOKEN_DETAILS: {
      USDx
    },
    AUTHORITY_DETAILS
  },
  production: {
    TOKEN_DETAILS: {
      USDx
    },
    AUTHORITY_DETAILS
  }
}


// CSV
// "0x8cb2cebb0070b231d4ba4d3b747acaebdfbbd142",
// "0x8cb2cebb0070b231d4ba4d3b747acaebdfbbd142",
// "USD by token.io",
// "USDx",
// "USD",
// "v0.1.2",
// 2
