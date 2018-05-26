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
    admin: "0x627306090abab3a6e1400e9345bc60c78a8bef57",
  	feeAccount: "0x5aeda56215b167893e80b4fe645ba6d5bab767de",
  },
  production: {
    admin: "0xc444Ca35CBA4a71Ad75325C34428B5e7348a7EE0",
  	feeAccount: "0x00a054ffda97220e9a7483e6e7b87d445e4d6c96",

  }
}
