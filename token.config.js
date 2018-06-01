const USDx = {
  tokenName: 'USD by token.io',
  tokenSymbol: 'USDx',
  tokenTLA: 'USD',
  tokenVersion: 'v0.1.0',
  tokenDecimals: 2
}


module.exports = {
  mode: 'development',
  tokenDetails: USDx,
  development: {
    admin: "0x8cb2cebb0070b231d4ba4d3b747acaebdfbbd142",
  	feeAccount: "0x8cb2cebb0070b231d4ba4d3b747acaebdfbbd142",
  },
  production: {
    admin: "0xc444Ca35CBA4a71Ad75325C34428B5e7348a7EE0",
  	feeAccount: "0x00a054ffda97220e9a7483e6e7b87d445e4d6c96",

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
