// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "../lib/reactive-lib/src/interfaces/IReactive.sol";
import "../lib/reactive-lib/src/abstract-base/AbstractReactive.sol";
import "../lib/reactive-lib/src/interfaces/ISystemContract.sol";

contract StreakSystemReactive is IReactive, AbstractReactive {
    uint256 public originChainId;
    uint256 public destinationChainId;
    address private callback;
    uint64 private constant CALLBACK_GAS_LIMIT = 1000000;
    uint256 private constant EARNEDNFT_TOPIC_0 =
        0x57958548394d02387e4204984f7d693567c1fd729fe1ed83ae8b233332e7319e;

    constructor(
        address _service,
        uint256 _originChainId,
        uint256 _destinationChainId,
        address _contract,
        address _callback
    ) payable {
        service = ISystemContract(payable(_service));

        originChainId = _originChainId;
        destinationChainId = _destinationChainId;
        callback = _callback;

        if (!vm) {
            service.subscribe(
                originChainId,
                _contract,
                EARNEDNFT_TOPIC_0,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE,
                REACTIVE_IGNORE
            );
        }
    }

    function react(LogRecord calldata log) external vmOnly {
        bytes memory payload = abi.encodeWithSignature(
            "callback(address,address,uint256)",
            address(0),
            address(uint160(log.topic_1)),
            log.topic_2
        );
        emit Callback(
            destinationChainId,
            callback,
            CALLBACK_GAS_LIMIT,
            payload
        );
    }
}
