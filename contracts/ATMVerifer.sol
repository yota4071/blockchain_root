// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Verifier.sol";

contract ZKPStorage {
    Verifier public verifier;

    constructor(address _verifier) {
        verifier = Verifier(_verifier);
    }

    // =========================
    // 1. Proof構造体の定義
    // =========================
    struct Proof {
        uint[2] a;
        uint[2][2] b;
        uint[2] c;
        uint[] input;
    }

    // =========================
    // 2. アドレスごとにProof保存
    // =========================
    mapping(address => Proof) public proofs;

    function storeProof(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[] memory input
    ) public {
        proofs[msg.sender] = Proof(a, b, c, input);
    }

    // =========================
    // 3. 自分のProofを検証
    // =========================
    function verifyMyProof() public view returns (bool) {
        Proof memory p = proofs[msg.sender];
        return verifier.verifyProof(p.a, p.b, p.c, p.input);
    }

    // =========================
    // 4. オンチェーンに保存された verification key
    //    → 読み取り専用（デプロイ時に書き込む）
    // =========================
    struct VerificationKey {
        uint256[] alpha;
        uint256[][] beta;
        uint256[] gamma;
        uint256[][] delta;
        uint256[] ic; // 一般的に公開入力に対応
    }

    VerificationKey public vk;

    function setVerificationKey(
        uint256[] memory _alpha,
        uint256[][] memory _beta,
        uint256[] memory _gamma,
        uint256[][] memory _delta,
        uint256[] memory _ic
    ) public {
        // 必要なら onlyOwner に制限
        vk = VerificationKey(_alpha, _beta, _gamma, _delta, _ic);
    }

    function getVerificationKey() public view returns (VerificationKey memory) {
        return vk;
    }
}