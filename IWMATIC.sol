// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

interface WrappedMaticInterface {

    function deposit() external payable;

    function withdraw(uint wad) external;
    
    function transfer(address dst, uint wad) external returns (bool);
    
}
