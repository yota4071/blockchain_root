const hre = require("hardhat");

async function main() {
  const zkpStorageAddress = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";


  const ZKPStorage = await hre.ethers.getContractFactory("ZKPStorage");
  const zkpStorage = await ZKPStorage.attach(zkpStorageAddress);

  const result = await zkpStorage.verifyMyProof();
  console.log("Verification result:", result);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});