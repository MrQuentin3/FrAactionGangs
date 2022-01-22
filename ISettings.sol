//SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

interface ISettings {

    function maxAuctionLength() external returns(uint256);

    function minAuctionLength() external returns(uint256);
    
    function playerFee() external returns(uint256);

    function maxPlayerFee() external returns(uint256);

    function governanceFee() external returns(uint256);

    function minBidIncrease() external returns(uint256);

    function minVotePercentage() external returns(uint256);

    function maxReserveFactor() external returns(uint256);

    function minReserveFactor() external returns(uint256);
    
    function minPlayerVotePercentage() external returns(uint256);
    
    function maxNumberDaysFunding() external returns(uint256);
    
    function minNumberDaysFunding() external returns(uint256);

    function fundingFee() external returns(uint256);
    
    function maxNumberDaysAavegotchiFunding() external returns(uint256);
    
    function minNumberDaysAavegotchiFunding() external returns(uint256);

    function feeReceiver() external returns(address);
    
    function minLengthVotePercentage() external returns(uint256);
    
    function minPlayerFeeVotePercentage() external returns(uint256);
    
    function minTypeVotePercentage() external returns(uint256);
    
    function minAavegotchiVotePercentage() external returns(uint256);
    
    function minOpenVotePercentage() external returns(uint256);
    
    function minDestroyVotePercentage() external returns(uint256);
    
    function minNameVotePercentage() external returns(uint256);
    
    function maxNftsArrayLength() external returns(uint256);
    
    function maxOwnersArrayLength() external returns(uint256);

    function fraactionFactoryContract() external returns(address);
    
    function feesRewardTrigger() external returns(uint256);
    
    function feesReward() external returns(uint256);
    
    function auctionLength() external returns(uint256);

    function collateralTypeIntoGhst(address _collateralType) external returns (uint256 ghstRate_);

}