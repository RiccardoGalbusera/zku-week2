//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {PoseidonT3} from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        hashes = new uint256[](15);
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        hashes[index] = hashedLeaf;
        uint256 supIndex = 0;
        for (uint8 level = 0; level < 3; level++) {
            supIndex += 2**(3 - level) + index / 2;
            if (index % 2 == 0) {
                hashes[supIndex] = PoseidonT3.poseidon(
                    [hashes[index], hashes[index + 1]]
                );
            } else {
                hashes[supIndex] = PoseidonT3.poseidon(
                    [hashes[index - 1], hashes[index]]
                );
            }
        }
        index++;
        return hashes[supIndex];
    }

    function verify(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[1] memory input
    ) public view returns (bool) {
        // [assignment] verify an inclusion proof and check that the proof root matches current root
        return Verifier.verifyProof(a, b, c, input);
    }
}
