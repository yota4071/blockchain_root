// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Verifier.sol";

contract ZKPStorage {
    Groth16Verifier public verifier;

    constructor(address _verifier) {
        verifier = Groth16Verifier(_verifier);
    }

    struct Proof {
        uint[2] a;
        uint[2][2] b;
        uint[2] c;
        uint[1] input; // 固定長配列
    }

    mapping(address => Proof) private proofs;

    function storeProof(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint inputValue
    ) public {
        proofs[msg.sender] = Proof(a, b, c, [inputValue]);
    }

    function verifyMyProof() public view returns (bool) {
        Proof memory p = proofs[msg.sender];
        return verifier.verifyProof(p.a, p.b, p.c, p.input);
    }

    // 追加: getterが必要ならこうする
    function getMyProof() public view returns (
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[1] memory input
    ) {
        Proof memory p = proofs[msg.sender];
        return (p.a, p.b, p.c, p.input);
    }
}