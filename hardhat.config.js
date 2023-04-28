require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
const API_URL = process.env.API_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.10",
  networks:{
    matic: {
          url : API_URL,
           accounts : [PRIVATE_KEY]
  }
}
}
;
