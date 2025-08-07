const hre = require("hardhat");

async function main() {
  const zkpStorageAddress = "0x5FC8d32690cc91D4c39d9d3abcBD16989F875707";


  const ZKPStorage = await hre.ethers.getContractFactory("ZKPStorage");
  const zkpStorage = await ZKPStorage.attach(zkpStorageAddress);

  const result = await zkpStorage.verifyMyProof();
  console.log("Verification result:", result);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});