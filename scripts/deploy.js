const hre = require("hardhat");

async function main() {
  const IDT_TOKEN_ADDRESS = "0x95351dF7dC2A753C8cFa4a0fD7C3Ee9F6D883306"; // Format checksum benar

  const MLM_Binary = await hre.ethers.getContractFactory("MLM_Binary");
  const contract = await MLM_Binary.deploy(IDT_TOKEN_ADDRESS);
  await contract.deployed();

  console.log(`MLM_Binary deployed at: ${contract.address}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
