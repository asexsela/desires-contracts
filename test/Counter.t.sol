// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";

contract CounterTest is Test {
    uint public counter;

    function test_Increment() public {
        counter += 1;
        assertEq(counter, 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        counter = x;
        assertEq(counter, x);
    }
}
