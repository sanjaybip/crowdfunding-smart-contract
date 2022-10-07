require("@nomicfoundation/hardhat-toolbox");

require("dotenv").config({ path: ".env" });
require("@nomiclabs/hardhat-etherscan");

const ALCHEMY_API_KEY_URL = process.env.MUMBAI_RPC_URL;

const MUMBAI_PRIVATE_KEY = process.env.PRIVATE_KEY;

const POLYGONSCAN_KEY = process.env.POLYGONSCAN_API_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
  networks: {
    hardhat: {
      chainId: 1337,
    },
    mumbai: {
      url: ALCHEMY_API_KEY_URL,
      accounts: [MUMBAI_PRIVATE_KEY],
      chainId: 80001,
    },
  },
  etherscan: {
    apiKey: {
      polygonMumbai: POLYGONSCAN_KEY,
    },
  },
};
