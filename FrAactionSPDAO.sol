//SPDX-License-Identifier: MIT
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
    IERC20Upgradeable
} from "@OpenZeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
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
    //   (1) INACTIVE or ACTIVE on deploy
    //   (2) BIDSUBMITTED, ENDED or FAILED on finalizeBid()
    enum auctionStatus { 
        INACTIVE, 
        ACTIVE,
        ENDED
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
    
    // 0 = no split ongoing, 1 = split going on for the realms transfer, 2 = same for the NFTs transfer, 3 = same for the items transfer, 4 = same for owner addresses transfer
    uint256 internal split;
    
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
    address public constant diamondContract = 
    
    // Address of the GHST contract
    address public constant ghstContract;
    
    // Address of the staking contract
    address public constant stakingContract;
    
    // Address of the REALMs contract
    address public constant realmsContract;

    // Address of the Raffles contract
    address public constant rafflesContract;
    
    // Address of the wrapped MATIC contract
    address public constant wrappedMaticContract;
    
    // Address of the FrAaction Gangs settings Contract
    address public constant settingsContract = ;

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

    // ============ EVENTS ============

    // an event emitted when a user updates their price
    event PriceUpdate(
        address indexed user, 
        uint price
    );

    // an event emitted when an auction starts
    event Start(
        address indexed buyer, 
        uint price
    );

    // an event emitted when a bid is made
    event Bid(
        ddress indexed buyer, 
        uint price
    );

    // an event emitted when an auction is won
    event Won(
        address indexed buyer, 
        uint price
    );

    // an event emitted when someone cashes in ERC20 tokens for ETH from an ERC721 token sale
    event Cash(
        address indexed owner, 
        uint256 shares
    );
    
    // an event emitted when the assets merger is finalized
    event AssetsMerged(address indexed _mergerTarget);
    
    // an event emitted when the merger is finalized
    event MergerFinalized(address indexed _mergerTarget);
    
    // an event emitted when the demerger is done 
    event Demerged(address indexed proxyAddress, string name, string symbol);
    
    // an event emitted when the Player is appointed or changed
    event AppointedPlayer(address indexed appointedPlayer);
    
    // an event emitted when the auction length is changed
    event UpdateAuctionLength(uint256 indexed newLength);
    
    // an event emitted when the Player fee is changed
    event UpdatePlayerFee(uint256 indexed newFee);
    
    // an event emitted when the FrAaction type is changed
    event UpdateFraactionType(string indexed newGameType);
    
    // an event emitted when somebody redeemed all the FrAactionHub tokens
    event Redeem(address indexed redeemer);
    
    // an event emitted when an Aavegotchi is appointed to be summoned
    event AppointedAavegotchi(uint256 indexed portalTokenId, uint256 appointedAavegotchiOption);
    
    // an event emitted when a portal is open
    event OpenPortal(uint256 indexed portalId);
    
    // an event emitted when an Aavegotchi is destroyed
    event Destroy(uint256 indexed tokenId);
    
    // an event emitted when an Aavegotchi name is chosen
    event Named(uint256 indexed tokenId, string name);
    
    // an event emitted when an Aavegotchi skill points set is submitted
    event SkilledUp(uint256 indexed tokenId, uint256 tokenId);
    
    // an event emitted when wearables are equipped on an Aavegotchi
    event Equipped(uint256 indexed tokenId, uint16[16] wearables);
    
    // an event emitted when consumables are used on one or several Aavegotchis
    event ConsumablesUsed(uint256 indexed tokenId, uint256[] itemIds, uint256[] quantities);
    
    function initializeVault(uint256 _supply, uint256 _listPrice, string memory _name, string memory _symbol) internal initializer {
        // initialize inherited contracts
        __ERC20_init(_name, _symbol);
        reserveTotal = _listPrice * _supply;
        lastClaimed = block.timestamp;
        votingTokens = _listPrice == 0 ? 0 : _supply;
        _mint(address(this), _supply);
        userPrices[address(this)] = _listPrice;
        initialized = true;
    }

    // ============ VIEW FUNCTIONS ============
    
    function getOwners() public view returns (address[] memory) {
        return ownersAddress;
    }

    /// @notice provide the current reserve price of the FrAactionHub 
    function reservePrice() public view returns(uint256) {
        return votingTokens == 0 ? 0 : reserveTotal / votingTokens;
    }
    
    /// @notice inform if the bid is open (return true) or not (return false)
    function openForBid() public view returns(bool) {
        return votingTokens * 1000 >= ISettings(settings).minVotePercentage() * totalSupply() ? true : false;
    }
    
    /// @notice provide minimum amount to bid during the auction
    function minBid() public view returns(uint256) {
        uint256 increase = ISettings(settingsContract).minBidIncrease() + 1000;
        return livePrice * increase / 1000;
    }
    
    // ========= GOV FUNCTIONS =========

    /// @notice allow governance to boot a bad actor Player
    /// @param _Player the new Player
    function kickPlayer(address _player) external {
        require(
            msg.sender == ISettings(settingsContract).owner(), 
            "kick: not gov"
        );
        player = _player;
    }

    /// @notice allow governance to remove bad reserve prices
    function removeReserve(address _user) external {
        require(
            msg.sender == ISettings(settingsContract).owner(), 
            "remove: not gov"
        );
        require(
            auctionStatus == AuctionsStatus.INACTIVE, 
            "remove: auction live cannot update price"
        );
        uint256 old = userPrices[_user];
        require(
            0 != old, 
            "remove: not an update"
        );
        uint256 weight = balanceOf(_user);
        votingTokens -= weight;
        reserveTotal -= weight * old;
        userPrices[_user] = 0;
        emit PriceUpdate(_user, 0);
    }

    // ============ SETTINGS & FEES FUNCTIONS ============

    /// @notice allow the FrAactionHub owners to change the FrAactionHub type
    function changeFraactionType() external {
        require(
            initialized == true, 
            "updateFraactionType: FrAactionHub not initialized yet"
        );
        require(
            balanceOf(msg.sender) > 0, 
            "updateFraactionType: user not an owner of the FrAactionHub"
        );
        require(
            gangAddress != address(0), 
            "updateFraactionType: cannot change the Collective type if the FraactionHub is part of a gang"
        );
        if (typeNumber != typeCurrentNumber[msg.sender]) {
            votersType[msg.sender] = 0;
            currentTypeBalance[msg.sender] = 0;
        }
        if (votersType[msg.sender] == true) {
            votesTotalType -= currentTypeBalance[msg.sender];
        } else {
            votersType[msg.sender] = true;
        }
        votesTotalType += balanceOf(msg.sender);
        currentTypeBalance[msg.sender] = balanceOf(msg.sender);
        if (typeNumber != typeCurrentNumber[msg.sender]) typeCurrentNumber[msg.sender] = typeNumber;
        if (votesTotalType * 1000 >= ISettings(settingsContract).minTypeVotePercentage() * totalSupply()) {
            // 0 is for Delegated FrAactionHub, 1 for Collective FrAactionHub
            if (gameType == 0) gameType = 1;
            if (gameType == 1) gameType = 0;
            emit UpdateFraactionType(gameType);
            typeNumber++;
            votesTotalType = 0;
        }
    }
    
    /// @notice allow the FrAactionHub owners to update the auction length
    /// @param _length the new maximum length of the auction
    function updateAuctionLength(uint256 _length) external {
        require(
            initialized == true, 
            "updateAuctionLength: FrAactionHub not initialized yet"
        );
        require(
            balanceOf(msg.sender) > 0, 
            "updateAuctionLength: user not an owner of the FrAactionHub"
        );
        require(
            _length >= ISettings(settingsContract).minAuctionLength() && _length <= ISettings(settings).maxAuctionLength(), 
            "updateAuctionLength: invalid auction length"
        );
        if (lengthNumber != lengthCurrentNumber[msg.sender]) {
            votersLength[msg.sender] = 0;
            currentLengthVote[msg.sender] = 0;
            currentLengthBalance[msg.sender] = 0;
        }
        if (votersLength[msg.sender] == true) {
            votesLength[currentLengthVote[msg.sender]] -= currentLengthBalance[msg.sender];
            votesTotalLength -= currentLengthBalance[msg.sender];
        } else {
            votersLength[msg.sender] = true;
        }
        if (votesLength[_length] == 0) votedLength.push(_length);
        votesLength[_length] += balanceOf(msg.sender);
        votesTotalLength += balanceOf(msg.sender);
        currentLengthVote[msg.sender] = _length;
        currentLengthBalance[msg.sender] = balanceOf(msg.sender);
        if (lengthNumber != lengthCurrentNumber[msg.sender]) lengthCurrentNumber[msg.sender] = lengthNumber;
        uint256 winner;
        uint256 result;
        if (votesTotalLength * 1000 >= ISettings(settingsContract).minLengthVotePercentage() * totalSupply()) {
            for (uint i = 0; i < votedLength.length; i++) {
                if (votesLength[votedLength[i]] > result) {
                    result = votesLength[votedLength[i]];
                    winner = votedLength[i];
                }
                votesLength[votedLength[i]] = 0;
            }
            auctionLength = winner;
            delete votedLength;
            emit UpdateAuctionLength(auctionLength);
            lengthNumber++;
            votesTotalLength = 0;
        }
    }

    /// @notice allow the FrAactionHub owners to change the player fee
    /// @param _fee the new fee
    function updatePlayerFee(uint256 _playerFee) external {
        require(
            gameType == 0, 
            "updatePlayerFee: this FrAactionHub was set as Collective by its creator"
        );
        require(
            _playerFee <= ISettings(settingsContract).maxPlayerFee(), 
            "updatePlayerFee: cannot increase fee this high"
        );
        require(
            initialized == true, 
            "updatePlayerFee: FrAactionHub not initialized yet"
        );
        require(
            balanceOf(msg.sender) > 0, 
            "updatePlayerFee: user not an owner of the FrAactionHub"
        );
        if (feeNumber != feeCurrentNumber[msg.sender]) {
            votersFee[msg.sender] = 0;
            currentFeeVote[msg.sender] = 0;
            currentFeeBalance[msg.sender] = 0;
        }
        if (votersFee[msg.sender] == true) {
            votesFee[currentFeeVote[msg.sender]] -= currentFeeBalance[msg.sender];
            votesTotalFee -= currentFeeBalance[msg.sender];
        } else {
            votersFee[msg.sender] = true;
        }
        if (votesFee[_playerFee] == 0) votedFee.push(_playerFee);
        votesFee[_playerFee] += balanceOf(msg.sender);
        votesTotalFee += balanceOf(msg.sender);
        currentFeeVote[msg.sender] = _playerFee;
        currentFeeBalance[msg.sender] = balanceOf(msg.sender);
        if (feeNumber != feeCurrentNumber[msg.sender]) feeCurrentNumber[msg.sender] = feeNumber;
        if (votesTotalFee * 1000 >= ISettings(settingsContract).minPlayerFeeVotePercentage() * totalSupply()) {
            for (uint i = 0; i < votedFee.length; i++) {
                if (votesFee[votedFee[i]] > result) {
                    result = votesFee[votedFee[i]];
                    winner = votedFee[i];
                }
                votesFee[votedFee[i]] = 0;
            }
            playerFee = winner;
            delete votedFee;
            emit UpdatePlayerFee(playerFee);
            feeNumber++;
            votesTotalFee = 0;
        }
    }

    // ========= CORE FUNCTIONS ============

    function voteForTransfer(
        uint256[] calldata _nftsIds, 
        uint256[] calldata _extNftsIds,
        uint256[] calldata _ext1155Ids, 
        uint256[] calldata _realmsIds, 
        uint256[] calldata _itemsIds, 
        uint256[] calldata _itemsQuantity, 
        uint256[] calldata _ext1155Quantity,
        uint256[7] calldata _ticketsQuantity, 
        address[] calldata _extNftsAddress, 
        address[] calldata _ext1155Address,
        uint256 _idsToVoteFor, 
        address _transferTo
        ) external nonReentrant {
        require(
            demergerStatus == DemergerStatus.INACTIVE, 
            "voteForTransfer: transfer already active"
        );
        require(
            balanceOf(msg.sender) > 0, 
            "voteForTransfer: caller not an owner of the FrAactionHub"
        );
        require(
            _itemsIds.length == _itemsQuantity.length &&
            _extNftsIds.length == _extNftsAddress.length &&
            _ext1155Ids.length == _ext1155Address.length &&
            _ext1155Address.length == _ext1155Quantity.length &&, 
            "voteForTransfer: input arrays lengths are not matching"
        );
        require(
            _nftsIds.length + 
            _realmsIds.length + 
            _itemsIds.length +
            _itemsQuantity.length +
            _ticketsQuantity.length + 
            _extNftsIds.length + 
            _extNftsAddress.length +
            _ext1155Ids.length +
            _ext1155Quantity.length +
            _ext1155Address.length +
            =< ISettings(settingsContract).MaxTransferLimit(), 
            "voteForTransfer: cannot transfer more than the GovSettings allowed limit"
        );
        if (_nftsIds.length > 0 ||
            _realmsIds.length > 0 ||
            _itemsIds.length > 0 ||
            _ticketsIds.length > 0 ||
            _extNftsIds.length > 0 ||
            _ext1155Ids.length > 0 
        ) {
            if (_idsToVoteFor != proposedIndex + 1) {
                require(
                    _idsToVoteFor == proposedIndex + 1, 
                    "voteForTransfer: user submitting a new demerger has to vote for it"
                );
            }
            require(
                transferTo != address(0), 
                "voteForTransfer: address to transfer to cannot be zero"
            );
            ownershipCheck(
                _nftsIds,
                _extNftsIds,
                _ext1155Ids, 
                _realmsIds, 
                _itemsIds, 
                _itemsQuantity, 
                _ext1155Quantity, 
                _ticketsQuantity,
                _extNftsAddress,
                _ext1155Address,
                1
            );
        }
        if (votersTransfer[msg.sender][_idsToVoteFor] == true) {
            if (balanceOf(msg.sender) != currentTransferBalance[msg.sender][_idsToVoteFor]) 
                votesTotalTransfer[_idsToVoteFor] -= currentTransferBalance[msg.sender][_idsToVoteFor];
        } else {
            votersTransfer[msg.sender][_idsToVoteFor] = true;
        }
        if (balanceOf(msg.sender) != currentTransferBalance[msg.sender][_idsToVoteFor]) {
            votesTotalTransfer[_idsToVoteFor] += balanceOf(msg.sender);
            currentTransferBalance[msg.sender][_idsToVoteFor] = balanceOf(msg.sender);
        }
        if (votesTotalTransfer[_idsToVoteFor] * 1000 >= ISettings(settingsContract).minTransferVotePercentage() * totalSupply()) {
            if (demergerStatus != DemergerStatus.ACTIVE) {
                ownershipCheck(
                    _nftsIds,
                    _extNftsIds,
                    _ext1155Ids, 
                    _realmsIds, 
                    _itemsIds, 
                    _itemsQuantity, 
                    _ext1155Quantity, 
                    _ticketsQuantity,
                    _extNftsAddress,
                    _ext1155Address,
                    0
                );
                indexToTransfer = _idsToVoteFor;
                demergerStatus = DemergerStatus.ACTIVE;
                emit TransferActive(target);
            }
            if (!realmsDemerged || split = 1) {
                transferRealms();
                if (split == 0) realmsDemerged = true;
            } else if (!nftsDemerged || split = 2) {
                transferNfts();
                if (split == 0) {
                    nftsDemerged = true;
                }
            } else if (!itemsDemerged || split = 3) {
                transferItems();
                if (split == 0) itemsDemerged = true;
            } else {
                demergerStatus = DemergerStatus.INACTIVE;
                emit AssetsTransferred(address(this));
                realmsDemerged = false;
                nftsDemerged = false;
                itemsDemerged = false;
            }
            feesContributor[msg.sender]++;
            if (feesContributor[msg.sender] == ISettings(settingsContract).feesRewardTrigger()) {
                mint(msg.sender, ISettings(settingsContract).feesReward());
                feesContributor[msg.sender] = 0;
            }
        }
    }
    
    function finalizeTarget() external {
        require(
            ISettings(settingsContract).fraactionHubRegistry(msg.sender) > 0,
            "finalizeTarget: not a registered FrAactionHub contract"
        );
        require(
            mergerStatus == MergerStatus.ACTIVE,
            "finalizeTarget: merger not active"
        );
        target = address(0);
        mergerStatus == MergeStatus.INACTIVE;
    }
    
    function initiateMerger() external {
        require(
            ISettings(settingsContract).fraactionHubRegistry(msg.sender) > 0,
            "initiateMerger: not a registered FrAactionHub contract"
        );
        require(
            mergerStatus == MergerStatus.INACTIVE, 
            "initiateMerger: caller not an owner of the FrAactionHub"
        );
        proposedMerger[msg.sender] = true;
        timeMerger = block.timestamp;
        emit MergerProposed(msg.sender);
    }
    
    function voteForMerger(
        address _mergerTarget, 
        uint256[] calldata _extNftsIds,  
        uint256[] calldata _ext1155Ids,
        uint256[] calldata _ext1155Quantity,
        address[] calldata _extNftsAddress, 
        address[] calldata _ext1155Address
    ) external nonReentrant {
        require(
            fundingStatus == FundingStatus.FRACTIONALIZED, 
            "voteForMerger: FrAactionHub not fractionalized yet"
        );
        require(
            ISettings(settingsContract).fraactionHubRegistry(_mergerTarget) > 0,
            "voteForMerger: not a registered FrAactionHub contract"
        );
        require(
            balanceOf(msg.sender) > 0, 
            "voteForMerger: user not an owner of the FrAactionHub"
        );
        require(
            mergerStatus == MergerStatus.INACTIVE || 
            target == _mergerTarget, 
            "voteForMerger: merger already active"
        );
        require(
            _extNftsIds.length == _extNftsAddress.length &&
            _ext1155Ids.length == _ext1155Quantity.length
            _ext1155Quantity.length == _ext1155Address.length,
            "voteForMerger: each NFT ID needs a corresponding token address"
        );
        if (timeMerger > ISettings(settingsContract).minMergerTime()) {
            timeMerger = 0;
            if (proposedMerger[_mergerTarget] && target != _mergerTarget) proposedMerger[_mergerTarget] = false;
        }
        if (targetReserveTotal[_tokenId] != 0) targetReserveTotal[_mergerTarget] = FraactionInterface(_mergerTarget).reserveTotal();
        if (votersMerger[msg.sender][_mergerTarget] == true) {
            if (balanceOf(msg.sender) != currentMergerBalance[msg.sender][_mergerTarget]) 
                votesTotalMerger[_mergerTarget] -= currentMergerBalance[msg.sender][_mergerTarget];
        } else {
            votersMerger[msg.sender][_mergerTarget] = true;
        }
        if (balanceOf(msg.sender) != currentMergerBalance[msg.sender][_mergerTarget]) { 
            votesTotalMerger[_mergerTarget] += balanceOf(msg.sender);
            currentMergerBalance[msg.sender][_mergerTarget] = balanceOf(msg.sender);
        }
        if (votesTotalMerger[_mergerTarget] * 1000 >= ISettings(settingsContract).minMergerVotePercentage() * totalSupply()) {
            if (proposedMerger[_mergerTarget] == true) {
                if (mergerStatus == MergerStatus.INACTIVE) {
                    target = _mergerTarget;
                    mergerStatus = MergerStatus.ACTIVE
                    emit MergerInitiated(mergerTarget);
                }
                uint256[] memory realmsIds = DiamondInterface(realmsContract).tokenIdsOfOwner(target);
                uint32[] memory nftIds = DiamondInterface(diamondContract).tokenIdsOfOwner(target);
                ItemIdIO[] memory itemsDiamond = DiamondInterface(diamondContract).itemBalances(target);
                uint256[] memory itemsStaking = DiamondInterface(stakingContract).balanceOfAll(target);
                bool checkTickets;
                for (uint i = 0; i < itemsStaking.length; i++) {
                    if (itemsStaking[i] != 0) {
                        checkTickets = true;
                        break;
                    }
                }
                if (realmsIds.length > 0 && split == 0 || split == 1) {
                    (bool success, bytes memory returnData) = 
                    target.call(abi.encodeWithSignature("transferRealms()"));
                    require(
                        success,
                        string(
                            abi.encodePacked(
                                "voteForMerger: initiating merger order failed: ",
                                returnData
                            )
                        )
                    );
                } else if (nftIds.length > 0 && split == 0 || split == 2) {
                    (bool success, bytes memory returnData) = 
                    target.call(abi.encodeWithSignature("mergeNfts()"));
                    require(
                        success,
                        string(
                            abi.encodePacked(
                                "voteForMerger: initiating merger order failed: ",
                                returnData
                            )
                        )
                    );
                } else if (itemsDiamond.length > 0 && split == 0 || 
                    split == 3 || 
                    checkTickets == true
                    ) {
                    (bool success, bytes memory returnData) = 
                    target.call(abi.encodeWithSignature("mergeItems()"));
                    require(
                        success,
                        string(
                            abi.encodePacked(
                                "voteForMerger: initiating merger order failed: ",
                                returnData
                            )
                        )
                    );
                } else if (_extNftsIds.length > 0 && split == 0 || split == 4) {
                    (bool success, bytes memory returnData) = 
                    target.call(abi.encodeWithSignature("mergeNfts()"));
                    require(
                        success,
                        string(
                            abi.encodePacked(
                                "voteForMerger: initiating merger order failed: ",
                                returnData
                            )
                        )
                    );
                } else if (_ext1155Ids.length > 0 && split == 0 || split == 5) {
                    (bool success, bytes memory returnData) = 
                    target.call(abi.encodeWithSignature("mergeNfts()"));
                    require(
                        success,
                        string(
                            abi.encodePacked(
                                "voteForMerger: initiating merger order failed: ",
                                returnData
                            )
                        )
                    );
                } else {
                    mergerStatus == MergerStatus.ASSETSTRANSFERRED;
                    emit MergerAssetsTransferred(address(this));
                }
                if (realmsIds.length > 50 ||
                
                ) {
                    feesContributor[msg.sender]++;
                }
                if (feesContributor[msg.sender] == ISettings(settingsContract).feesRewardTrigger()) {
                    mint(msg.sender, ISettings(settingsContract).feesReward());
                    feesContributor[msg.sender] = 0;
                }
            } else {
                target = _mergerTarget;
                (bool success, bytes memory returnData) = 
                    target.call(abi.encodeWithSignature("initiateMerger()"));
                require(
                    success,
                    string(
                        abi.encodePacked(
                            "voteForMerger: initiating merger order failed: ",
                            returnData
                        )
                    )
                );
                mergerStatus = MergerStatus.ACTIVE;
                timeMerger = block.timestamp;
                emit MergerInitiated(target);
            }
            votesTotalMerger[_mergerTarget] = 0;
        }
    }

    function postAuctionMerge(
        uint256[] calldata _extNftsIds,  
        uint256[] calldata _ext1155Ids,
        uint256[] calldata _ext1155Quantity,
        address[] calldata _extNftsAddress, 
        address[] calldata _ext1155Address
    ) public {
        require(
            _extNftsIds.length == _extNftsAddress.length &&
            _ext1155Ids.length == _ext1155Quantity.length
            _ext1155Quantity.length == _ext1155Address.length,
            "postAuctionMerge: each NFT ID needs a corresponding token address"
        );
        if (mergerStatus == MergerStatus.INACTIVE) {
            target = auctionTarget;
            mergerStatus = MergerStatus.ACTIVE
            emit MergerInitiated(target);
        }
        uint256[] memory realmsIds = DiamondInterface(realmsContract).tokenIdsOfOwner(target);
        uint32[] memory nftIds = DiamondInterface(diamondContract).tokenIdsOfOwner(target);
        ItemIdIO[] memory itemsDiamond = DiamondInterface(diamondContract).itemBalances(target);
        uint256[] memory itemsStaking = DiamondInterface(stakingContract).balanceOfAll(target);
        bool checkTickets;
        for (uint i = 0; i < itemsStaking.length; i++) {
            if (itemsStaking[i] != 0) {
                checkTickets = true;
                break;
            }
        }
        if (realmsIds.length > 0 && split == 0 || split == 1) {
            (bool success, bytes memory returnData) = 
            target.call(abi.encodeWithSignature("transferRealms()"));
            require(
                success,
                string(
                    abi.encodePacked(
                        "voteForMerger: initiating merger order failed: ",
                        returnData
                    )
                )
            );
        } else if (nftIds.length > 0 && split == 0 || split == 2) {
            (bool success, bytes memory returnData) = 
            target.call(abi.encodeWithSignature("mergeNfts()"));
            require(
                success,
                string(
                    abi.encodePacked(
                        "voteForMerger: initiating merger order failed: ",
                        returnData
                    )
                )
            );
        } else if (itemsDiamond.length > 0 && split == 0 || 
            split == 3 || 
            checkTickets == true
            ) {
            (bool success, bytes memory returnData) = 
            target.call(abi.encodeWithSignature("mergeItems()"));
            require(
                success,
                string(
                    abi.encodePacked(
                        "voteForMerger: initiating merger order failed: ",
                        returnData
                    )
                )
            );
        } else if (_extNftsIds.length > 0 && split == 0 || split == 4) {
            (bool success, bytes memory returnData) = 
            target.call(abi.encodeWithSignature("mergeItems()"));
            require(
                success,
                string(
                    abi.encodePacked(
                        "voteForMerger: initiating merger order failed: ",
                        returnData
                    )
                )
            );
        } else if (_ext1155Ids.length > 0 && split == 0 || split == 5) {
            (bool success, bytes memory returnData) = 
            target.call(abi.encodeWithSignature("mergeItems()"));
            require(
                success,
                string(
                    abi.encodePacked(
                        "voteForMerger: initiating merger order failed: ",
                        returnData
                    )
                )
            );
        } else {
            mergerStatus == MergerStatus.MERGED;
            MergerAssetsTransferred(address(this));
        }
    }

    function finalizeMerger() external nonReentrant {
        require(
            mergerStatus == MergerStatus.ASSETSTRANSFERRED,
            "finalizeMerger: items not transferred yet"
        );
        require(
            balanceOf(msg.sender) > 0, 
            "finalizeMerger: user not an owner of the FrAactionHub"
        );
        address[] memory ownersFrom = FraactionInterface(mergerTarget).getOwners();
        uint256 max = ISettings(settingsContract).maxOwnersArrayLength();
        uint256 startIndex = 0;
        uint256 endIndex = ownersFrom.length;
        if (split == 0) {
            uint256 agreedReserveTotal = FraactionInterface(mergerTarget).targetReserveTotal(address(this));
            uint256 agreedReserveTotalFrom = targetReserveTotal[mergerTarget];
            newShareFrom = totalSupply() * agreedReserveTotalFrom / agreedReserveTotal;
            if (ownersFrom.length > max) {
                if (ownersFrom.length % max > 0) {
                    multiple = ownersFrom.length / max + 1;
                } else {
                    multiple = ownersFrom.length / max;
                }
                split = 6;
                splitCounter++;
            }
            endIndex = max;
        } else {
            if (ownersFrom.length % max > 0 && splitCounter >= multiple - 1) {
                startIndex = splitCounter * max + 1;
                endIndex = ownersFrom.length;
            } else {
                startIndex = splitCounter * max + 1;
                endIndex = (splitCounter + 1) * max;
            }
            splitCounter++;
        }
        bool existing;
        if (endIndex > ownersFrom.length) endIndex = ownersFrom.length;
        if (startIndex > ownersFrom.length) return;
        for (uint i = startIndex; i < endIndex; i++) {
            for (uint j = 0; j < ownersAddress.length; j++) {
                if (ownersFrom[i] == ownersAddress[j]) {
                    existing = true;
                }
            }
            if (existing == false) ownersAddress.push(ownersFrom[i]);
            totalContributedToFraactionHub += FraactionInterface(mergerTarget).totalContributedToFraactionHub();
            mint(
                ownersFrom[i], 
                newShareFrom * FraactionInterface(mergerTarget).balanceOf(ownersFrom[i]) / FraactionInterface(mergerTarget).totalSupply()
            );
        }
        if (splitCounter == multiple) {
            if (split > 0) {
                split = 0;
                splitCounter = 0;
                multiple = 0;
            }
            mergerStatus = MergerStatus.MERGED;
            emit MergerFinalized(mergerTarget);
        }
        feesContributor[msg.sender]++;
        if (feesContributor[msg.sender] == ISettings(settingsContract).feesRewardTrigger()) {
            mint(msg.sender, ISettings(settingsContract).feesReward());
            feesContributor[msg.sender] = 0;
        }
    }
    
    function transferRealms() public nonReentrant {
        require(
            msg.sender == target,
            "transferRealms: caller not approved"
        );
        require(
            mergerStatus == MergerStatus.ACTIVE ||
            demergerStatus == DemergerStatus.ACTIVE,
            "transferRealms: merger, transfer or demerger not active"
        );
        uint256 arrayLength;
        if (demergerStatus == DemergerStatus.ACTIVE) {
            arrayLength = votedRealms[votedIndexRealms[indexToTransfer]].length;
        } else {
            arrayLength = DiamondInterface(realmsContract).tokenIdsOfOwner(address(this)).length;
        }
        uint256[] memory realmsIds = new uint256[](arrayLength);
        if (demergerStatus == DemergerStatus.ACTIVE) {
            realmsIds = votedRealms[votedIndexRealms[indexToTransfer]];
        } else {
            realmsIds = DiamondInterface(realmsContract).tokenIdsOfOwner(address(this));
        }
        uint256 startIndex;
        uint256 endIndex = realmsIds.length;
        if (split == 0) {
            maxNftArrayLength = ISettings(settingsContract).maxNftArrayLength();
            if (realmsIds.length > max) {
                endIndex = max;
                if (demergerStatus == DemergerStatus.ACTIVE) {
                    if (realmsIds.length % max > 0) {
                        multiple = realmsIds.length / max + 1;
                    } else {
                        multiple = realmsIds.length / max;
                    }
                    split = 1;
                    splitCounter++;
                }
            }
        } else {
            } else {
            if (realmsIds.length % max > 0 && splitCounter >= multiple - 1) {
                startIndex = splitCounter * max + 1;
                endIndex = realmsIds.length;
            } else {
                startIndex = splitCounter * max + 1;
                endIndex = (splitCounter + 1) * max;
            }
            splitCounter++;
        }
        if (_endIndex > realmsIds.length) _endIndex = nftIds.length;
        if (_startIndex > realmsIds.length) return;
        for (uint i = _startIndex; i < _endIndex; i++) {
            (bool success, bytes memory returnData) =
                realmsContract.call(
                    abi.encodeWithSignature(
                        "safeTransferFrom(
                            address,
                            address,
                            uint256,
                            bytes
                        )", 
                        address(this), 
                        target, 
                        realmsIds[i], 
                        new bytes(0)
                    )
                );
            require(
                success,
                string(
                    abi.encodePacked(
                        "mergeRealms: merge realms order failed: ",
                        returnData
                    )
                )
            );
        }
        if (splitCounter == multiple) {
            if (split) {
                split = 0;
                splitCounter = 0;
                multiple = 0;
            }
            emit TransferredRealms(transferTo);
        }
    }
    
    function transferNfts() public nonReentrant {
        require(
            msg.sender == target,
            "transferNfts: caller not approved"
        );
        require(
            mergerStatus == MergerStatus.ACTIVE ||
            demergerStatus == DemergerStatus.ACTIVE,
            "transferNfts: merger, transfer or demerger not active"
        );
        uint256 arrayLength;
        if (demergerStatus == DemergerStatus.ACTIVE) {
            arrayLength = votedNfts[votedIndexNfts[indexToTransfer]].length;
        } else {
            arrayLength = DiamondInterface(diamondContract).tokenIdsOfOwner(address(this)).length;
        }
        uint256[] memory nftsIds = new uint256[](arrayLength);
        if (demergerStatus == DemergerStatus.ACTIVE) {
            nftIds = votedNfts[votedIndexNfts[indexToTransfer]];
        } else {
            nftIds = DiamondInterface(diamondContract).tokenIdsOfOwner(address(this));
        }
        uint256 startIndex;
        uint256 endIndex = nftsIds.length;
        if (split == 0) {
            maxNftArrayLength = ISettings(settingsContract).maxNftArrayLength();
            if (nftIds.length > max) {
                endIndex = max;
                if (demergerStatus == DemergerStatus.ACTIVE) {
                    if (nftIds.length % max > 0) {
                        multiple = nftIds.length / max + 1;
                    } else {
                        multiple = nftIds.length / max;
                    }
                    split = 1;
                    splitCounter++;
                }
            }
        } else {
            if (nftIds.length % max > 0 && splitCounter >= multiple - 1) {
                startIndex = splitCounter * max + 1;
                endIndex = nftIds.length;
            } else {
                startIndex = splitCounter * max + 1;
                endIndex = (splitCounter + 1) * max;
            }
            splitCounter++;
        }
        if (endIndex > nftIds.length) endIndex = nftIds.length;
        if (startIndex > nftIds.length) return;
        for (uint i = startIndex; i < endIndex; i++) {
            (bool success, bytes memory returnData) =
                diamondContract.call(
                    abi.encodeWithSignature(
                        "safeTransferFrom(
                            address,
                            address,
                            uint256,
                            bytes
                        )", 
                        address(this), 
                        target, 
                        nftIds[i], 
                        new bytes(0)
                    )
                );
            require(
                success,
                string(
                    abi.encodePacked(
                        "mergeNfts: merge nfts order failed: ",
                        returnData
                    )
                )
            );
        }
        if (splitCounter == multiple) {
            if (split > 0) {
                split = 0;
                splitCounter = 0;
                multiple = 0;
            }
            emit TransferredNfts(target);
        }
    }
    
    function transferItems() public nonReentrant {
        require(
            msg.sender == target,
            "transferItems: caller not approved"
        );
        require(
            mergerStatus == MergerStatus.ACTIVE ||
            demergerStatus == DemergerStatus.ACTIVE,
            "transferItems: merger, transfer or demerger not active"
        );
        if (demergerStatus == DemergerStatus.ACTIVE) {
            arrayLength = votedItemsDemerger[votedIndexItems[indexToTransfer]].length;
        } else {
            arrayLength = DiamondInterface(diamondContract).itemBalances(this.address).length;
        } 
        ItemIdIO[] memory items = new ItemIdIO[](arrayLength);
        uint256[] memory ids = new uint256[](arrayLength);
        uint256[] memory quantities = new uint256[](arrayLength);
        uint256 startIndex;
        uint256 arrayLength;
        uint256 endIndex;
        if (demergerStatus == DemergerStatus.ACTIVE) {
            ids = votedItems[votedIndexItems[indexToTransfer]];
            quantities = votedItemsQuantity[votedIndexItemsQuantity[indexToTransfer]];
            endIndex = ids.length;
        } else {
            items = DiamondInterface(diamondContract).itemBalances(this.address);
            endIndex = items.length;
        }
        if (split == 0) {
            maxItemsArrayLength = ISettings(settingsContract).maxItemsArrayLength();
            if (items.length > max ) {
                endIndex = max;
                if (demergerStatus == DemergerStatus.ACTIVE) {
                    if (items.length % max > 0) {
                        multiple = items.length / max + 1;
                    } else {
                        multiple = items.length / max;
                    }
                    split = 3;
                    splitCounter++;
                }
            }
            {
                bool exist;
                uint256[] memory idsTickets = new uint256[](7);
                uint256[] memory quantityTickets = new uint256[](7);
                if (demergerStatus == DemergerStatus.ACTIVE) {
                    quantityTickets = votedTicketsQuantity[votedIndexTicketsQuantity[indexToTransfer]];
                } else {
                    quantityTickets = DiamondInterface(stakingContract).balanceOfAll(this.address);
                }
                for (uint i = 0; i < idsTickets.length; i++) {
                    idsTickets[i] = i;
                    if (exist == false) {
                        if (quantityTickets[i] > 0) exist = true;
                    }
                }
                if (exist == true) {
                    (bool success, bytes memory returnData) = 
                        stakingContract.call(
                            abi.encodeWithSignature(
                                "safeBatchTransferFrom(
                                    address,
                                    address,
                                    uint256[],
                                    uint256[],
                                    bytes
                                )", 
                                address(this), 
                                target, 
                                idsTickets, 
                                quantityTickets, 
                                new bytes(0)
                            )
                        );
                    require(
                        success,
                        string(
                            abi.encodePacked(
                                "mergeItems: merge items order failed: ",
                                returnData
                            )
                        )
                    );
                }
            }
        } else {
            if (ids.length % max > 0 && splitCounter >= multiple - 1) {
                startIndex = splitCounter * max + 1;
                endIndex = ids.length;
            } else {
                startIndex = splitCounter * max + 1;
                endIndex = (splitCounter + 1) * max;
            }
            splitCounter++;
        }
        if (endIndex > ids.length) endIndex = ids.length;
        if (startIndex > ids.length) return;
        for (uint i = startIndex; i < endIndex; i++) {
            ids[i] = items[i].itemId;
            quantities[i] = items[i].balance;
        }
        (bool success, bytes memory returnData) = 
            diamondContract.call(
                abi.encodeWithSignature(
                    "safeBatchTransferFrom(
                        address,
                        address,
                        uint256[],
                        uint256[],
                        bytes
                    )", 
                    address(this), 
                    target, 
                    ids, 
                    quantities, 
                    new bytes(0)
                    )
            );
        require(
            success,
            string(
                abi.encodePacked(
                    "mergeItems: merge items order failed: ",
                    returnData
                )
            )
        );
        if (splitCounter == multiple) {
            if (split > 0) {
                split = 0;
                splitCounter = 0;
                multiple = 0;
            }
            emit TransferredItems(target);
        }
    }

    function transferExternalNfts(uint256[] calldata _extNftsIds, uint256[] calldata _extNftsAddress) public nonReentrant {
        require(
            msg.sender == target,
            "transferExternalNfts: caller not approved"
        );
        require(
            mergerStatus == MergerStatus.ACTIVE ||
            demergerStatus == DemergerStatus.ACTIVE,
            "transferExternalNfts: merger, transfer or demerger not active"
        );
        uint256 arrayLength;
        if (demergerStatus == DemergerStatus.ACTIVE) {
            arrayLength = votedExtNfts[votedIndexExtNfts[indexToTransfer]].length;
        } else {
            for (uint i = 0; i < _extNftsToTransfer.length; i++) {
                require(
                    _extNftsAddress != address(0),
                    "transferExternalNfts: NFT address cannot be null"
                );
            }
            arrayLength = _extNftsToTransfer.length;
        }
        uint256[] memory nftAddress = new uint256[](arrayLength);
        uint256[] memory nftsIds = new uint256[](arrayLength);
        if (demergerStatus == DemergerStatus.ACTIVE) {
            nftIds = votedExtNfts[votedIndexExtNfts[indexToTransfer]];
            nftAddress = votedExtNftsAddress[votedIndexExtAddress[indexToTransfer]];
        } else {
            nftIds = _extNftsIds;
            nftAddress = _extNftsAddress;
        }
        uint256 startIndex;
        uint256 endIndex;
        if (split == 0) {
            maxNftArrayLength = ISettings(settingsContract).maxNftArrayLength();
            if (nftIds.length > max) {
                endIndex = max;
                if (demergerStatus == DemergerStatus.ACTIVE) {
                    if (nftIds.length % max > 0) {
                        multiple = nftIds.length / max + 1;
                    } else {
                        multiple = nftIds.length / max;
                    }
                    split = 1;
                    splitCounter++;
                }
            }
        } else {
            if (nftsIds.length % max > 0 && splitCounter >= multiple - 1) {
                startIndex = splitCounter * max + 1;
                endIndex = nftsIds.length;
            } else {
                startIndex = splitCounter * max + 1;
                endIndex = (splitCounter + 1) * max;
            }
            splitCounter++;
        }
        if (endIndex > nftIds.length) endIndex = nftIds.length;
        if (startIndex > nftIds.length) return;
        if (demergerStatus == DemergerStatus.ACTIVE) {
            for (uint i = startIndex; i < endIndex; i++) {
                (bool success, bytes memory returnData) =
                    nftAddress[i].call(
                        abi.encodeWithSignature(
                            "safeTransferFrom(
                                address,
                                address,
                                uint256,
                                bytes
                            )", 
                            address(this), 
                            target, 
                            nftIds[i], 
                            new bytes(0)
                        )
                    );
                require(
                    success,
                    string(
                        abi.encodePacked(
                            "mergeNfts: merge nfts order failed: ",
                            returnData
                        )
                    )
                );
                delete ownedNft[nftAddress[i]][nftIds[i]];
            }
        }
        if (splitCounter == multiple) {
            if (split > 0) {
                split = 0;
                splitCounter = 0;
                multiple = 0;
            }
            emit TransferredExtNfts(target);
        }
    }

    function transferExternal1155(
        uint256[] calldata _ext1155Ids, 
        uint256[] calldata _ext1155Quantity,
        address[] calldata _ext1155Address
    ) public nonReentrant {
        require(
            msg.sender == target,
            "transferExternal1155: caller not approved"
        );
        require(
            mergerStatus == MergerStatus.ACTIVE ||
            demergerStatus == DemergerStatus.ACTIVE,
            "transferExternal1155: merger, transfer or demerger not active"
        );
        if (demergerStatus == DemergerStatus.ACTIVE) {
            arrayLength = votedExt1155Transfer[votedIndexExt1155[indexToTransfer]].length;
        } else {
            arrayLength = _ext1155ToTransfer.length;
        } 
        uint256[] memory ids1155 = new uint256[](arrayLength);
        uint256[] memory quantity1155 = new uint256[](arrayLength);
        address[] memory address1155 = new uint256[](arrayLength);
        uint256 startIndex;
        uint256 arrayLength;
        uint256 endIndex;
        if (demergerStatus == DemergerStatus.ACTIVE) {
            ids1155 = votedExt1155[votedIndexExt1155[indexToTransfer]];
            quantity1155 = votedExt1155Quantity[votedIndexExt1155Quantity[indexToTransfer]];
            address1155 = votedExt1155Address[votedIndexExt1155Address[indexToTransfer]];
            endIndex = ids1155.length;
        } else {
            ids1155 = _ext1155Ids;
            quantity1155 = _ext1155Quantity;
            address1155 = _ext1155Address;
            endIndex = _ext1155ToTransfer.length;
        }
        if (split == 0) {
            maxItemsArrayLength = ISettings(settingsContract).maxItemsArrayLength();
            if (ids55.length > max) {
                endIndex = max;
                if (demergerStatus == DemergerStatus.ACTIVE) {
                    if (ids1155.length % max > 0) {
                        multiple = ids1155.length / max + 1;
                    } else {
                        multiple = ids1155.length / max;
                    }
                    split = 5;
                    splitCounter++;
                }
            } 
        } else {
            if (ids1155.length % max > 0 && splitCounter >= multiple - 1) {
                startIndex = splitCounter * max + 1;
                endIndex = ids1155.length;
            } else {
                startIndex = splitCounter * max + 1;
                endIndex = (splitCounter + 1) * max;
            }
            splitCounter++;
        }
        if (endIndex > idsDiamond.length) endIndex = idsDiamond.length;
        if (startIndex > idsDiamond.length) return;
        for () {}
            (bool success, bytes memory returnData) = 
                address1155[i].call(
                    abi.encodeWithSignature(
                        "safeBatchTransferFrom(
                            address,
                            address,
                            uint256[],
                            uint256[],
                            bytes
                        )", 
                        address(this), 
                        target, 
                        ids1155[i], 
                        quantity1155[i], 
                        new bytes(0)
                        )
                );
            require(
                success,
                string(
                    abi.encodePacked(
                        "mergeItems: merge items order failed: ",
                        returnData
                    )
                )
            );
            if (demergerStatus == DemergerStatus.ACTIVE) {
                owned1155[address1155[i]][ids1155[i]] -= quantity1155[i];
            } else {
                delete owned1155[address1155[i]][ids1155[i]];
            }
        if (splitCounter == multiple) {
            if (split > 0) {
                split = 0;
                splitCounter = 0;
                multiple = 0;
            }
            emit TransferredItems(target);
        }
    }
                            
    function voteForDemerger(
        uint256[] calldata _nftsIds, 
        uint256[] calldata _extNftsIds,
        uint256[] calldata _ext1155Ids, 
        uint256[] calldata _realmsIds, 
        uint256[] calldata _itemsIds, 
        uint256[] calldata _itemsQuantity, 
        uint256[] calldata _ext1155Quantity,
        uint256[7] calldata _ticketsQuantity, 
        address[] calldata _extNftsAddress, 
        address[] calldata _ext1155Address,
        uint256 _idsToVoteFor, 
        string calldata _name,  
        string calldata _symbol
    ) external nonReentrant {
        require(
            fundingStatus == FundingStatus.FRACTIONALIZED, 
            "voteForDemerger: FrAactionHub not fractionalized yet"
        );
        require(
            balanceOf(msg.sender) > 0, 
            "voteForDemerger: user not an owner of the FrAactionHub"
        );
        require(
            demergerStatus == DemergerStatus.INACTIVE, 
            "voteForDemerger: user not an owner of the FrAactionHub"
        );
        require(
            mergerStatus == MergerStatus.INACTIVE, 
            "voteForDemerger: active merger"
        );
        require(
            _itemsIds.length == _itemsQuantity.length &&
            _extNftsIds.length == _extNftsAddress.length &&
            _ext1155Ids.length == _ext1155Address.length &&
            _ext1155Address.length == _ext1155Quantity.length &&, 
            "voteForDemerger: input arrays lengths are not matching"
        );
        require(
            _nftsIds.length + 
            _realmsIds.length + 
            _itemsIds.length +
            _itemsQuantity.length +
            _ticketsQuantity.length + 
            _extNftsIds.length + 
            _extNftsAddress.length +
            _ext1155Ids.length +
            _ext1155Quantity.length +
            _ext1155Address.length +
            =< ISettings(settingsContract).MaxTransferLimit(), 
            "voteForDemerger: cannot transfer more than the GovSettings allowed limit"
        );
        if (_nftsIds.length > 0 ||
            _realmsIds.length > 0 ||
            _itemsIds.length > 0 ||
            _ticketsIds.length > 0 ||
            _extNftsIds.length > 0 ||
            _ext1155Ids.length > 0 
        ) {
            if (_idsToVoteFor != proposedIndex + 1) {
                require(
                    _idsToVoteFor == proposedIndex + 1, 
                    "voteFordemerger: user submitting a new demerger has to vote for it"
                );
            }
            ownershipCheck(
                _nftsIds,
                _extNftsIds,
                _ext1155Ids, 
                _realmsIds, 
                _itemsIds, 
                _itemsQuantity, 
                _ext1155Quantity, 
                _ticketsQuantity,
                _extNftsAddress,
                _ext1155Address,
                1
            );
        }
        if (votersDemerger[msg.sender][_idsToVoteFor] == true) {
            if (balanceOf(msg.sender) != currentDemergerBalance[msg.sender][_idsToVoteFor]) 
                votesTotalDemerger[_idsToVoteFor] -= currentDemergerBalance[msg.sender][_idsToVoteFor];
        } else {
            votersDemerger[msg.sender][_idsToVoteFor] = true;
        }
        if (_name != "" && _symbol != "") {
            if (demergerName[_idsToVoteFor] == "" && demergerSymbol[_idsToVoteFor] == "") {
                demergerName[_idsToVoteFor] = _name;
                demergerSymbol[_idsToVoteFor] = _symbol;
            }
        }
        if (balanceOf(msg.sender) != currentDemergerBalance[msg.sender][_idsToVoteFor]) {
            votesTotalDemerger[_idsToVoteFor] += balanceOf(msg.sender);
            currentDemergerBalance[msg.sender][_idsToVoteFor] = balanceOf(msg.sender);
        }
        if (votesTotalDemerger[_idsToVoteFor] * 1000 >= ISettings(settingsContract).minDemergerVotePercentage() * totalSupply()) {
            ownershipCheck(
                _nftsIds,
                _extNftsIds,
                _ext1155Ids, 
                _realmsIds, 
                _itemsIds, 
                _itemsQuantity, 
                _ext1155Quantity, 
                _ticketsQuantity,
                _extNftsAddress,
                _ext1155Address,
                0
            );
            address fraactionFactoryContract = ISettings(settingsContract).fraactionFactoryContract();
            (bool success, bytes memory returnData) = 
                fraactionFactoryContract.call(
                    abi.encodeWithSignature(
                        "startFraactionHub(
                            string,
                            string,
                            address
                        )", 
                        demergerName[_idsToDemerger], 
                        demergerSymbol[_idsToDemerger], 
                        address(this)
                    )
                );
            require(
                success,
                string(
                    abi.encodePacked(
                        "voteForDemerger: mergerFrom order failed: ",
                        returnData
                    )
                )
            );
            target = abi.decode(returnData, (address));
            indexToTransfer = _idsToVoteFor;
            demergerStatus = DemergerStatus.ACTIVE;
            emit DemergerActive(target, demergerName[_idsToVoteFor], demergerSymbol[_idsToVoteFor]);
            feesContributor[msg.sender]++;
            if (feesContributor[msg.sender] == ISettings(settingsContract).feesRewardTrigger()) {
                mint(msg.sender, ISettings(settingsContract).feesReward());
                feesContributor[msg.sender] = 0;
            }
        }
    }
    
    function demergeFrom() external nonReentrant {
        require(
            demergerStatus == DemergerStatus.ACTIVE,
            "demergeFrom: demerger not active"
        );
        FraactionInterface(target).demergeTo();
        if (FraactionInterface(target).demergerStatus() == DemergerStatus.ASSETSTRANSFERRED) {
            demergerStatus = DemergerStatus.ASSETSTRANSFERRED;
            DemergerAssetsTransferred(address(this));
        }
        feesContributor[msg.sender]++;
        if (feesContributor[msg.sender] == ISettings(settingsContract).feesRewardTrigger()) {
            mint(msg.sender, ISettings(settingsContract).feesReward());
            feesContributor[msg.sender] = 0;
        }
    }

    function demergeTo() external nonReentrant {
        require(
            demergerStatus == DemergerStatus.ACTIVE,
            "demergeTo: demerger not active"
        );
        require(
            msg.sender == target,
            "demergeTo: caller is not the demerger child contract"
        );
        if (!realmsDemerged || split = 1) {
            transferRealms();
            if (split == 0) realmsDemerged = true;
        } else if (!nftsDemerged || split = 2) {
            transferNfts();
            if (split == 0) nftsDemerged = true;
        } else if (!itemsDemerged || split = 3) {
            transferItems();
            if (split == 0) itemsDemerged = true;
        } else if (!extNftsDemerged || split = 4) {
            transferExternalNfts();
            if (split == 0) extNftsDemerged = true;
        } else if (!ext1155Demerged || split = 5) {
            transferExternal1155();
            if (split == 0) ext1155Demerged = true;
        } else {
            demergerStatus == DemergerStatus.ASSETSTRANSFERRED;
            realmsDemerged = false;
            nftsDemerged = false;
            itemsDemerged = false;
            extNftsDemerged = false;
            ext1155Demerged = false;
        }
    }

    function finalizeDemerger() external nonReentrant {
        require(
            demergerStatus == DemergerStatus.ASSETSTRANSFERRED, 
            "finalizeDemerger: demerger assets not transferred yet"
        );
        address[] memory ownersFrom = FraactionInterface(target).getOwners();
        uint256 max = ISettings(settingsContract).maxOwnersArrayLength();
        uint256 startIndex = 0;
        uint256 endIndex = ownersFrom.length;
        if (split == 0) {
            if (ownersFrom.length > max) {
                if (ownersFrom.length % max > 0) {
                    multiple = ownersFrom.length / max + 1;
                } else {
                    multiple = ownersFrom.length / max;
                }
                split = 7;
                splitCounter++;
            }
            endIndex = max;
        } else {
            if (ownersFrom.length % max > 0 && splitCounter >= multiple - 1) {
                startIndex = splitCounter * max + 1;
                endIndex = ownersFrom.length;
            } else {
                startIndex = splitCounter * max + 1;
                endIndex = (splitCounter + 1) * max;
            }
            splitCounter++;
        }
        if (endIndex > ownersFrom.length) endIndex = ownersFrom.length;
        if (startIndex > ownersFrom.length) return;
        bool existing;
        for (uint i = startIndex; i < endIndex; i++) {
            ownersAddress.push(ownersFrom[i]);
            ownerTotalContributed[ownersFrom[i]] += FraactionInterface(target).ownerTotalContributed(ownersFrom[i]);
            totalContributedToFraactionHub += FraactionInterface(target).totalContributedToFraactionHub();
            mint(
                ownersFrom[i], 
                FraactionInterface(demergerTarget).balanceOf(ownersFrom[i])
            );
        }
        if (splitCounter == multiple) {
            if (split > 0) {
                split = 0;
                splitCounter = 0;
                multiple = 0;
            }
            demergerStatus = DemergerStatus.INACTIVE;
            FraactionInterface(target).confirmDemerger();
            target = address(0);
            emit DemergerFinalized(target);
        }
        feesContributor[msg.sender]++;
        if (feesContributor[msg.sender] == ISettings(settingsContract).feesRewardTrigger()) {
            mint(msg.sender, ISettings(settingsContract).feesReward());
            feesContributor[msg.sender] = 0;
        }
    }

    function confirmDemerger() external {
        require(
            msg.sender == target,
            "confirmDemerger: caller is not the demerger child contract"
        );
        require(
            demergerStatus == DemergerStatus.ASSETSTRANSFERRED, 
            "confirmDemerger: demerger assets not transferred yet"
        );
        demergerStatus = DemergerStatus.INACTIVE;
        target = address(0);
    }

    function ownershipCheck internal (
        uint256[] calldata _nftsIds,
        uint256[] calldata _extNftsIds,
        uint256[] calldata _ext1155Ids, 
        uint256[] calldata _realmsIds, 
        uint256[] calldata _itemsIds, 
        uint256[] calldata _itemsQuantity, 
        uint256[] calldata _ext1155Quantity, 
        uint256[7] calldata _ticketsQuantity,
        address[] calldata _extNftsAddress,
        address[] calldata _ext1155Address,
        bool _checkParams
    ) external {
        uint256 counterOwned;
        if (_nftsIds.length > 0) {
            uint32[] memory nftsIds = DiamondInterface(diamondContract).tokenIdsOfOwner(address(this));
            for (uint i = 0; i < _nftsIds.length; i++) {
                for (uint j = 0; j < nftsIds.length; j++) {
                    if (_nftsIds[i] == nftsIds[j]) {
                        counterOwned++;
                        break;
                    }
                }
            }
        }
        if (_extNftsIds.length > 0) {
            for (uint i = 0; i < _extNftsIds.length; i++) {
                if (_checkParams) {
                    require(
                        _extNftsAddress[i] != address(0),
                        "ownershipCheck: invalid NFT address"
                    );
                }
                if (IERC721Upgradeable(_extNftsAddress[i]).ownerOf(_extNftsIds[i]) == address(this)) counterOwned++;
            }
        }
        if (_realmsIds.length > 0) {
            uint256[] memory realmsIds = DiamondInterface(realmsContract).tokenIdsOfOwner(address(this));
            for (uint i = 0; i < _realmsIds.length; i++) {
                for (uint j = 0; j < realmsIds.length; j++) {
                    if (_realmsIds[i] == realmsIds[j]) {
                        counterOwned++;
                        break;
                    }
                }
            }
        }
        if (_itemsIds.length > 0) {
            ItemIdIO[] memory itemsIds = DiamondInterface(diamondContract).itemBalances(address(this));
            for (uint i = 0; i < _itemsIds.length; i++) {
                if (_checkParams) {
                    require(
                        _itemsIds[i] > 0 && _itemsQuantity[i] > 0,
                        "ownershipCheck: invalid item quantity"
                    );
                }
                for (uint j = 0; j < itemsIds.length; j++) {
                    if (_itemsIds[i] == itemsIds[j].itemId) {
                        require(
                            _itemsQuantity[i] <= itemsIds[j].balance,
                            "ownershipCheck: proposed item quantities have to be equal or inferior to the owned items quantities"
                        );
                        counterOwned++;
                        break;
                    }
                }
            }
        }
        if (_ext1155Ids.length > 0) {
            for (uint i = 0; i < _ext1155Ids.length; i++) {
                if (_checkParams) {
                    require(
                        _ext1155Quantity[i] > 0 && _ext1155Address[i] != address(0),
                        "ownershipCheck: invalid item quantity or address"
                    );
                }
                if (IERC1155Upgradeable(_ext1155Address[i]).balanceOf(address(this), _ext1155Ids[i]) > 0) {
                    require(
                        _ext1155Quantity[i] <= IERC1155Upgradeable(_ext1155Address[i]).balanceOf(address(this), _ext1155Ids[i]),
                        "ownershipCheck: proposed item quantities have to be equal or inferior to the owned items quantities"
                    );
                    counterOwned++;
                }
            }
        }
        if (_ticketsQuantity.length > 0) {
            bool check;
            uint256[] memory ticketsCurrentQuantity = DiamondInterface(stakingContract).balanceOfAll(address(this));
            for (uint i = 0; i < _ticketsQuantity.length; i++) {
                if (_checkParams) {
                    if (_ticketsQuantity[i] == 0) check = true;
                }
                for (uint j = 0; j < ticketsCurrentQuantity.length; j++) {
                    if (i == j) {
                        require(
                            _ticketsQuantity[i] <= ticketsCurrentQuantity[j],
                            "ownershipCheck: proposed tickets quantities have to be equal or inferior to the owned tickets quantities"
                        );
                        counterOwned++;
                        break;
                    }
                }
            }
            if (check) {
                require(
                    !check,
                    "ownershipCheck: a ticket quantity has to be provided"
                );
            }
        }
        if (counterOwned != _nftsIds.length + _realmsIds.length + _itemsIds.length + _ticketsQuantity.length + _extNftsIds.length + _ext1155ToIds) {
            require(
                counterOwned == _nftsIds.length + _realmsIds.length + _itemsIds.length + _ticketsQuantity.length + _extNftsIds.length + _ext1155ToIds,
                "ownershipCheck: one token or more is not owned by the FrAactionHub"
            );
        }
        votedIndex++;
        if (_nftsIds.length > 0) {
            votedIndexNfts[votedIndex] = votedNfts.length;
            votedNfts.push(_nftsToIds);
        }
        if (_realmsIds.length > 0) {
            votedIndexRealms[votedIndex] = votedRealms.length;
            votedRealms.push(_realmsIds);
        }
        if (_itemsIds.length > 0) {
            votedIndexItems[votedIndex] = votedItems.length;
            votedItems.push(_itemsIds);
            votedIndexItemsQuantity[votedIndex] = votedItemsQuantity.length;
            votedItemsQuantity.push(_itemsQuantity);
        }
        if (_ticketsQuantity.length > 0) {
            votedIndexTicketsQuantity[votedIndex] = votedTicketsQuantity.length;
            votedTicketsQuantity.push(_ticketsQuantity);
        }
        if (_extNftsIds.length > 0) {
            votedIndexExtNfts[votedIndex] = votedExtNfts.length;
            votedExtNfts.push(_extNftsIds);
            votedIndexExtAddress[votedIndex] = votedExtAddress.length;
            votedExtAddress.push(_extNftsAddress);
        }
        if (_ext1155Ids.length > 0) {
            votedIndexExt1155[votedIndex] = votedExt1155.length;
            votedExt1155.push(_ext1155Ids);
            votedIndexExt1155Quantity[votedIndex] = votedExt1155Quantity.length;
            votedExt1155Quantity.push(_ext1155Quantity);
            votedIndexExt1155Address[votedIndex] = votedExt1155Address.length;
            votedExt1155Address.push(_ext1155Address);
        }
    }

    /// @notice a function for an end user to update their desired sale price
    /// @param _new the desired price in GHST
    function updateUserPrice(uint256 _new) external {
        require(
            balanceOf(msg.sender) > 0, 
            "updateUserPrice: user not an owner of the FrAactionHub"
        );
        require(
            finalAuctionStatus == FinalAuctionStatus.INACTIVE, 
            "updatePrice: auction live cannot update price"
        );
        require(
            initialized == true, 
            "updatePrice: FrAactionHub not fractionalized yet"
        );
        uint256 old = userPrices[msg.sender];
        require(
            _new != old, 
            "updatePrice:not an update"
        );
        uint256 weight = balanceOf(msg.sender);

        if (votingTokens == 0) {
            votingTokens = weight;
            reserveTotal = weight * _new;
        }
        // they are the only one voting
        else if (weight == votingTokens && old != 0) {
            reserveTotal = weight * _new;
        }
        // previously they were not voting
        else if (old == 0) {
            uint256 averageReserve = reserveTotal / votingTokens;
            uint256 reservePriceMin = averageReserve * ISettings(settingsContract).minReserveFactor() / 1000;
            require(
                _new >= reservePriceMin, 
                "updatePrice:reserve price too low"
            );
            uint256 reservePriceMax = averageReserve * ISettings(settingsContract).maxReserveFactor() / 1000;
            require(
                _new <= reservePriceMax, 
                "update:reserve price too high"
            );
            votingTokens += weight;
            reserveTotal += weight * _new;
        }
        // they no longer want to vote
        else if (_new == 0) {
            votingTokens -= weight;
            reserveTotal -= weight * old;
        }
        // they are updating their vote
        else {
            uint256 averageReserve = (reserveTotal - (old * weight)) / (votingTokens - weight);
            uint256 reservePriceMin = averageReserve * ISettings(settingsContract).minReserveFactor() / 1000;
            require(
                _new >= reservePriceMin, 
                "updatePrice:reserve price too low"
            );
            uint256 reservePriceMax = averageReserve * ISettings(settingsContract).maxReserveFactor() / 1000;
            require(
                _new <= reservePriceMax, 
                "updatePrice:reserve price too high"
            );
            reserveTotal = reserveTotal + (weight * _new) - (weight * old);
        }
        userPrices[msg.sender] = _new;
        emit PriceUpdate(msg.sender, _new);
    }
    
     /// @notice an external function to decrease an Aavegotchi staked collateral amount
    function VoteForStakeDecrease(uint256 _tokenId, uint256 _stakeAmount) external nonReentrant {
        require(
            balanceOf(msg.sender) > 0, 
            "VoteForStakeDecrease: user not an owner of the FrAactionHub"
        );
        require(
            _stakeAmount < DiamondInterface(diamondContract).collateralBalance(_tokenId).balance_, 
            "VoteForStakeDecrease: stake amount greater than the total contributed amount"
        );
        require(
            _stakeAmount > 0,
            "VoteForStakeDecrease: staked amount must be greater than 0"
        );
        require(
            finalAuctionStatus == FinalAuctionStatus.INACTIVE, 
            "VoteForStakeDecrease: an auction is live"
        );
        require(
            _stakeAmount < DiamondInterface(diamondContract).getAavegotchi(_tokenId).minimumStake, 
            "VoteForStakeDecrease: amount has to be lower than the minimum stake"
        );
        if (decreaseNumber[_tokenId][_stakeAmount] != decreaseCurrentNumber[msg.sender][_tokenId][_stakeAmount]) {
            votersDecrease[msg.sender][_tokenId][_stakeAmount] = 0;
            currentDecreaseBalance[msg.sender][_tokenId][_stakeAmount] = 0;
        }
        votesTotalDecrease[_tokenId][_stakeAmount] += balanceOf(msg.sender) - currentDecreaseBalance[msg.sender][_tokenId][_stakeAmount];
        currentDecreaseBalance[msg.sender][_tokenId][_stakeAmount] = balanceOf(msg.sender);
        if (decreaseStaking[_tokenId][_stakeAmount] == 0) decreaseStaking[_tokenId][_stakeAmount] = _stakeAmount;
        if (decreaseNumber != decreaseCurrentNumber[msg.sender]) decreaseCurrentNumber[msg.sender][_tokenId][_stakeAmount] = decreaseNumber;
        if (votesTotalDecrease[_tokenId][_stakeAmount] * 1000 >= ISettings(settingsContract).minDecreaseVotePercentage() * totalSupply()) {
            address collateral = DiamondInterface(diamondContract).collateralBalance(_tokenId).collateralType_;
            (bool success, bytes memory returnData) =
                diamondContract.call(
                    abi.encodeWithSignature("decreaseStake(uint256,uint256)", 
                    _tokenId, 
                    decreaseStaking[_tokenId]
                )
            );
            require(
                success,
                string(
                    abi.encodePacked(
                        "VoteForStakeDecrease: staking order failed: ",
                        returnData
                    )
                )
            );
            redeemedCollateral[collateral].push(decreaseStaking[_tokenId][_stakeAmount]);
            if (collateralToRedeem[collateral] == 0) {
                collateralToRedeem[collateral] = true;
                collateralAvailable.push(collateral);
            }
            decreaseStaking[_tokenId][_stakeAmount] = 0;
            emit StakeDecreased(
                _tokenId, 
                decreaseStaking[_tokenId][_stakeAmount]
            );
            claimed[_contributor] = false;
            if (allClaimed == true) allClaimed = false;
        }
    }
    
    /// @notice a function to vote for opening an already purchased and closed portal
    function voteForOpenPortal(uint256 _tokenId) external {
        require(
            initialized == true, 
            "voteForOpenPortal: cannot vote if an auction is ended"
        );
        require(
            balanceOf(msg.sender) > 0, 
            "voteForOpenPortal: user not an owner of the NFT"
        );
        require(
            finalAuctionStatus == FinalAuctionStatus.INACTIVE, 
            "voteForOpenPortal: auction live cannot update price"
        );
        AavegotchiInfo memory gotchi = getAavegotchi(_tokenId);
        require(
            gotchi.status == 0,
            "voteForOpenPortal: portal already open"
        );
        if (votersOpen[msg.sender][_tokenId] == true) {
            votesTotalOpen[_tokenId] -= currentOpenBalance[msg.sender][_tokenId];
        } else {
            votersOpen[msg.sender][_tokenId] = true;
        }
        votesTotalOpen[_tokenId] += balanceOf(msg.sender);
        currentOpenBalance[msg.sender][_tokenId] = balanceOf(msg.sender);
        if (votesTotalOpen[_tokenId] * 1000 >= ISettings(settingsContract).minOpenVotePercentage() * totalSupply()) {
            DiamondInterface(diamondContract).openPortals(_tokenId);
            emit OpenPortal(_tokenId);
            assets[tokenIdToAssetIndex[_tokenId]].category = 1;
            votesTotalOpen[_tokenId] = 0;
        }
    }
    
    /// @notice vote for an Aavegotchi to be summoned
    function voteForAavegotchi(uint256 _tokenId, uint256 _option) external {
        AavegotchiInfo memory gotchi = getAavegotchi(_tokenId);
        require(
            gotchi.status == 2,
            "voteForAavegotchi: portal not open yet or Aavegotchi already summoned"
        );
        require(_option < 10,
            "voteForAavegotchi: only 10 options available"
        );
        require(balanceOf(msg.sender) > 0,
            "voteForAavegotchi: only owners can vote"
        );
        require(
            finalAuctionStatus == FinalAuctionStatus.INACTIVE, 
            "voteForAavegotchi: auction live cannot update price"
        );
        if (votersAavegotchi[msg.sender][_tokenId] == true) {
            votesAavegotchi[_tokenId][currentAavegotchiVote[msg.sender][_tokenId]] -= currentAavegotchiBalance[msg.sender][_tokenId];
            votesTotalAavegotchi -= currentAavegotchiBalance[msg.sender][_tokenId];
        } else {
            votersAavegotchi[msg.sender][_tokenId] = true;
        }
        if (votesAavegotchi[_tokenId][_option] == 0) votedAavegotchi[_tokenId].push(_option);
        votesAavegotchi[_tokenId][_option] += balanceOf(msg.sender);
        votesTotalAavegotchi[_tokenId] += balanceOf(msg.sender);
        currentAavegotchiVote[msg.sender][_tokenId] = _option;
        currentAavegotchiBalance[msg.sender][_tokenId] = balanceOf(msg.sender);
        uint256 winner;
        uint256 result;
        if (votesTotalAavegotchi[_tokenId] * 1000 >= ISettings(settingsContract).minAavegotchiVotePercentage() * totalSupply()) {
            for (uint i = 0; i < votedAavegotchi[_tokenId].length; i++) {
                if (votesAavegotchi[_tokenId][votedAavegotchi[_tokenId][i]] > result) {
                    result = votesAavegotchi[_tokenId][votedAavegotchi[i]];
                    winner = votedAavegotchi[_tokenId][i];
                }
                votesAavegotchi[_tokenId][votedAavegotchi[_tokenId][i]] = 0;
            }
            aavegotchi[_tokenId] = winner;
            address collateral = DiamondInterface(diamondContract).portalAavegotchiTraits(_tokenId).collateralType;
            DiamondInterface(collateral).approve(diamondContract, MAX_INT);
            emit AppointedAavegotchi(_tokenId, aavegotchi[_tokenId]);
            delete votedAavegotchi[_tokenId];
            votesTotalAavegotchi[_tokenId] = 0;
        } 
    }
    
    /// @notice vote for naming an Aavegotchi 
    function voteForName(uint256 _tokenId, string calldata _name) external {
        require(balanceOf(msg.sender) > 0,
            "voteForName: only owners can vote"
        );
        AavegotchiInfo memory gotchi = getAavegotchi(_tokenId);
        require(
            gotchi.status == 3,
            "voteForName: Aavegotchi not summoned yet"
        );
        require(DiamondInterface(diamondContract).aavegotchiNameAvailable(_name),
            "voteForName: Aavegotchi name not available"
        );
        if (nameNumber[_tokenId] != nameCurrentNumber[msg.sender][_tokenId]) {
            votersName[msg.sender][_tokenId] = 0;
            currentNameVote[msg.sender][_tokenId] = 0;
            currentNameBalance[msg.sender][_tokenId] = 0;
        }
        if (votersName[msg.sender][_tokenId] == true) {
            votesName[_tokenId][currentNameVote[msg.sender][_tokenId]] -= currentNameBalance[msg.sender][_tokenId];
            votesTotalName -= currentNameBalance[msg.sender][_tokenId];
        } else {
            votersName[msg.sender][_tokenId] = true;
        }
        if (votesName[_tokenId][_name] == 0) votedName[_tokenId].push(_name);
        votesName[_tokenId][_name] += balanceOf(msg.sender);
        votesTotalName[_tokenId] += balanceOf(msg.sender);
        currentNameVote[msg.sender][_tokenId] = _name;
        currentNameBalance[msg.sender][_tokenId] = balanceOf(msg.sender);
        if (nameNumber[_tokenId] != nameCurrentNumber[msg.sender][_tokenId]) 
            nameCurrentNumber[msg.sender][_tokenId] = nameNumber[_tokenId];
        string memory winner;
        uint256 result;
        if (votesTotalName[_tokenId] * 1000 >= ISettings(settingsContract).minNameVotePercentage() * totalSupply()) {
            for (uint i = 0; i < votedName[_tokenId].length; i++) {
                if (votesName[_tokenId][votedName[_tokenId][i]] > result) {
                    result = votesName[_tokenId][votedName[i]];
                    winner = votedName[_tokenId][i];
                }
                votesName[_tokenId][votedName[_tokenId][i]] = 0;
                votedName[_tokenId][i] = 0;
            }
            name[_tokenId] = winner;
            DiamondInterface(diamondContract).setAavegotchiName(_tokenId, name[_tokenId]);
            emit Named(_tokenId, name[_tokenId]);
            votesTotalName[_tokenId] = 0;
            nameNumber[_tokenId]++:
        } 
    }
    
    /// @notice vote for spending available skill points on an Aavegotchi
    function voteForSkills(uint256 _tokenId, int16[4] calldata _values) external {
        require(balanceOf(msg.sender) > 0,
            "voteForSkills: only owners can vote"
        );
        require(
            finalAuctionStatus == FinalAuctionStatus.INACTIVE, 
            "voteForSkills: auction live cannot update price"
        );
        uint256 total;
        for (uint i = 0; i < _values.length; i++) {
            if (_values[i] < 0) {
                total += -(_values[i]);
            } else {
                total += _values[i];
            }
        }
        require(total > 0,
            "voteForSkills: must allocate at least 1 skill point"
        );
        require(DiamondInterface(diamondContract).availableSkillPoints(_tokenId) > total,
            "voteForSkills: not enough available skill points"
        );
        if (skillNumber[_tokenId] != skillCurrentNumber[msg.sender][_tokenId]) {
            votersSkill[msg.sender][_tokenId] = 0;
            currentSkillBalance[msg.sender][_tokenId] = 0;
        }
        if (votersSkill[msg.sender][_tokenId] == true) {
            votesSkill[_tokenId][currentSkillVote[msg.sender][_tokenId]] -= currentSkillBalance[msg.sender][_tokenId];
            votesTotalSkill -= currentSkillBalance[msg.sender][_tokenId];
        } else {
            votersSkill[msg.sender][_tokenId] = true;
        }
        uint256 counter;
        if (skillVoting[_tokenId] == false) {
            votedSkill[_tokenId].push(_values);
            votesSkill[_tokenId][0] += balanceOf(msg.sender);
            currentSkillVote[msg.sender][_tokenId] = 0;
            skillVoting[_tokenId] = true;
        } else (skillVoting == true) {
            for (uint i = 0; i < votedSkill.length; i++) {
                for (uint j = 0; j < _values.length; j++) {
                    if (votedSkill[i][j] == _values[j]) counter++;
                }
                if (counter == 4) {
                    votesSkill[_tokenId][i] += balanceOf(msg.sender);
                    currentSkillVote[msg.sender][_tokenId] = i;
                    break;
                }
            }
        } else if (counter != 4) {
            votedSkill[_tokenId].push(_values);
            skillIndex++;
            votesSkill[_tokenId][skillIndex] += balanceOf(msg.sender);
            currentSkillVote[msg.sender][_tokenId] = skillIndex;
        }
        votesTotalSkill[_tokenId] += balanceOf(msg.sender);
        currentSkillBalance[msg.sender][_tokenId] = balanceOf(msg.sender);
        if (skillNumber[_tokenId] != skillCurrentNumber[msg.sender][_tokenId]) 
            skillCurrentNumber[msg.sender][_tokenId] = skillNumber[_tokenId];
        uint256 winner;
        uint256 result;
        if (votesTotalSkill[_tokenId] * 1000 >= ISettings(settingsContract).minSkillVotePercentage() * totalSupply()) {
            for (uint i = 0; i < votedSkill[_tokenId].length; i++) {
                if (votesSkill[_tokenId][i] > result) {
                    result = votesSkill[_tokenId][i];
                    winner = i;
                }
                votesSkill[_tokenId][i] = 0;
            }
            DiamondInterface(diamondContract).spendSkillPoints(_tokenId, votedSkill[_tokenId][winner]);
            emit SkilledUp(_tokenId, votedSkill[_tokenId][winner]);
            delete votedSkill[_tokenId];
            skillNumber[_tokenId]++;
            votesTotalSkill[_tokenId] = 0;
        } 
    }
    
    /// @notice vote for equipping an Aavegotchi with the selected items in the parameter _wearablesToEquip
    function equipWearables(uint256 _tokenId, int16[16] calldata _wearablesToEquip) external {
        require(balanceOf(msg.sender) > 0,
            "equipWearables: only owners can use this function"
        );
        require(
            auctionStatus == AuctionStatus.INACTIVE, 
            "equipWearables: auction live cannot equipe wearables"
        );
        if (fundingStatus = FundingStatus.SUBMITTED) {
            require(
                _tokenId != listingId, 
                "equipWearables: cannot equip a type of item being purchased"
            );
        }
        DiamondInterface(diamondContract).equipWearables(_tokenId, _wearablesToEquip);
        emit Equipped(_tokenId, _values);
    }
    
    /// @notice vote for using consumables on one or several Aavegotchis 
    function useConsumables(
        uint256 _tokenId,
        uint256[] calldata _itemIds,
        uint256[] calldata _quantities
    ) external {
        require(balanceOf(msg.sender) > 0,
            "useConsumables: only owners can use this function"
        );
        require(
            finalAuctionStatus == FinalAuctionStatus.INACTIVE, 
            "useConsumables: auction live cannot use consumables"
        );
        DiamondInterface(diamondContract).useConsumables(_tokenId, _itemIds, _quantities);
        emit ConsumablesUsed(_tokenId, _itemIds, _quantities);
    }
    
    /// @notice vote for and appoint a new Player to play with the FrAactionHub's Aavegotchi(s) on behalf of the other owners
    function voteForPlayer(address _player) external {
        require(
            balanceOf(_player) > 0, 
            "voteForPlayer: player not an owner of the FrAactionHub"
        );
        require(
            finalAuctionStatus != FinalAuctionStatus.ENDED, 
            "voteForPlayer: cannot vote if an auction is ended"
        );
        require(
            initialized == true, 
            "voteForPlayer: FrAactionHub not fractionalized yet"
        );
        require(
            balanceOf(msg.sender) > 0, 
            "voteForPlayer: user not an owner of the NFT"
        );
        require(
            gameType == 0, // 0 is for Delegated FrAactionHub, 1 for Collective FrAactionHub
            "voteForPlayer: this FrAactionHub was set as Collective by its creator"
        );
        if (playerNumber != playerCurrentNumber[msg.sender]) {
            votersPlayer[msg.sender] = 0;
            currentPlayerVote[msg.sender] = 0;
            currentPlayerBalance[msg.sender] = 0;
        }
        if (votersPlayer[msg.sender] == true) {
            votesPlayer[currentPlayerVote[msg.sender]] -= currentPlayerBalance[msg.sender];
            votesTotalPlayer -= currentPlayerBalance[msg.sender];
        } else {
            votersPlayer[msg.sender] = true;
        }
        votesPlayer[_player] += balanceOf(msg.sender);
        votesTotalPlayer += balanceOf(msg.sender);
        currentPlayerVote[msg.sender] = _player;
        currentPlayerBalance[msg.sender] = balanceOf(msg.sender);
        if (playerNumber != playerCurrentNumber[msg.sender]) playerCurrentNumber[msg.sender] = playerNumber;
        address winner;
        uint256 result;
        if (votesTotalPlayer * 1000 >= ISettings(settingsContract).minPlayerVotePercentage() * totalSupply()) {
            for (uint i = 0; i < ownersAddress.length; i++) {
                if (votesPlayer[ownersAddress[i]] > result) {
                    result = votesPlayer[ownersAddress[i]];
                    winner = ownersAddress[i];
                }
                if (votesPlayer[ownersAddress[i]] != 0) votesPlayer[ownersAddress[i]] = 0;
            }
            player = winner;
            playerNumber++;
            votesTotalPlayer = 0;
            DiamondInterface(diamondContract).setApprovalForAll(player, true);
            emit AppointedPlayer(player);
        }
    }
    
    function voteForDestruction(uint256 _tokenId, uint256 _xpToId) external {
        require(balanceOf(msg.sender) > 0,
            "voteForDestruction: only owners can vote"
        );
        require(
            finalAuctionStatus == FinalAuctionStatus.INACTIVE, 
            "voteForDestruction: auction live cannot update price"
        );
        if (destroyNumber[_tokenId] != destroyCurrentNumber[msg.sender][_tokenId]) {
            votersDestroy[msg.sender][_tokenId] = 0;
            currentDestroyBalance[msg.sender][_tokenId] = 0;
        }
        if (votersDestroy[msg.sender][_tokenId] == true) {
            votesTotalDestroy[_tokenId] -= currentDestroyBalance[msg.sender][_tokenId];
        } else {
            votersDestroy[msg.sender][_tokenId] = true;
        }
        votesTotalDestroy[_tokenId] += balanceOf(msg.sender);
        currentDestroyBalance[msg.sender][_tokenId] = balanceOf(msg.sender);
        if (xpToId[_tokenId] == 0) xpToId[tokenId] = _xpToId;
        if (destroyNumber[_tokenId] != destroyCurrentNumber[msg.sender][_tokenId]) 
            destroyCurrentNumber[msg.sender][_tokenId] = destroyNumber[_tokenId];
        if (votesTotalDestroy[_tokenId] * 1000 >= ISettings(settingsContract).minDestroyVotePercentage() * totalSupply()) {
            address collateral = DiamondInterface(diamondContract).collateralBalance(_tokenId).collateralType_;
            uint256 balance = DiamondInterface(diamondContract).collateralBalance(_tokenId).balance_;
            (bool success, bytes memory returnData) =
                diamondContract.call(
                    abi.encodeWithSignature("decreaseAndDestroy(uint256,uint256)", 
                    _tokenId, 
                    xpToId
                )
            );
            require(
                success,
                string(
                    abi.encodePacked(
                        "voteForDestruction: staking order failed: ",
                        returnData
                    )
                )
            );
            redeemedCollateral[collateral].push(balance);
            if (collateralToRedeem[collateral] == 0) {
                collateralToRedeem[collateral] = true;
                collateralAvailable.push(collateral);
            }
            
            emit Destroy(_tokenId);
            destroyNumber[_tokenId]++;
            votesTotalDestroy[_tokenId] = 0;
        }
    }
    
    /// @notice an internal function used to register receiver previous FractionHub token balance, to be used in the _afterTokenTransfer function
    /// @param _from the ERC20 token sender
    /// @param _to the ERC20 token receiver
    /// @param _amount the ERC20 token amount
    function _beforeTokenTransfer(address _from, address _to, uint256 _amount) internal virtual override {
        require (finalAuctionStatus == FinalAuctionStatus.INACTIVE,
            "beforeTokenTransfer: cannot transfer because a final auction is live"
        );
        beforeTransferToBalance = balanceOf(_to);
    }
    
    /// @notice an internal function used to update the ownership register and  update sender and receivers price after each FractionHub token transfer
    /// @param _from the ERC20 token sender
    /// @param _to the ERC20 token receiver
    /// @param _amount the ERC20 token amount
    function _afterTokenTransfer(address _from, address _to, uint256 _amount) internal virtual override {
        if (balanceOf(_from) == 0) {
            for (uint i = 0; i < ownersAddress.length; i++) {
                if (ownersAddress[i] == _from) {
                    replace = ownersAddress[ownersAddress.length - 1];
                    ownersAddress[i] = replace;
                    ownersAddress.pop();
                    numberOfOwners--;
                    break;
                }
            }
        }
        bool replaced;
        if (beforeTransferToBalance == 0) {
                ownersAddress.push(_to);
                numberOfOwners++;
        }
        if (_from != address(0)) {
            uint256 fromPrice = userPrices[_from];
            uint256 toPrice = userPrices[_to];
            // only do something if users have different reserve price
            if (toPrice != fromPrice) {
                // new holder is not a voter
                if (toPrice == 0) {
                    // removing old holder's reserve price 
                    votingTokens -= _amount;
                    reserveTotal -= _amount * fromPrice;
                }
                // old holder is not a voter
                else if (fromPrice == 0) {
                    votingTokens += _amount;
                    reserveTotal += _amount * toPrice;
                }
                // both holders are voters
                else {
                    reserveTotal = reserveTotal + (_amount * toPrice) - (_amount * fromPrice);
                }
            }
        }
    }
}