// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import {IEntryPoint} from "account-abstraction/interfaces/IEntryPoint.sol";
import {DesireFactory} from  "../src/DesireFactory.sol";
import {Desire} from  "../src/Desire.sol";
import {Test, console2} from "forge-std/Test.sol";

contract DesireFactoryTest is Test {

    IEntryPoint constant ENTRYPOINT = IEntryPoint(0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789);
    address constant TEST_ADDRESS = 0xFf34BecC2A0AE4cc106Fd034758b8EE59cE76BA7;

    DesireFactory public factory;

    uint256 public salt;
    address[] public signers;

    function setUp() public {
        factory = new DesireFactory(ENTRYPOINT); // 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f

        signers.push(address(1234)); // 0x00000000000000000000000000000000000004d2
        signers.push(address(12345)); // 0x0000000000000000000000000000000000003039

        salt = uint256(1);
    }

    // проверяем правильный адрес
    function test_check_get_desire() public {
        address desire = factory.getAddress(signers, salt);

        assertEq(desire, TEST_ADDRESS);
    }

    // проверяем создание адреса
    function test_check_create_desire() public {
        Desire desire = factory.createDesire(signers, salt);

        assertEq(address(desire), TEST_ADDRESS);
    }

    // сравниваем что без создания с адресом создания desire
    function test_check_create_desire_and_create_address() public {
        address desire_address = factory.getAddress(signers, salt);
        Desire desire = factory.createDesire(signers, salt);

        assertEq(address(desire), desire_address);
    }

    // проверяем адрес desire объявленный в конструкторе factory
    function test_check_desire_implementation_address() public {
        assertEq(address(factory.desireImplementation()), address(0x104fBc016F4bb334D775a19E8A6510109AC63E00));
    }

    // проверяем что адрес приходит не верный (с другой солью)
    function test_check_get_desire_with_different_salt() public {
        address desire = factory.getAddress(signers, 2);
        assertFalse(desire == TEST_ADDRESS);
    }

    function test_check_create_desire_and_different_create_address() public {
        address desire_address = factory.getAddress(signers, salt);
        Desire desire = factory.createDesire(signers, 2);

        assertFalse(address(desire) == desire_address);
    }

}
