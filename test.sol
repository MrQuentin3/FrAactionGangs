// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

/**
 * @title FrAactionSPDAO
 * @author Quentin for FrAaction Gangs
 */
 
// ============ Internal Import ============

import {
    ISettings
} from "./GovSettings.sol";

// ============ External Imports: Inherited Contracts ============

// NOTE: we inherit from OpenZeppelin upgradeable contracts because of the proxy implementation of this logic contract

import {
    IERC721Upgradeable
} from "@OpenZeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import {
    ERC721HolderUpgradeable
} from "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import {
    ERC1155HolderUpgradeable
} from "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import {
    IERC1155Upgradeable
} from "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import {
    ERC20Upgradeable
} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {
    ERC20lib
} from "./interfaces/ERC20lib.sol";
import {
    DiamondInterface
} from "./DiamondInterface.sol";
 
contract FraactionSPDAO is ERC20Upgradeable, ERC721HolderUpgradeable, ERC1155HolderUpgradeable {

    using Address for address;
 
    // ============ Enums ============
    
    // State Transitions:
    //   (1) INACTIVE on deploy
    //   (2) FUNDING on startFunding()
    //   (3) PURCHASED on purchase()
    //   (4) COMPLETED, FRACTIONALIZED and FAILED on finalize()
    enum fundingStatus {
        INACTIVE,
        FUNDING,
        PURCHASED,
        COMPLETED,
        FRACTIONALIZED,
        FAILED
    }
    
    // funding round status of the FrAactionHub
    FundingStatus public fundingStatus;
    
    // State Transitions:
    //   (1) INACTIVE on deploy
    //   (2) ACTIVE on startAuction()
    //   (3) ENDED on endAuction() or redeem()
    enum finalAuctionStatus { 
        INACTIVE, 
        ACTIVE, 
        ENDED 
    }

    FinalAuctionStatus public finalAuctionStatus;
    
    // State Transitions:
    //   (1) INACTIVE or ACTIVE on deploy
    //   (2) BIDSUBMITTED, ENDED or FAILED on finalizeBid()
    enum auctionStatus { 
        INACTIVE, 
        ACTIVE,
        BIDSUBMITTED,
        ENDED, 
        FAILED
    }

    AuctionStatus public auctionStatus;
    
    // State Transitions:
    //   (1) INACTIVE on deploy
    //   (2) ACTIVE on initiateMerger() and voteForMerger(), ASSETSTRANSFERRED on voteForMerger()
    //   (3) MERGED or POSTMERGERLOCKED on finalizeMerger()
    enum MergerStatus { 
        INACTIVE, 
        ACTIVE,
        ASSETSTRANSFERRED,
        MERGED,
        POSTMERGERLOCKED
    }
    
    MergerStatus public mergerStatus;
    
    // State Transitions:
    //   (1) INACTIVE or INITIALIZED on deploy
    //   (2) ACTIVE on voteForDemerger()
    //   (4) ASSETSTRANSFERRED on DemergeAssets()
    //   (4) DEMERGED on finalizeDemerger()
    enum DemergerStatus { 
        INACTIVE, 
        ACTIVE,
        INITIALIZED,
        ASSETSTRANSFERRED,
        DEMERGED
    }
    
    DemergerStatus public demergerStatus;
    
     // State Transitions:
    //   (1) INACTIVE on deploy
    //   (2) FUNDING on startAavegotchiFunding()
    //   (3) CLAIMED on claimAavegotchi()
    //   (4) COMPLETED, FRACTIONALIZED and FAILED on finalizeAavegotchi()
    enum PortalStatus {
        INACTIVE,
        FUNDING,
        CLAIMED,
        COMPLETED,
        FRACTIONALIZED,
        FAILED
    }
    
    PortalStatus public portalStatus;
    
    // ============ Public Constant ============
    
    // version of the FrAactionHub smart contract
    uint256 public constant contractVersion = 1;
    
    // ============ Internal Constants ============

    // tokens are minted at a rate of 1 GHST : 100 tokens
    uint16 internal constant TOKEN_SCALE = 100;
    
    // max integer in hexadecimal format
    uint256 internal constant MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    
    // ============ Internal Mutable Storage ============
    
    // previous FrAactionHub token balance of the receiver
    uint256 internal beforeTransferToBalance;
    
    // stake amount to be decreased in GHST to be burnt 
    uint256 internal decreasedGhst;
    
    // stake amount to be decreased  
    uint256 internal decreasedStake;
    
    // last index of the skill points set array of votedSkill mapping
    uint256 internal skillIndex;
    
    // current number of times the changeFraactionType() function reached the minimum quorum and voted
    uint256 internal typeNumber;
    
    // current number of times the updateAuctionLength() function reached the minimum quorum and voted
    uint256 internal lengthNumber;
    
    // current number of times the updatePlayerFee() function reached the minimum quorum and voted
    uint256 internal feeNumber;
    
    // current number of times the voteForPlayer() function reached the minimum quorum and voted
    uint256 internal playerNumber;
    
    // number of iterations currently done in order to run through the whole ownerAddress array
    uint256 internal splitCounter;
    
    // number of iterations necessary in order to run through the whole ownerAddress array
    uint256 internal multiple;
    
    // number of this item type owned by the FrAactionHub before the purchase
    uint256 internal initialNumberOfItems;
    
    // number of the new funding round
    uint256 internal fundingNumber;
    
    // true if a split is necessary to run through the whole ownerAddress array
    bool internal split;
    
    // voter's address => current votes submitted for the FrAactionHub type change
    mapping(address => uint256) internal currentTypeBalance;
    
    // voter's address => current auction length voted by the owner
    mapping(address => uint256) internal currentLengthVote;
    
    // voter's address => current votes submitted for the auction length update
    mapping(address => uint256) internal currentLengthBalance;

    // voter's address => current player's fee voted by the owner
    mapping(address => uint256) internal currentFeeVote;
    
    // voter's address => current votes submitted for the player's fee update
    mapping(address => uint256) internal currentFeeBalance;
    
    // voter's address => current player voted by the owner
    mapping(address => uint256) internal currentPlayerVote;
    
    // voter's address => current votes submitted for the player appointment
    mapping(address => uint256) internal currentPlayerBalance;
    
    // voter's address => typeNumber of the last time the owner voted
    mapping(address => uint256) internal typeCurrentNumber;
    
    // voter's address => feeNumber of the last time the owner voted
    mapping(address => uint256) internal feeCurrentNumber;
    
    // voter's address => lengthNumber of the last time the owner voted
    mapping(address => uint256) internal lengthCurrentNumber;
    
    // voter's address => current number of times the voteForPlayer() function reached the minimum quorum and voted
    mapping(address => uint256) internal playerCurrentNumber;
    
    // mergerTarget address => current number of times the voteForMerger() function reached the minimum quorum and voted
    mapping(address => uint256) internal mergerNumber;
    
    // contributor address => current number of times the contributor paid the gas fees on behalf of all the FrAactionHub owners
    mapping(address => uint256) internal feesContributor;
    
    // contributor => Aavegotchi funding round number
    mapping(address => uint256[]) internal fundingContributor;
    
    // contributor => tokenId(s) concerned by a stake increase
    mapping(address => uint256[]) internal stakeContributor;
    
    // tokenId => current number of times the voteForName() function reached the minimum quorum and voted
    mapping(uint256 => uint256) internal nameNumber;
    
    // tokenId => current number of times the voteForSkills() function reached the minimum quorum and voted
    mapping(uint256 => uint256) internal skillNumber;
    
    // tokenId => current number of times the voteForDestruction() function reached the minimum quorum and voted
    mapping(uint256 => uint256) internal destroyNumber;
    
    // portal Id => portal funding round number
    mapping(uint256 => uint256) internal portalFundingNumber;
    
    // contributor => last funding index iterated during the last newClaim() call
    mapping(uint256 => uint256) internal lastFundingContributorIndex;
    
    // contributor => last portal index iterated during the last newClaim() call
    mapping(uint256 => uint256) internal lastPortalContributorIndex;
    
    // tokenId => each portal option already voted by at least one owner
    mapping(uint256 => uint256[]) internal votedAavegotchi;
    
    // portal Id => Aavegotchi funding round number
    mapping(uint256 => uint256[]) internal contributorPortalFunding;
    
    // tokenId => each skill points set already voted by at least one owner
    mapping(uint256 => uint256[4][]) internal votedSkill;
    
    // tokenId => each name already voted by at least one owner
    mapping(uint256 => string[]) internal votedName;
    
    // tokenId => true if new funding round is successful
    mapping(uint256 => bool) internal fundingResult;
    
    // portal Id  => funding round number => true if success of the Aavegotchi portal funding round
    mapping(uint256 => mapping(uint256 => bool) internal portalFundingResult;
    
    // voter's address => tokenId => current Aavegotchi option voted by the owner
    mapping(address => mapping(uint256 => uint256)) internal currentAavegotchiVote;
    
    // voter's address => tokenId => current votes submitted by the owner for the Aavegotchi appointment
    mapping(address => mapping(uint256 => uint256)) internal currentAavegotchiBalance;
    
     // voter's address => tokenId => current Aavegotchi skill points set voted by the owner
    mapping(address => mapping(uint256 => uint256)) internal currentSkillVote;
    
    // voter's address => tokenId => current votes submitted by the owner for the Aavegotchi skill points
    mapping(address => mapping(uint256 => uint256)) internal currentSkillBalance;
    
    // voter's address => tokenId => current Aavegotchi name voted by the owner
    mapping(address => mapping(uint256 => string)) internal currentNameVote;
    
    // voter's address => tokenId => current votes submitted by the owner for the Aavegotchi name appointment
    mapping(address => mapping(uint256 => uint256)) internal currentNameBalance;
    
    // voter's address => tokenId => current votes from the contributor for the Aavegotchi destruction
    mapping(address => mapping(uint256 => uint256)) internal currentDestroyBalance;
    
    // voter's address => tokenId => nameNumber of the last time the owner voted
    mapping(address => mapping(uint256 => uint256)) internal nameCurrentNumber;
    
    // voter's address => tokenId => skillNumber of the last time the owner voted
    mapping(address => mapping(uint256 => uint256)) internal skillCurrentNumber;
    
    // voter's address => tokenId => destroyNumber of the last time the owner voted
    mapping(address => mapping(uint256 => uint256)) internal destroyCurrentNumber;
    
    // contributor => tokenId => total amount contributed to the funding round
    mapping(address => mapping(uint256 => uint256)) internal ownerContributedToFunding;
    
    // voter's address => mergerTarget address => mergerNumber of the last time the owner voted
    mapping(address => mapping(address => uint256)) internal mergerCurrentNumber;
    
    // contributor => Aavegotchi funding round portals
    mapping(address => uint256[]) internal portalContributor;
    
    // contributor => tokenId => each collateral stake contribution for the considered Aavegotchi 
    mapping(address => mapping(uint256 => stakeContribution[])) internal ownerStakeContribution;
    
    // contributor => portal Id => portal funding round => contributed collateral 
    mapping(address => mapping(uint256 => mapping(uint256 => uint256))) internal ownerContributedCollateral;
    
    // contributor => portal Id => portal funding round => contributed collateral type
    mapping(address => mapping(uint256 => mapping(uint256 => uint256))) internal ownerCollateralType;
    
    // contributor => portal Id => portal funding round => contributed ghst
    mapping(address => mapping(uint256 => mapping(uint256 => uint256))) internal ownerContributedToAavegotchiFunding;
    
    // ============ Public Not-Mutated Storage ============
    
    // ERC-20 name for fractional tokens
    string public name;
    
    // ERC-20 symbol for fractional tokens
    string public symbol;
    
    // Address of the Aavegotchi Diamond contract
    address public diamondContract;
    
    // Address of the GHST contract
    address public ghstContract;
    
    // Address of the staking contract
    address public stakingContract;
    
    // Address of the REALMs contract
    address public realmsContract;
    
    // address of the parent FrAactionHub
    address public demergeFrom;
    
    // ============ Public Mutable Storage ============
    
    // the governance contract which gets paid in ETH
    address public settingsContract;
    
    // FrAactionDAOMultisig address
    address public fraactionDaoMultisig;
    
    // FrAactionHall address
    address public fraactionHall;
    
    // target of the initial bid
    address public fraactionHubTarget;
    
    // contributor for the current staking decrease or increase;
    address public stakingContributor;
    
    // the current user winning the token auction
    address public winning;
    
    // the Player of the fractionalized Aavegotchi
    address public player;
    
    // addresses of all the FrAactionHub owners
    address[] public ownersAddress;
    
    // fee rewarded to the Player
    uint256 public playerFee;

    // the last timestamp when fees were claimed
    uint256 public lastClaimed;

    // the number of ownership tokens voting on the reserve price at any given time
    uint256 public votingTokens;

    // total GHST deposited by all contributors
    uint256 public totalContributedToFraactionHub;
    
    // Price in wei of the listed item targetted by the current funding round
    uint256 public priceInWei;
    
    // quantity of items to be acquired from the baazaar by the new funding round
    uint256 public quantity;
    
    // total votes for the election of the player 
    uint256 public votesTotalPlayer; 
    
    // total votes for the player fee update
    uint256 public votesTotalFee; 
    
    // total votes for the auction length update
    uint256 public votesTotalLength;
    
    // total votes for the FrAactionHub type update
    uint256 public votesTotalType;
    
    // total GHST deposited by all contributors for the funding round
    uint256 public totalContributedToFunding;
    
    // last initial bid price submitted to the target FrAactionHub
    uint256 public submittedBid;
    
    // Number of assets acquired by the FrAactionHub
    uint256 public numberOfAssets;
    
    // Id of the portal to be claimed by the FrAactionHub
    uint256 public portalTarget;
    
    // option number of the appointed Aavegotchi to be claimed by the FrAactionHub
    uint256 public portalOption;
    
    // the unix timestamp end time of the token auction
    uint256 public auctionEnd;

    // the length of auctions
    uint256 public auctionLength;

    // reservePrice * votingTokens
    uint256 public reserveTotal;

    // the current price of the token during the final auction
    uint256 public livePrice;
    
    // listingId of the current funding round target
    uint256 public listingId;
     
    // Number of the FrAactionHub owners
    uint256 public numberOfOwners;
    
    // new funding round initial time 
    uint256 public fundingTime;
    
    // Aavegotchi funding round initial time 
    uint256 public aavegotchiFundingTime;
    
    // maximum collateral contribution allowed for the Aavegotchi funding
    uint256 public maxContribution;
    
    // collateral type of the appointed Aavegotchi
    uint256 public collateralType;
    
    // current collateral balance of the targeted Aavegotchi for the stake increase or decrease
    uint256 public collateralBalance;
    
    // current tokenId of the targeted Aavegotchi for the stake increase or decrease
    uint256 public stakingTarget;
    
    // array of the proposed auction lengths for the vote
    uint256[] public votedLength;
    
    // array of the proposed player fees for the vote
    uint256[] public votedFee;
    
    // 0 is for Delegated FrAactionHub, 1 for Collective FrAactionHub
    bool public gameType;
    
    // true if the new funding round is targetting an NFT
    bool public isNft;
    
    // true if there is currently at least one destroyed Aavegotchi tokens to be claimed
    bool public destroyed;
    
    // true if all the funding rounds contributors claimed their tokens
    bool public allClaimed;
    
    // true if the first FrAactionHub funding round is currently active
    bool public firstRound;
    
    // true if the FrAactionHub successfully fractionalized its first NFT or item
    bool public initialized;
    
    // proposed auction length => collected votes in favor of that auction length
    mapping (uint256 => uint256) public votesLength;
    
    // proposed player's fee => collected votes in favor of that player's fee
    mapping (uint256 => uint256) public votesFee;
    
    // portal tokenId => appointed Aavegotchi
    mapping (uint256 => uint256) public aavegotchi;
    
    // tokenId => total votes for the Aavegotchi destruction
    mapping (uint256 => uint256) public votesTotalDestroy;
    
    // tokenId => total votes for the Aavegotchi 
    mapping (uint256 => uint256) public votesTotalAavegotchi;
    
    // tokenId => total votes for the Aavegotchi name
    mapping (uint256 => uint256) public votesTotalName;
    
    // tokenId => total votes for the Aavegotchi skill points allocation
    mapping (uint256 => uint256) public votesTotalSkill;
    
    // tokenId => total votes collected to open this closed portal
    mapping(uint256 => uint256) public votesTotalOpen;
    
    // tokenId => index of asset
    mapping(uint256 => uint256) public tokenIdToAssetIndex;
    
    // portal Id => total contributed for the Aavegotchi portal funding
    mapping(uint256 => uint256) public totalContributedToAavegotchiFunding;
    
    // tokenId => winning Aavegotchi name
    mapping (uint256 => string) public name;
    
    // FrAactionHub owner => votes he collected to become the appointed Player
    mapping(address => uint256) public votesPlayer;
    
    // contributor => total amount contributed to the FrAactionHub
    mapping(address => uint256) public ownerTotalContributed;
    
    // contributor => array of Contributions
    mapping(address => Contribution[]) public contributions;
    
    // FrAactionHub owner => his desired token price
    mapping(address => uint256) public userPrices;

    // FrAactionHub owner => return True if owner already voted for the appointed player
    mapping(address => bool) public votersPlayer;
    
    // FrAactionHub owner => return True if owner already voted for the new Player's fee
    mapping(address => bool) public votersFee;
    
    // FrAactionHub owner => return True if owner already voted for the new auction length
    mapping(address => bool) public votersLength;
    
    // FrAactionHub owner => return True if owner already voted for the new FrAactionHub type
    mapping(address => bool) public votersType;
    
    // FrAactionHub owner => return True if owner already voted for the Aavegotchi
    mapping(address => bool) public votersAavegotchi;
    
    // contributor => true if the contributor already claimed its tokens from the funding round
    mapping(address => bool) public claimed;
    
    // tokenId => true if there is currently a vote for allocating skill points
    mapping(uint256 => bool) public skillVoting;
    
    // owner => tokenId => true if alredy voted, false if not
    mapping(address => mapping(uint256 => bool)) public votersOpen;
    
    // contributor => tokenId => true if contributor already voted for that Aavegotchi destruction
    mapping(address => mapping(uint256 => bool)) public votersDestroy;
    
    // contributor => tokenId => true if contributor already voted for that Aavegotchi 
    mapping(address => mapping(uint256 => bool)) public votersAavegotchi;
    
    // owner => tokenId => current votes for opening the portal
    mapping(address => mapping(uint256 => uint256)) public currentOpenBalance;
    
    // contributor => tokenId => total staking contribution for the considered Aavegotchi
    mapping(address => mapping(uint256 => uint256)) public ownerTotalStakeAmount;
    
    // tokenId => portal option => current votes for this portal option
    mapping(uint256 => mapping(uint256 => uint256)) public votesAavegotchi;
    
    // tokenId => skill points set => current votes for this skill points set
    mapping(uint256 => mapping(uint256 => uint256)) public votesSkill;
    
    // tokenId => Aavegotchi name => current votes for this name
    mapping(uint256 => mapping(string => uint256)) public votesName;
    
    // Array of Assets acquired by the FrAactionHub
    Asset[] public assets;
    
    // ============ Structs ============

    struct Contribution {
        uint256 amount;
        uint256 previousTotalContributedToFraactionHub;
    }
