require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config(); // 🔥 Pastikan dotenv dipanggil di awal!

module.exports = {
  solidity: "0.8.19",
  networks: {
    polygonAmoy: {
      url: process.env.POLYGON_AMOY_RPC || "", // 🔥 Pastikan dotenv digunakan dengan benar
      accounts: process.env.PRIVATE_KEY ? [`0x${process.env.PRIVATE_KEY}`] : [],
    },
  },
};

