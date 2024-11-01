// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {NitroProver} from "lib/NitroProver/src/NitroProver.sol";

contract PoScrub is NitroProver {
    bytes32 public twoThirdsMeasurement;
    bytes16 public oneThirdMeasurement;
    mapping(bytes32 => bytes32) public shaToCommp;

    constructor(bytes32 _twoThirdsMeasurement, bytes16 _oneThirdMeasurement) {
        twoThirdsMeasurement = _twoThirdsMeasurement;
        oneThirdMeasurement = _oneThirdMeasurement;
    }

    function extractMeasurement(
        bytes memory attestation
    ) public returns (bytes32, bytes16) {
        // Ensure the data is long enough to contain the measurement field
        require(
            attestation.length >= 192,
            "Data too short for AttestationReport"
        );

        bytes32 word1;
        bytes16 word2;
        assembly {
            // The `data` bytes array has a 32-byte length prefix.
            // The actual data starts at `add(data, 32)`.
            // The `measurement` field starts at byte offset 144.
            // Therefore, the starting memory position is 32 + 144 = 176 bytes.

            let ptr := add(attestation, 176)

            // Load the first 32 bytes of the measurement
            word1 := mload(ptr)

            // Load the next 16 bytes of the measurement
            word2 := mload(add(ptr, 32))
        }
        return (word1, word2);
    }

    // Check that 
    // 1. the measurement correctly validates the computing environment doing signing
    // 2. the signature 
    function verifyAttestationForSEVSNP(
        bytes memory attestation,
        bytes memory signature,
        bytes memory pubKey
    ) public returns (bool) {
        // extract and match measurment
        (bytes32 word1, bytes16 word2) = extractMeasurement(attestation);
        require(word1 == twoThirdsMeasurement, "Measurement mismatch");
        require(word2 == oneThirdMeasurement, "Measurement mismatch");

        _processSignature(signature, pubKey, attestation);
        return true;
    }

    function merkleAssociate(bytes memory attestation) public {
        verifyAttestationForSEVSNP(attestation, signature, pubKey);
        // TODO implement extractReport, its just extractMeasurement but with a different offset
        bytes report = extractReport(attestation);
        
        bytes32 commp;
        bytes32 sha;
        assembly {
            let ptr := add(report, 32)
            // Load first 32 bytes as commp
            commp := mload(ptr)
            // Load next 32 bytes as sha
            sha := mload(add(ptr, 32))
        }
        shaToCommp[sha] = commp;
    }

    address constant RANDOMNESS_PRECOMPILE = 0xfE00000000000000000000000000000000000006;
    function getRandomness(uint64 epoch) public view returns (bytes32) {
        // Prepare the input data (epoch as a uint256)
        uint256 input = uint256(epoch);

        // Call the precompile
        (bool success, bytes memory result) = RANDOMNESS_PRECOMPILE.staticcall(abi.encodePacked(input));

        // Check if the call was successful
        require(success, "Randomness precompile call failed");

        // Decode and return the result
        return abi.decode(result, (bytes32));
    }

    // Proof recency of scrub
    function recentScrub(bytes memory attestation, uint256 epoch, bytes memory commp) public {
        verifyAttestationForSEVSNP(attestation, signature, pubKey);
        require(epoch < block.number - 20160, "Epoch must be from within the last week");

        bytes report = extractReport(attestation);
        bytes32 drand;
        bytes32 sha;
        assembly {
            let ptr := add(report, 32)
            // Load first 32 bytes as commp
            drand := mload(ptr)
            // Load next 32 bytes as sha
            sha := mload(add(ptr, 32))
        }
        require(shaToCommp[sha] == commp, "Measurement mismatch");
        bytes32 measuredDrand = getRandomness(epoch);
        require(drand == measuredDrand, "Drand mismatch");
    }
}
