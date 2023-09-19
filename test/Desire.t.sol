// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import {IEntryPoint} from "account-abstraction/interfaces/IEntryPoint.sol";
import {DesireFactory} from  "../src/DesireFactory.sol";
import {Desire} from  "../src/Desire.sol";
import {Test, console2} from "forge-std/Test.sol";
import {UserOperation} from "account-abstraction/interfaces/UserOperation.sol";


contract DesireTest is Test {

    IEntryPoint constant ENTRYPOINT = IEntryPoint(0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789);
    address constant TO_ADDRESS = address(1111); // 0x0000000000000000000000000000000000000457

    DesireFactory public factory;
    Desire public desire;

    uint256 public salt;
    address[] public signers;

    function setUp() public {
        factory = new DesireFactory(ENTRYPOINT); // 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f
        signers.push(address(1234)); // 0x00000000000000000000000000000000000004d2
        signers.push(address(12345)); // 0x0000000000000000000000000000000000003039

        salt = uint256(1);

        desire = factory.createDesire(signers, salt);
    }

    // проверяем signers
    function test_check_signers() public {
        address signer1 = desire.signers(0);
        address signer2 = desire.signers(1);

        assertEq(signers[0], signer1);
        assertEq(signers[1], signer2);
    }

    // проверяем factory
    function test_check_factory_address() public {
        assertEq(address(factory), desire.desireFactory());
    }

    // проверяем entryPoint
    function test_check_entry_point() public {
        assertEq(address(ENTRYPOINT), address(desire.entryPoint()));
    }

    // проверяем initialize once
    function test_check_initialize_once() public {
        (bool success,) = address(desire).call(
            abi.encodeWithSignature("initialize(address[])", new address[](0))
        );

        assertFalse(success);
    }

    // проверяем _validateSignature
    function test_check_validate_signatures() public {
//        string memory callData = bytes(0xb61d27f600000000000000000000000000000000000000000000000000000000000004570000000000000000000000000000000000000000000000000de0b6b3a764000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000);
//
//        UserOperation storage userOp = UserOperation(
//            desire.signers(0),
//            desire.getNonce(),
//            bytes(0),
//            callData,
//            100000,
//            2000000,
//            100000,
//            94,
//            70,
//            bytes(0),
//            bytes(0x00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000)
//        );
    }


}
