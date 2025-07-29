const hre = require("hardhat");

async function main() {
  const Verifier = await hre.ethers.getContractFactory("Verifier");
  const verifier = await Verifier.deploy();
  await verifier.deployed();

  console.log("Verifier deployed to:", verifier.address);

  const ZKPStorage = await hre.ethers.getContractFactory("ZKPStorage");
  const zkpStorage = await ZKPStorage.deploy(verifier.address);
  await zkpStorage.deployed();

  console.log("ZKPStorage deployed to:", zkpStorage.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});