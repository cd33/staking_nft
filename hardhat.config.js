require('dotenv').config()
require('@nomiclabs/hardhat-waffle')
require("@nomiclabs/hardhat-etherscan");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 module.exports = {
  paths: {
    artifacts: './artifacts',
  },
  solidity: {
    version: "0.8.7",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  mocha: {
    timeout: 10000000,
  },
  networks: {
    rinkeby: {
      url: process.env.INFURA,
      accounts: [process.env.PRIVATE_KEY],
      allowUnlimitedContractSize: true
    },  
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN
  }
}