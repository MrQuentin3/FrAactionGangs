// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

/**
 * @title FrAaction Interface
 * @author Quentin for FrAaction Gangs
 */

interface FrAactionInterface{

function openForBid() public view returns(bool);

function livePrice() external returns(uint256);

function getAssets() public view returns (Asset[] memory);

function getDemergeAssets(uint256 _idsToDemerger) public view returns (uint256[] memory);

function getOwners() public view returns (address[] memory);

function getOwnerStake(address _stakeContributor) public view returns (uint256[] memory);

function getStakeContribution(address _contributor, uint256 _tokenId) public view returns (StakeContribution[] memory);

}