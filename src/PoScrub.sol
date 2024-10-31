// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {NitroProver} from "lib/NitroProver/src/NitroProver.sol";

contract PoScrub is NitroProver {
    bytes32 public twoThirdsMeasurement;
    bytes16 public oneThirdMeasurement;

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

    function verifyAttestationForSEVSN(
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
}
