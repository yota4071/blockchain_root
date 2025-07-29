// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Verifier {
    struct G1Point {
        uint X;
        uint Y;
    }

    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }

    function pairing(
        G1Point[] memory p1,
        G2Point[] memory p2
    ) internal view returns (bool) {
        require(p1.length == p2.length, "Input lengths do not match");
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);

        for (uint i = 0; i < elements; i++) {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }

        uint[1] memory out;
        bool success;
        assembly {
            success := staticcall(
                gas(),
                8,
                add(input, 0x20),
                mul(inputSize, 0x20),
                out,
                0x20
            )
        }
        require(success, "pairing failed");
        return out[0] != 0;
    }

    // ==== 入力に応じて置き換える ====
    // 固定された verification key
    // あなたのプロジェクト用のα, β, γ, δ, ICに置き換える必要があります
    struct VerifyingKey {
        G1Point alfa1;
        G2Point beta2;
        G2Point gamma2;
        G2Point delta2;
        G1Point[] IC;
    }

    struct Proof {
        G1Point A;
        G2Point B;
        G1Point C;
    }

    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alfa1 = G1Point(<uint>, <uint>);
        vk.beta2 = G2Point([<uint>, <uint>], [<uint>, <uint>]);
        vk.gamma2 = G2Point([<uint>, <uint>], [<uint>, <uint>]);
        vk.delta2 = G2Point([<uint>, <uint>], [<uint>, <uint>]);
        vk.IC = new G1Point ; // 入力数+1に応じて変更
        vk.IC[0] = G1Point(<uint>, <uint>);
        vk.IC[1] = G1Point(<uint>, <uint>);
    }

    function verifyProof(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[] memory input
    ) public view returns (bool) {
        Proof memory proof;
        proof.A = G1Point(a[0], a[1]);
        proof.B = G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.C = G1Point(c[0], c[1]);

        VerifyingKey memory vk = verifyingKey();

        // input check
        require(input.length + 1 == vk.IC.length, "Bad input length");

        // vk_xの計算
        G1Point memory vk_x = vk.IC[0];
        for (uint i = 0; i < input.length; i++) {
            // 加算: vk_x = vk_x + input[i] * vk.IC[i + 1]
            // ここはライブラリかプリコンパイルの拡張が必要だが省略
        }

        // pairing check
        return pairing(
            [proof.A, negate(vk_x), proof.C],
            [proof.B, vk.gamma2, vk.delta2]
        );
    }

    function negate(G1Point memory p) internal pure returns (G1Point memory) {
        if (p.X == 0 && p.Y == 0) return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }

    uint constant q = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
}