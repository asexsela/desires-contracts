// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import {IEntryPoint} from "account-abstraction/interfaces/IEntryPoint.sol";
import {BaseAccount} from "account-abstraction/core/BaseAccount.sol";
import {UserOperation} from "account-abstraction/interfaces/UserOperation.sol";
import {ECDSA} from "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import {Initializable} from "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";
import {TokenCallbackHandler} from "account-abstraction/samples/callback/TokenCallbackHandler.sol";

contract Desire is
    BaseAccount,
    Initializable,
    UUPSUpgradeable,
    TokenCallbackHandler
{
    using ECDSA for bytes32;
    address[] public signers;

    bool public locked;

    address public immutable desireFactory;
    IEntryPoint private immutable _entryPoint;

    event DesireInitialized(IEntryPoint indexed entryPoint, address[] signers);

    modifier _requireFromEntryPointOrFactory() {
        require(
            msg.sender == address(entryPoint()) || msg.sender == desireFactory,
            "only entry point or desire factory can call"
        );
        _;
    }

    modifier onlyOwner() {
        require(
            msg.sender == signers[1],
            "only owner can do this"
        );
        _;
    }

    constructor(IEntryPoint myEntryPoint, address _desireFactory) {
        _entryPoint = myEntryPoint;
        desireFactory = _desireFactory;
        locked = true;
        _disableInitializers();
    }

    function entryPoint() public view override returns (IEntryPoint) {
        return _entryPoint;
    }

    function initialize(address[] memory initialSigners) public initializer {
        _initialize(initialSigners);
    }

    function execute(
        address dest,
        uint256 value,
        bytes calldata func
    ) external _requireFromEntryPointOrFactory {
        _call(dest, value, func);
    }

    function executeBatch(
        address[] calldata dests,
        uint256[] calldata values,
        bytes[] calldata funcs
    ) external _requireFromEntryPointOrFactory {
        require(dests.length == funcs.length, "wrong dests lengths");
        require(values.length == funcs.length, "wrong values lengths");
        for (uint256 i = 0; i < dests.length; i++) {
            _call(dests[i], values[i], funcs[i]);
        }
    }

    function _initialize(address[] memory initialSigners) internal {
        require(initialSigners.length > 0, "no signers");
        signers = initialSigners;
        emit DesireInitialized(_entryPoint, initialSigners);
    }

    function _validateSignature(
        UserOperation calldata userOp,
        bytes32 userOpHash
    ) internal view override returns (uint256) {
        bytes32 hash = userOpHash.toEthSignedMessageHash();
        bytes[] memory signatures = abi.decode(userOp.signature, (bytes[]));

        for (uint256 i = 0; i < signers.length; i++) {
            if (signers[i] != hash.recover(signatures[i])) {
                return SIG_VALIDATION_FAILED;
            }
        }

        return 0;
    }

    function _call(address target, uint256 value, bytes memory data) internal {
        (bool success, bytes memory result) = target.call{value: value}(data);
        if (!success) {
            assembly {
            // The assembly code here skips the first 32 bytes of the result, which contains the length of data.
            // It then loads the actual error message using mload and calls revert with this error message.
                revert(add(result, 32), mload(result))
            }
        }
    }

    // @dev helpers
    function _authorizeUpgrade(
        address newImplementation
    ) internal view override _requireFromEntryPointOrFactory {}

    function encodeSignatures(
        bytes[] memory signatures
    ) public pure returns (bytes memory) {
        return abi.encode(signatures);
    }

    function getDeposit() public view returns (uint256) {
        return entryPoint().balanceOf(address(this));
    }

    function addDeposit() public payable {
        entryPoint().depositTo{value: msg.value}(address(this));
    }

    function withdrawDepositTo(address payable withdrawAddress, uint256 amount) public onlyOwner {
        // TODO: расчет и вывод комиссии
        entryPoint().withdrawTo(withdrawAddress, amount);
    }

    receive() external payable {}
}
