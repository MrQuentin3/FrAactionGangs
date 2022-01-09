// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

/**
 * @title FrAactionFactory
 * @author Quentin for FrAaction Gangs
 */

import {
    InitializedProxy
} from "./InitializedProxy.sol";
import {
    FraactionHub
} from "./FrAactionHub.sol";

//pausable

contract FraactionFactory {
    //======== Events ========

    event FraactionDeployed(
        address fraactionProxy,
        address creator,
        string name,
        string symbol,
        address demergeFrom,
        address gangAddress
    );

    //======== Immutable storage =========

    address public immutable logic;

    //======== Constructor =========

    constructor(
    ) {
        // deploy logic contract
        FraactionHub _logicContract = new FraactionHub();
        // store logic contract address
        logic = address(_logicContract);
    }

    //======== Deploy function =========

    function startFraactionHub(
        string calldata _name,
        string calldata _symbol,
        address _demergeFrom
    ) external returns (address fraactionProxy) {
        bytes memory _initializationCalldata =
            abi.encodeWithSignature(
                "initialize(
                    string,
                    string,
                    address,
                    address
                )",
                _name,
                _symbol,
                _demergeFrom,
                _gangAddress
            );
        fraactionProxy = address(
            new InitializedProxy(
                logic,
                _initializationCalldata
            )
        );
        (bool success, bytes memory returnData) = 
            settingsContract.call(abi.encodeWithSignature("registerNewFrAactionHub(address)", fraactionProxy));
        require(
            success,
            string(
                abi.encodePacked(
                    "startFraactionHub: registering FrAactionHub failed: ",
                    returnData
                )
            )
        );
        emit FraactionDeployed(
            fraactionProxy,
            msg.sender,
            _name,
            _symbol,
            _demergeFrom
            _gangAddress
        );
    }
}
