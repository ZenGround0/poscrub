// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {PoScrub} from "../src/PoScrub.sol";

contract PoScrubTest is Test {
    PoScrub public scrub;

    function setUp() public {
        bytes32 twoThirdsMeasurement = hex"eb5c02d3ba319e65218994fc47925cf8a5e9a433081c44d4d989434f15a7c6d7";
        bytes16 oneThirdMeasurement = hex"15d302401b3147da04e49abc99e50aea";
        scrub = new PoScrub(twoThirdsMeasurement, oneThirdMeasurement);
    }

    event measurement(bytes32 word1, bytes16 word2);

    function testAttestationSignatureVerification() public {
        bytes
            memory attestation = hex"020000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000010000000100000003000000000016d5030000000000000004000000000000008bc0d70e311292982e52c0182b0cd50d025f7e78d5077d12d6d4e002b11b0b39919f0c7f40c36189ad67661e7f2e10a4503a5af4cd227ff49e37024f73c8d238eb5c02d3ba319e65218994fc47925cf8a5e9a433081c44d4d989434f15a7c6d715d302401b3147da04e49abc99e50aea000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020df0e0dc68456284ddd77d540f78959ea940251cf565fc9493973023ffaed89ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff03000000000016d30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000000000016d5143701001437010003000000000016d50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006089f0dfb01d1ef5eabd3d6fb302031d684436e145ea907b8931a9ec1f489ab13adeebc5134125583568e2a8680a00b9000000000000000000000000000000000000000000000000e891511a4550585b9ae7e6ae5f1ee09c4361455a2541438afb22287e70e9657c08bb6841465eb9e58457491c306350ad0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";

        bytes
            memory signature = hex"6089f0dfb01d1ef5eabd3d6fb302031d684436e145ea907b8931a9ec1f489ab13adeebc5134125583568e2a8680a00b9e891511a4550585b9ae7e6ae5f1ee09c4361455a2541438afb22287e70e9657c08bb6841465eb9e58457491c306350ad"; // Sample signature
        bytes
            memory pubKey = hex"04d5af8f6ac8b7fc71f386de65aaf1a3790dfeee41b49e7f48c3a1a9b33a7a13bcab89e600a809101be84cafdd3b4d5691ddc2cfb39ad692ea585ec849bf7efcad40c31e733f02901ac9f694a934ec3ab91ced45b0ec56c84fd0b0cdc47f03c8a3"; // Sample public key

        bool result = scrub.verifyAttestationForSEVSN(
            attestation,
            signature,
            pubKey
        );
        assertTrue(result, "Attestation verification failed");
    }

    function testReadMeasurement() public {
        bytes
            memory attestation = hex"020000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000010000000100000003000000000016d5030000000000000004000000000000008bc0d70e311292982e52c0182b0cd50d025f7e78d5077d12d6d4e002b11b0b39919f0c7f40c36189ad67661e7f2e10a4503a5af4cd227ff49e37024f73c8d238eb5c02d3ba319e65218994fc47925cf8a5e9a433081c44d4d989434f15a7c6d715d302401b3147da04e49abc99e50aea000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020df0e0dc68456284ddd77d540f78959ea940251cf565fc9493973023ffaed89ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff03000000000016d30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000000000016d5143701001437010003000000000016d50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006089f0dfb01d1ef5eabd3d6fb302031d684436e145ea907b8931a9ec1f489ab13adeebc5134125583568e2a8680a00b9000000000000000000000000000000000000000000000000e891511a4550585b9ae7e6ae5f1ee09c4361455a2541438afb22287e70e9657c08bb6841465eb9e58457491c306350ad0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";

        (bytes32 w1, bytes16 w2) = scrub.extractMeasurement(attestation);
        emit measurement(w1, w2);

        // Assert first 32 bytes match expected measurement
        require(
            w1 == scrub.twoThirdsMeasurement(),
            "First 32 bytes of measurement do not match"
        );

        // Assert last 16 bytes match expected measurement
        require(
            w2 == scrub.oneThirdMeasurement(),
            "Last 16 bytes of measurement do not match"
        );
    }
}
