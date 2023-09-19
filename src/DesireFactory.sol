// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import {Desire} from "./Desire.sol";
import {ERC1967Proxy} from "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IEntryPoint} from "account-abstraction/interfaces/IEntryPoint.sol";
import {Create2} from "openzeppelin-contracts/contracts/utils/Create2.sol";

contract DesireFactory {
    Desire public immutable desireImplementation;

    constructor(IEntryPoint entryPoint) {
        desireImplementation = new Desire(entryPoint, address(this));
    }

    function getAddress(
        address[] memory signers,
        uint256 salt
    ) public view returns (address) {
        bytes memory desireInit = abi.encodeCall(Desire.initialize, signers);
        bytes memory proxyConstructor = abi.encode(
            address(desireImplementation),
            desireInit
        );
        bytes memory bytecode = abi.encodePacked(
            type(ERC1967Proxy).creationCode,
            proxyConstructor
        );
        bytes32 bytecodeHash = keccak256(bytecode);

        return Create2.computeAddress(bytes32(salt), bytecodeHash);
    }

    function createDesire(
        address[] memory signers,
        uint256 salt
    ) external returns (Desire) {
        address addr = getAddress(signers, salt);
        uint256 codeSize = addr.code.length;
        if (codeSize > 0) {
            return Desire(payable(addr));
        }

        bytes memory desireInit = abi.encodeCall(Desire.initialize, signers);
        ERC1967Proxy proxy = new ERC1967Proxy{salt: bytes32(salt)}(
            address(desireImplementation),
            desireInit
        );

        return Desire(payable(address(proxy)));
    }
}
