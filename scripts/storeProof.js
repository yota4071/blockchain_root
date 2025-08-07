const hre = require("hardhat");
const fs = require("fs");

async function main() {
  // デプロイ済みコントラクトアドレス
  const zkpStorageAddress = "0x5FC8d32690cc91D4c39d9d3abcBD16989F875707";

  // サインナーを明示的に取得（store と verify が同じアドレスで動くように）
  const [signer] = await hre.ethers.getSigners();
  console.log("Using signer:", await signer.getAddress());

  // コントラクト接続
  const ZKPStorage = await hre.ethers.getContractFactory("ZKPStorage", signer);
  const zkpStorage = await ZKPStorage.attach(zkpStorageAddress);

  // proof.json と public.json を読み込み
  const proof = JSON.parse(fs.readFileSync("./proof/proof.json"));
  const pub = JSON.parse(fs.readFileSync("./proof/public.json"));

  

  // snarkjsのproof.jsonの形式に合わせて分解（Solidity順に変換）
  const a = [
    BigInt(proof.pi_a[0]),
    BigInt(proof.pi_a[1])
  ];

  const b = [
    // snarkjsのproof.jsonから正しい順序で取得（最初の2要素のみ使用）
    [BigInt(proof.pi_b[0][1]), BigInt(proof.pi_b[0][0])],
    [BigInt(proof.pi_b[1][1]), BigInt(proof.pi_b[1][0])]
  ];

  const c = [
    BigInt(proof.pi_c[0]),
    BigInt(proof.pi_c[1])
  ];

  // 公開入力は配列で渡す（固定長[1]に対応させる）
  const inputValue = BigInt(pub[0]);

  console.log("Storing proof on blockchain...");
  const tx = await zkpStorage.storeProof(a, b, c, inputValue);
  await tx.wait();

  console.log(" Proof stored on blockchain");

  // 確認用にコントラクトに保存された Proof を取得
  const storedProof = await zkpStorage.getMyProof();
  console.log("Stored Proof in contract:", storedProof);
  console.log("✅ Stored a:", storedProof.a.map(v => v.toString()));
  console.log("✅ Stored b:", storedProof.b.map(arr => arr.map(v => v.toString())));
  console.log("✅ Stored c:", storedProof.c.map(v => v.toString()));
  console.log("✅ Stored input:", storedProof.input.map(v => v.toString()));
}
  

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});