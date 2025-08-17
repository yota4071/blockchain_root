const hre = require("hardhat");
const fs = require("node:fs");

async function main() {
  const VERIFIER_ADDRESS = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
  
  // Read proof and public signals directly from JSON files
  console.log("Reading proof.json and public.json...");
  
  const proof = JSON.parse(fs.readFileSync("./proof/proof.json", "utf8"));
  const publicSignals = JSON.parse(fs.readFileSync("./proof/public.json", "utf8"));
  
  // Convert pi_a, pi_b, pi_c to the format expected by Solidity verifier
  // Try using decimal strings directly (no hex conversion)
  
  // pi_a: [x, y, z] -> [x, y] (remove z coordinate)
  const a = [proof.pi_a[0], proof.pi_a[1]];
  
  // pi_b: [[x1, x2], [y1, y2], [z1, z2]] -> [[x1, x2], [y1, y2]] (remove z coordinates)
  // Note: snarkjs reverses the order for pi_b elements
  const b = [
    [proof.pi_b[0][1], proof.pi_b[0][0]],
    [proof.pi_b[1][1], proof.pi_b[1][0]]
  ];
  
  // pi_c: [x, y, z] -> [x, y] (remove z coordinate)
  const c = [proof.pi_c[0], proof.pi_c[1]];
  
  console.log("\nParsed calldata from proof files:");
  console.log("a:", a);
  console.log("b:", b);
  console.log("c:", c);
  console.log("publicSignals:", publicSignals);
  
  // Get the deployed verifier contract
  const verifier = await hre.ethers.getContractAt("Groth16Verifier", VERIFIER_ADDRESS);
  
  console.log("\nCalling verifyProof on-chain...");
  
  try {
    // Call verifyProof with public signals
    const result = await verifier.verifyProof(a, b, c, publicSignals);
    
    console.log("\n==========================================");
    if (result) {
      console.log("✅ VERIFICATION SUCCESSFUL!");
      console.log("The zero-knowledge proof has been successfully verified on-chain!");
    } else {
      console.log("❌ VERIFICATION FAILED");
      console.log("The proof verification failed.");
    }
    console.log("==========================================\n");
    
  } catch (error) {
    console.error("Error during verification:", error);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });