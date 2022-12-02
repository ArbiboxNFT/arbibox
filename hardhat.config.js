require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.6",
  settings: {
    optimizer: {
      runs: 999999,
      enabled: true
    }
  }
};
