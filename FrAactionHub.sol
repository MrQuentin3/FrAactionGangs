// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

/*
FrAactionHub v1.0
Quentin for FrAaction Gangs
*/

// ============ External Import: Inherited Contract ============
// NOTE: we inherit from an OpenZeppelin upgradeable contract

import {
    ReentrancyGuardUpgradeable
} from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

// ============ Internal Imports ============

import "./FraactionSPDAO.sol";
import {
    FraactionInterface
} from "./FraactionInterface.sol";

contract FraactionHub is FraactionSPDAO, ReentrancyGuardUpgradeable {
  
    // ============ Events ============
    
    // an event emitted when the contract is initialized
    event Initialized(
        string indexed contributor,
        string amount,
    );
    
    // an event emitted when somebody contributed to the initial bid 
    event ContributedBid(
        address indexed contributor,
        uint256 amount,
        uint256 totalFromContributor
    );
    
    // an event emitted when somebody contributed to the Aavegotchi funding
    event ContributedAavegotchi(
        address indexed contributor,
        address collateralAddress,
        uint256 amount,
        uint256 totalFromContributor
    );
    
    // an event emitted when the purchase of the NFT was realized
    event Purchased(uint256 amount);
    
    // an event emitted when the claim of the appointed Aavegotchi was realized
    event ClaimedAavegotchi(uint256 amount);
    
    // an event emitted when a funding round is initialized
    event Funding(
        uint256 targetListingId, 
        uint256 targetPriceInWey, 
        uint256 targetQuantity
    );
    
    // an event emitted when an Aavegotchi funding round is initialized
    event AavegotchiFunding(
        uint256 targetPortalTokenId, 
        uint256 targetPortalOption, 
    );
    
    // an event emitted when somebody contributed to the funding round
    event Contributed(
        address indexed contributor,
        uint256 amount,
        uint256 totalFromContributor
    );
    
    // an event emitted when the purchase of the Aavegotchi or item(s) of the funding round is realized
    event Purchase(uint256 amount);

    // an event emitted when the funding round is finalized
    event Finalized(
        fundingStatus result, 
        uint256 fee, 
        uint256 newFundingTotalContributed
    );
    
    // an event emitted when the initial bid is finalized
    event FinalizedBid(
        BidStatus result, 
        uint256 fee, 
        uint256 totalContributed
    );
    
     // an event emitted when the Aavegotchi funding round is finalized
    event FinalizedAavegotchi(
        PortalStatus result, 
        uint256 fee, 
        uint256 aavegotchiFundingTotalContributed
    );
    
    // an event emitted when the FrAactionHub tokens are claimed after initial bid 
    event BidClaimed(
        address indexed contributor,
        uint256 claimedtokenAmount,
        uint256 claimedghstAmount
    );
    
    // an event emitted when the FrAactionHub tokens are claimed after the funding round 
     event Claimed(
        address indexed contributor,
        uint256 claimedTokenAmount,
        uint256 claimedGhstAmount
    );
    
    // an event emitted when the FrAactionHub collateral tokens are claimed after the new funding round 
    event CollateralRefunded(
        address indexed contributor,
        address collateralType,
        uint256 sumCollateral
    );
    
    // an event emitted when somebody submitted a bid
    event SubmitBid (uint256 submittedBid);
    
    // an event emitted when a contributor increase the collateral stake of an Aavegotchi
    event StakeIncreased(
        address indexed contributor,
        uint256 tokenId,
        uint256 stakeAmount,
        uint256 amountInGhst
    );
    
    // an event emitted when a contributor decrease the collateral stake of an Aavegotchi
    event StakeDecreased(
        address indexed contributor,
        uint256 tokenId,
        uint256 stakeAmount,
        uint256 amountInGhst
    );
    
    // an event emitted when a contributor claimed its stake increase or decrease
    event StakeClaimed(
        StakingStatus status;
        address indexed contributor,
        uint256 tokenAmount,
        uint256 collateralAmount
    );

    // an event emitted when a contributor claimed its stake after the Aavegotchi destruction
    event DestroyClaimed(
        address indexed contributor,
        address collateral,
        uint256 collateralAmount
    );

    // an event emitted when someone donated ERC20 tokens to the FrAactionHub
    event DonatedErc20(
        address indexed tokenAddress,
        uint256 value
    );

    // an event emitted when someone donated ERC721 tokens to the FrAactionHub
    event DonatedErc721(
        address indexed contributor,
        uint256 id
    );

    // an event emitted when someone donated ERC1155 tokens to the FrAactionHub
    event DonatedErc1155(
        address indexed contributor,
        uint256 id,
        uint256 value
    );

    // an event emitted when someone acknowledged ERC20 tokens for the FrAactionHub
    event AcknowledgedErc20(
        address indexed tokenAddress,
        uint256 value
    );

    // an event emitted when someone acknowledged ERC721 tokens for the FrAactionHub
    event AcknowledgedErc721(
        address indexed contributor,
        uint256 id
    );

    // an event emitted when someone acknowledged ERC1155 tokens for the FrAactionHub
    event AcknowledgedErc1155(
        address indexed contributor,
        uint256 id,
        uint256 value
    );
    
    // ======== Modifiers =========

    modifier onlyFraactionDao() {
        require(
            msg.sender == fraactionDaoMultisig,
            "only FrAactionDAO multisig"
        );
        _;
    }

    // ======== Constructor =========

    constructor(
      
    ) {
        
        
    }

    // ======== Initializer =========

    function initialize(
        string memory _name,
        string memory _symbol,
        address _demergeFrom
        address _gangAddress;
    ) external initializer {
        // initialize ReentrancyGuard and ERC721Holder
        __ReentrancyGuard_init();
        __ERC721Holder_init();
        __ERC1155Holder_init();
        thisContract = address.this;
        fraactionDaoMultisig = _fraactionDaoMultisig;
        diamondContract = 0x86935F11C86623deC8a25696E1C19a8659CbF95d;
        ghstContract = 0x385eeac5cb85a38a9a07a70c73e0a3271cfb54a7;
        stakingContract = 0xA02d547512Bb90002807499F05495Fe9C4C3943f;
        realmsContract = 0x1D0360BaC7299C86Ec8E99d0c1C9A95FEfaF2a11;
        rafflesContract = 0x6c723cac1E35FE29a175b287AE242d424c52c1CE;
        marketContract = ;
        settingsContract = ;
        quickSwapRouterContract = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;
        wrappedMaticContract = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
        DiamondInterface(diamondContract).setApprovalForAll(diamondContract, true);
        DiamondInterface(stakingContract).setApprovalForAll(rafflesContract, true);
        IERC20(ghstContract).approve(stakingContract, MAX_INT);
        // set storage variables
        name = _name;
        symbol = _symbol;
        firstRound = true;
        if (_gangAddress != address(0)) gangAddress = _gangAddress;
        // realm contract approval
        if (_demergeFrom != address(0)) {
            demergeFrom = _demergeFrom;
            demergerStatus = DemergerStatus.ACTIVE;
            gameType = FraactionInterface(_demergeFrom).gameType();
            // guild rules
        }
        emit Initialized(name, symbol);
    }

    // ======== External: Donation =========

    function donateFungibleTokens(address _tokenAddress, uint256 _value) external payable {
        if (_tokenAddress == ghstContract) {
            ERC20lib.transferFrom(_tokenAddress, msg.sender, address(this), _value);
            totalTreasuryInGhst += _value;
        } else if (_tokenAddress == address(this) && msg.value > 0) {
            totalTreasuryInMatic += msg.value;
        } else {
            ERC20lib.transferFrom(_tokenAddress, msg.sender, address(this), _value);
            if (ownedErc20[_tokenAddress] == 0) {
                totalNumberExtAssets++;
                erc20tokens.push(_tokenAddress);
            }
            ownedErc20[_tokenAddress] += value;
        }
        emit DonatedErc20(_tokenAddress, _value);
    }

    function donateExtNft(address _tokenAddress, uint256 _id) external {
        require(
            _tokenAddress != diamondContract &&
            _tokenAddress != realmsContract,
            "donateExtNft: Aavegotchi NFTs can be donated to the FrAactionHub with a simple ERC721 transfer"
        );
        ERC721Upgradeable(_tokenAddress).transferFrom(_tokenAddress, msg.sender, address(this), _id);
        if (!ownedErc721[_tokenAddress][_id]) {
            totalNumberExtAssets++;
            Nft memory newNft = Nft(_tokenAddress, _id);
            nfts.push(newNft);
        }
        ownedNfts[_tokenAddress][_id] = true;
        emit DonatedExtNft(_tokenAddress, _id);
    }

    function donateErcExt1155(address _tokenAddress, uint256 _id, uint256 _value) external {
        require(
            _tokenAddress != diamondContract &&
            _tokenAddress != stakingContract,
            "donateErcExt1155: Aavegotchi items can be donated to the FrAactionHub with a simple ERC1155 transfer"
        );
        ERC1155Upgradeable(_tokenAddress).transferFrom(_tokenAddress, msg.sender, address(this), _id, _value);
        if (ownedErc1155[_tokenAddress][_id] == 0) {
            totalNumberExtAssets++;
            Erc1155 memory newErc1155 = Erc1155(_tokenAddress, _id, _value);
            erc1155Tokens.push(newErc1155);
        }
        ownedErc1155[_tokenAddress][_id] += _value;
        emit DonatedExtErc1155(_tokenAddress, _id, _value);
    }

    function acknowledgeFungibleTokens(address _tokenAddress) external {
        uint256 balance = IERC721Upgradeable(_tokenAddress).balanceOf(address(this));
        uint256 value;
        if (_tokenAddress == ghstContract) {
            require(
                balance >= currentBalanceInGhst,
                "acknowledgeFungibleTokens: insufficient GHST balance"
            );
            value = balance - currentBalanceInGhst;
            totalTreasuryInGhst += value;
        } else if (_tokenAddress == address(this) && msg.value > 0) {
            require(
                address(this).balance >= currentBalanceInMatic,
                "acknowledgeFungibleTokens: insufficient MATIC balance"
            );
            value = balance - currentBalanceInMatic;
            totalTreasuryInMatic += value;
        } else {
            require(
                balance >= ownedErc20[_tokenAddress],
                "acknowledgeFungibleTokens: insufficient ERC20 token balance"
            );
            if (!ownedErc20[_tokenAddress]) {
                totalNumberExtAssets++;
                erc20Tokens.push(_tokenAddress);
            }
            value = balance - ownedErc20[_tokenAddress]
            ownedErc20[_tokenAddress] += value;
        }
        emit AcknwoledgedExtErc20(_tokenAddress, value);
    }

    function acknowledgeExtNft(address _tokenAddress, uint256 _id) external {
        require(
            _tokenAddress != diamondContract &&
            _tokenAddress != realmsContract,
            "acknowledgeExtNft: Aavegotchi NFTs are natively acknowledged by the FrAactionHub"
        );
        require(
            ERC721Upgradeable(_tokenAddress).ownerOf(_id) == address(this),
            "acknowledgeExtNft: FrAactionHub not owner of this NFT"
        );
        if (!ownedErc721[_tokenAddress][_id]) {
            totalNumberExtAssets++;
            Nft memory newNft = Nft(_tokenAddress, _id);
            nfts.push(newNft);
        }
        ownedNfts[_tokenAddress][_id] = true;
        emit AcknowledgedExtNft(_tokenAddress, _id);
    }
    
    function acknowledgeExt1155(address _tokenAddress, uint256 _id, uint256 _value) external {
        require(
            _tokenAddress != diamondContract &&
            _tokenAddress != stakingContract,
            "acknowledgeExtErc1155: Aavegotchi items are natively acknowledged by the FrAactionHub"
        );
        require(
            ERC1155Upgradeable(_tokenAddress).balanceOf(address(this), _id) == _value,
            "acknowledgeExtErc1155: FrAactionHub not owner of this NFT"
        );
        if (ownedErc1155[_tokenAddress][_id] == 0) {
            totalNumberExtAssets++;
            Erc1155 memory newErc1155 = Erc1155(_tokenAddress, _id, _value);
            erc1155Tokens.push(newErc1155);
        }
        ownedErc1155[_tokenAddress][_id] += _value;
        emit AcknwoledgedExtErc1155(_tokenAddress, _id, _value);
    }
    
    // ======== External: Funding =========

    function startFundraising(bool _inGhst) external {
        require(
            fundingStatus == FundingStatus.INACTIVE,
            "startFundraising: FrAactionHub not fractionalized yet"
        );
        require(
            portalFundingStatus == PortalFundingStatus.INACTIVE,
            "startFundraising: FrAactionHub already having a new portal funding"
        );
                require(
            finalAuctionStatus == FinalAuctionStatus.INACTIVE, 
            "startFundraising: Final auction already started"
        );
        if (_inGhst) fundraisingInGhst = _inGhst;
        if (firstRound) {
            require(
                initiator == msg.sender,
                "startPurchase: not the FrAactionHub initiator"
            );
            fundingStatus = fundingStatus.FUNDING;
        } else {
            require(
                balanceOf(msg.sender) > 0,
                "startPurchase: not a FrAactionHub owner"
            );
            fundingStatus = fundingStatus.ACTIVE;
        }
        fundingEnd = block.timestamp + (ISettings(settingsContract).maxNumberDaysFunding() * 1 days);
        if (firstRound) {
            fundingStatus = fundingStatus.FUNDING;
        } else {
            fundingStatus = fundingStatus.ACTIVE;
        }
        totalContributedToFunding = 0;
        usedTreasury = _usedTreasury;
        emit StartedFundraising(msg.sender);
    }

    function confirmFunding(bool _confirm) external {
        require(
            balanceOf(msg.sender) > 0, 
            "confirmFunding: user not an owner of the FrAactionHub"
        );
        require(
            fundingStatus == FundingStatus.ACTIVE, 
            "confirmFunding: funding not active"
        );
        if (currentConfirmBalance[msg.sender] > 0 && !_confirm) {
            votesTotalConfirm -= currentConfirmBalance[msg.sender];
        } else if (currentRejectBalance[msg.sender] > 0 && _confirm) {
            votesTotalReject -= currentRejectBalance[msg.sender];
        }
        if (confirmNumber != confirmCurrentNumber[msg.sender]) confirmCurrentNumber[msg.sender] = confirmNumber;
        if (_confirm) {
            if (confirmNumber != confirmCurrentNumber[msg.sender]) currentConfirmBalance[msg.sender] = 0;
            votesTotalConfirm += balanceOf(msg.sender) - currentConfirmBalance[msg.sender];
            currentConfirmBalance[msg.sender] = balanceOf(msg.sender);
            if (votesTotalConfirm * 1000 >= ISettings(settingsContract).minConfirmVotePercentage() * totalSupply()) {
                if (fundingStatus == fundingStatus.FUNDING) {
                    fundingStatus = fundingStatus.FUNDING;
                } else if (auctionStatus == AuctionStatus.ACTIVE) {
                    fundingStatus = fundingStatus.FUNDING;
                }
                confirmNumber++;
                votesTotalConfirm = 0;
                emit ConfirmedTreasury(usedTreasury);
            }
        } else {
            if (confirmNumber != confirmCurrentNumber[msg.sender]) currentRejectBalance[msg.sender] = 0;
            votesTotalReject += balanceOf(msg.sender) - currentRejectBalance[msg.sender];
            currentRejectBalance[msg.sender] = balanceOf(msg.sender);
            if (votesTotalReject * 1000 >= ISettings(settingsContract).minRejectVotePercentage() * totalSupply()) {
                if (fundingStatus == fundingStatus.FUNDING) {
                    fundingStatus = fundingStatus.INACTIVE;
                } else if (auctionStatus == AuctionStatus.ACTIVE) {
                    fundingStatus = fundingStatus.INACTIVE;
                }
                confirmNumber++;
                votesTotalReject = 0;
                emit RejectedTreasury(usedTreasury);
            }
        }
    }

    function contributeFundraising(uint256 _value) external payable nonReentrant {
        require(
            fundingStatus == FundingStatus.FUNDING,
            "contributeFundraising: FrAactionHub not fractionalized yet"
        );
        if (privateHub) {
            require(
                balanceOf(msg.sender) > 0 ||
                whitelisted[msg.sender], 
                "contributeFundraising: user not an owner or whitelisted member of the FrAactionHub"
            );
        }
        if (block.timestamp > fundingEnd) {
            fundingStatus = fundingStatus.INACTIVE;
        } else {
            require(
                fundingStatus == FundingStatus.FUNDING,
                "contributeFundraising: fundraising not active"
            );
            require(
                balanceOf(msg.sender) > 0,
                "contributeFundraising: not a FrAactionHub owner"
            );
            if (fundraisingInGhst) {
                require(
                    _value > 0, 
                    "contributeFundraising: must contribute more than 0"
                );
                ERC20lib.transferFrom(ghstContract, _contributor, address(this), _value);
                ownerTotalContributedInGhst[_contributor] += _value;
                totalContributedToFraactionHubInGhst += _value;
                currentBalanceInGhst += _value;
                totalTreasuryInGhst += _value;
                totalContributedToFunding += _value;
                if (firstRound == true) {
                    // mint fractional ERC-20 tokens
                    initializeVault(
                        valueToTokens(totalContributedToFraactionHubInGhst, fundingInGhst[fundingNumber]), 
                        totalContributedToFraactionHubInGhst, 
                        name, 
                        symbol
                    );
                    exitInGhst = true;
                    firstRound = false;
                } else {
                    mint(msg.sender, valueToTokens(_value, fundingInGhst[fundingNumber]));
                }
                emit ContributedFundraising(msg.sender, _value);
            } else {
                require(
                    msg.value > 0, 
                    "contributeFundraising: must contribute more than 0"
                );
                ownerTotalContributedInMatic[_contributor] += msg.value;
                totalContributedToFraactionHubInMatic += msg.value;
                currentBalanceInMatic += msg.value;
                totalTreasuryInMatic += msg.value;
                totalContributedToFunding += msg.value;
                if (firstRound == true) {
                    // mint fractional ERC-20 tokens
                    initializeVault(
                        valueToTokens(totalContributedToFraactionHubInMatic, fundingInGhst[fundingNumber]), 
                        totalContributedToFraactionHubInMatic, 
                        name, 
                        symbol
                    );
                    firstRound = false;
                } else {
                    mint(msg.sender, valueToTokens(msg.value, fundingInGhst[fundingNumber]));
                }
                emit ContributedFundraising(msg.sender, msg.value);
            }
        }
    }

    /**
     * @notice Initiate a funding round to buy an Aavegotchi or an item  
     * @dev Emits a NewFunding event upon success; callable by anyone
     */
    function startPurchase(
        bool _isNft,
        bool _inGhst,
        bool _baazaarPurchase,
        uint256 _listingId, 
        uint256 _quantity,
        uint256 _usedTreasury
    ) external {
        require(
            fundingStatus == FundingStatus.INACTIVE,
            "startPurchase: funding already active"
        );
        require(
            portalFundingStatus == PortalFundingStatus.INACTIVE,
            "startPurchase: portal funding already active"
        );
        require(
            finalAuctionStatus == FinalAuctionStatus.INACTIVE, 
            "startPurchase: Final auction already started"
        );
        fundingNumber++;
        if (_inGhst) {
            require(
                _usedTreasury <= totalTreasuryInGhst,
                "startPurchase: value higher than the current treasury"
            );
            fundingInGhst[fundingNumber] = _inGhst;
        } else {
            require(
                _usedTreasury <= totalTreasuryInMatic,
                "startPurchase: value higher than the current treasury"
            );
            require(
                !_baazaarPurchase,
                "startPurchase: cannot purchase from the Baazaar with MATIC"
            );
        }
        if (firstRound) {
            require(
                initiator == msg.sender,
                "startPurchase: not the FrAactionHub initiator"
            );
            fundingStatus = fundingStatus.FUNDING;
        } else {
            require(
                balanceOf(msg.sender) > 0,
                "startPurchase: not a FrAactionHub owner"
            );
            fundingStatus = fundingStatus.ACTIVE;
        }
        if (_usedTreasury > 0) usedTreasury = _usedTreasury;
        if (_baazaarPurchase) fromBaazaar = true;
        listingId = _listingId;
        if (fromBaazaar) {
            isNft = _isNft;
            if (isNft == true) {
                ERC721Listing memory diamond = DiamondInterface(diamondContract).getERC721Listing(listingId);
                priceInWei = diamond.priceInWei;
                require(
                    diamond.timePurchased == 0,
                    "startPurchase: listing ID already sold"
                );
                require(
                    diamond.cancelled == false,
                    "startPurchase: listing ID cancelled"
                );
                require(
                    diamond.timeCreated != 0,
                    "startPurchase: listing ID does not exist"
                );
            } else {
                quantity = _quantity;
                ERC1155Listing memory diamondItem = DiamondInterface(diamondContract).getERC1155Listing(listingId);
                priceInWei = diamondItem.priceInWei;
                require(
                    diamondItem.sold == false,
                    "startPurchase: listing ID already sold"
                );
                require(
                    diamondItem.cancelled == false,
                    "startPurchase: listing ID cancelled"
                );
                require(
                    diamondItem.timeCreated != 0,
                    "startPurchase: listing ID does not exist"
                );
            }
        }
        fundingEnd = block.timestamp + (ISettings(settingsContract).maxNumberDaysFunding() * 1 days);
        totalContributedToFunding = 0;
        if (firstRound) {
            fundingStatus = fundingStatus.FUNDING;
        } else {
            fundingStatus = fundingStatus.ACTIVE;
        }
        emit Funding(
            listingId, 
            priceInWei, 
            quantity
        );
    }
        
    /**
     * @notice Contribute to the FrAaction's treasury
     * while the funding round is still open
     * @dev Emits a Contributed event upon success; 
     */
    function contributePurchase(uint256 _value) external payable nonReentrant {
        require(
            fundingStatus == FundingStatus.FUNDING,
            "contributePurchase: funding round not active"
        );
        require(
            block.timestamp <= fundingEnd,
            "contributePurchase: funding round expired"
        );
        if (privateHub) {
            require(
                balanceOf(msg.sender) > 0 ||
                whitelisted[msg.sender], 
                "contributePurchase: user not an owner or whitelisted member of the FrAactionHub"
            );
        }
        uint256 value;
        if (fundingInGhst[fundingNumber]) {
            value = _value;
        } else {
            value = msg.value;
        }
        require(
            value > 0, 
            "contributePurchase: must contribute more than 0"
        );
        if (fromBaazaar) {
            if (isNft == true) {
                ERC721Listing memory diamond = DiamondInterface(diamondContract).getERC721Listing(listingId);
                if (diamond.timePurchased != 0 ||
                    diamond.cancelled == true ||
                    diamond.timeCreated == 0
                ) {
                    fundingStatus = FundingStatus.SUBMITTED;
                    emit contributed(
                        msg.sender,
                        0,
                        0
                    );
                    return;
                }
            } else {
                ERC1155Listing memory diamondItem = DiamondInterface(diamondContract).getERC1155Listing(listingId);
                if (diamondItem.sold == true ||
                    diamondItem.cancelled == true ||
                    diamondItem.timeCreated == 0
                ) {
                    fundingStatus = FundingStatus.SUBMITTED;
                    emit contributed(
                        msg.sender,
                        0,
                        0
                    );
                    return;
                }
            }
        }
        if (fundingInGhst[fundingNumber]) {
            ownerTotalContributedInGhst[msg.sender] += value;
            currentBalanceInGhst += value;
            ERC20lib.transferFrom(ghstContract, msg.sender, address(this), value);
        } else {
            ownerTotalContributedInMatic[msg.sender] += value;
            currentBalanceInMatic += value;
        }
        ownerContributedToFunding[msg.sender][fundingNumber] += value;
        totalContributedToFunding += value;
        require(
            totalContributedToFunding + value <= getFundingGrossPrice() - usedTreasury,
            "contributePurchase: cannot contribute more than the gross price"
        );
        if (ownerContributedToFunding[msg.sender][fundingNumber] = 0) fundingContributor.push(fundingNumber);  
        emit contributed(
            msg.sender,
            value,
            ownerContributedToFunding[msg.sender][fundingNumber]
        );
    }

    /**
     * @notice Submit a purchase order to the Market
     * @dev Reverts if insufficient funds to purchase the item and pay FrAactionDAO fees
     * Emits a Purchased event upon success.
     * Callable by anyone
     */
    function purchase() external nonReentrant {
        require(
            fundingStatus == FundingStatus.FUNDING,
            "purchase: funding round not active"
        );
        // ensure there is enough GHST to order the purchase including FrAactionDAO fee
        require(
            totalContributedToFunding + usedTreasury == getFundingGrossPrice(),
            "purchase: insufficient funds to purchase"
        );
        if (fromBaazaar) {
            if (isNft == true) {
                ERC721Listing memory diamond = DiamondInterface(diamondContract).getERC721Listing(listingId);
                if (diamond.timePurchased != 0 ||
                    diamond.cancelled == true ||
                    diamond.timeCreated == 0
                ) {
                    fundingStatus = FundingStatus.SUBMITTED;
                    emit contributed(
                        msg.sender,
                        0,
                        0
                    );
                    return;
                }
                // submit the purchase order to the ERC721marketplaceFacet smart contract
                (bool success, bytes memory returnData) =
                    diamondContract.call(
                        abi.encodeWithSignature("executeERC721Listing(uint256)", 
                        listingId
                    )
                );
            } else {
                ERC1155Listing memory diamondItem = DiamondInterface(diamondContract).getERC1155Listing(listingId);
                if (diamondItem.sold == true ||
                    diamondItem.cancelled == true ||
                    diamondItem.timeCreated == 0
                ) {
                    fundingStatus = FundingStatus.SUBMITTED;
                    emit contributed(
                        msg.sender,
                        0,
                        0
                    );
                    return;
                }
                uint256 tokenId = diamondItem.erc1155TypeId;
                ItemIdIO[] memory item = DiamondInterface(diamondContract).itemBalances(address(this));
                for (uint i = 0; i < item.length; i++) {
                    if (item[i].itemId == tokenId) {
                        initialNumberOfItems = 
                            item[i].balance - MarketInterface(marketContract).sellingItems[item[i].itemId] + MarketInterface(marketContract).buyingItems[item[i].itemId];
                        break;
                    }
                }
                // submit the purchase order to the ERC1155marketplaceFacet smart contract
                (bool success, bytes memory returnData) =
                    diamondContract.call(
                        abi.encodeWithSignature("executeERC1155Listing(uint256)", 
                        listingId, 
                        quantity, 
                        priceInWei
                    )
                );
            }
        } else {
            MarketInterface(fraactionMarketContract).executeTokenTransaction(listingId);
        }
        fundingStatus = FundingStatus.SUBMITTED;
        emit Purchase(totalContributedToFunding);
    }

    /**
     * @notice Finalize the state of the new purchase
     * @dev Emits a Finalized event upon success; callable by anyone
     */
    function finalizePurchase() external nonReentrant {
        require(
            fundingStatus == fundingStatus.SUBMITTED,
            "finalizePurchase: funding target not purchased"
        );
        bool existingItem;
        uint256 tokenId;
        if (isNft == true) {
            tokenId = diamond.erc721TokenId;
            fundingStatus = DiamondInterface(diamondContract).ownerOf(tokenId) == address(this) ? FundingStatus.COMPLETED: FundingStatus.FAILED;
        } else {
            tokenId = diamondItem.erc1155TypeId;
            uint256 numberOfItems;
            ItemIdIO[] memory item = DiamondInterface(diamondContract).itemBalances(address(this));
            for (uint i = 0; i < item.length; i++) {
                if (item[i].itemId == tokenId) {
                    numberOfItems = 
                        item[i].balance - MarketInterface(marketContract).sellingItems[item[i].itemId] + MarketInterface(marketContract).buyingItems[item[i].itemId];
                    break;
                }
            }
            fundingStatus = quantity == (numberOfItems - initialNumberOfItems) ? FundingStatus.COMPLETED: FundingStatus.FAILED;
        }
        uint256 fee;
        // if the repurchase was completed,
        if (fundingStatus == FundingStatus.COMPLETED) {
            fundingResult[fundingNumber] = 1;
            // transfer the fee to FrAactionDAO
            fee = _getFundingFee(totalContributedToFunding);
            if (fundingInGhst[fundingNumber]) {
                ERC20lib.transfer(ghstContract, fraactionDaoMultisig, fee);
                totalContributedToFraactionHubInGhst += totalContributedToFunding;
            } else {
                transferMaticOrWmatic(fraactionDaoMultisig, fee);
                totalContributedToFraactionHubInMatic += totalContributedToFunding;
            }
            if (firstRound == true) {
                // mint fractional ERC-20 tokens
                initializeVault(
                    valueToTokens(totalContributedToFunding, fundingInGhst[fundingNumber]), 
                    totalContributedToFunding, 
                    name, 
                    symbol
                );
                if (fundingInGhst[fundingNumber]) exitInGhst = true;
                firstRound = false;
            } else {
                mint(address(this), valueToTokens(totalContributedToFunding, fundingInGhst[fundingNumber]));
            }
        } else {
            fundingResult[fundingNumber] = 0;
        }
        if (fromBaazaar) fromBaazaar = 0;
        if (_usedTreasury > 0) usedTreasury = 0;
        emit Finalized(
            fundingStatus, 
            fee,
            totalContributedToFunding
        );
        fundingStatus = FundingStatus.INACTIVE;
    }

    /**
     * @notice claim the tokens owed
     * to each contributor after the purchase and frationalization has ended
     * @dev Emits a Claimed event upon success
     * callable by anyone (doesn't have to be the contributor)
     * @param _contributor the address of the contributor
     */
    function claim(address _contributor) external nonReentrant {
        if (fundingStatus == FundingStatus.FUNDING &&
            block.timestamp > fundingEnd &&
            !isBid[fundingNumber]
        ) {
            fundingResult[fundingNumber] = 0;
            fundingStatus = FundingStatus.INACTIVE;
        }
        if (portalFundingStatus == PortalFundingStatus.FUNDING &&
            block.timestamp > portalFundingEnd
        ) {
            portalFundingResult[portalFundingNumber] = 0;
            portalFundingStatus = PortalFundingStatus.INACTIVE;
        }
        require(
            balanceOf(_contributor) > 0, 
            "claim: no tokens to cash out"
        );
        // calculate the amount of fractional NFT tokens owed to the user
        // based on how much GHST they contributed towards the new funding,
        // or the amount of GHST owed to the user if the FrAactionHub deadline is reached
        uint256 sumToken;
        uint256 sumGhst;
        uint256 sumMatic;
        uint256 sumCollateral;
        {
            uint256 contributions;
            if (portalFundingStatus != PortalFundingStatus.INACTIVE &&
                ownerContributedCollateral[_contributor][portalFundingNumber] > 0
            ) {
                contributions = portalFundingContributor[_contributor].length - 1;
            } else {
                contributions = portalFundingContributor[_contributor].length;
            }
            for (uint i = 0; i < contributions; i++) {
                (uint256 tokenAmount, uint256 collateralAmount, address collateralAddress) = 
                    portalCalculateTokensAndGhstOwed(
                        _contributor, 
                        portalFundingResult[portalFundingContributor[_contributor][i]], 
                        portalFundingContributor[_contributor][i]
                    );
                // transfer tokens to contributor for their portion of GHST used
                if (tokenAmount > 0) {
                    sumToken += tokenAmount;
                }
                if (collateralAmount > 0) {
                    uint256 bal = IERC20Upgradeable(collateralAddress).balanceOf(address(this));
                    if (collateralAmount > bal) collateralAmount = bal;
                    ERC20lib.transfer(collateralAddress, _contributor, collateralAmount);
                }
            }
            delete portalFundingContributor[_contributor];
            if (portalFundingStatus != PortalFundingStatus.INACTIVE &&
                ownerContributedCollateral[_contributor][portalFundingNumber] > 0
            ) portalFundingContributor[_contributor].push(portalFundingNumber);
        }
        {
            uint256 fundingLength;
            if (fundingStatus != FundingStatus.INACTIVE &&
                ownerContributedToFunding[_contributor][fundingNumber] > 0
            ) {
                fundingLength = fundingContributor[_contributor].length - 1;
            } else {
                fundingLength = fundingContributor[_contributor].length;
            }
            for (uint i = 0; i < fundingLength; i++) {
                (uint256 tokenAmount, uint256 ghstorMaticAmount) = 
                    calculateTokensOwed(
                        _contributor, 
                        fundingResult[fundingContributor[_contributor][i]], 
                        fundingContributor[_contributor][i]
                    );
                // transfer tokens to contributor for their portion of GHST used
                sumToken += tokenAmount;
                // if the new funding deadline is reached or the repurchase failed then return all the GHST or MATIC to the contributor
                if (ghstorMaticAmount > 0) {
                    if (fundingInGhst[fundingContributor[_contributor][i]]) {
                        sumGhst += ghstAmount;
                    } else {
                        sumMatic += maticAmount;
                    }
                }
            }
            delete fundingContributor[_contributor];
            if (fundingStatus != FundingStatus.INACTIVE &&
                ownerContributedToFunding[_contributor][fundingNumber] > 0
            ) fundingContributor[_contributor].push(fundingNumber);
        }
        if (sumToken > 0) _transferTokens(_contributor, sumToken);
        if (sumGhst > 0) {
            uint256 bal = IERC20Upgradeable(ghstContract).balanceOf(address(this));
            if (sumGhst > ) sumGhst = bal;
            ERC20lib.transfer(ghstContract, _contributor, sumGhst);
        }
        uint256 sum;
        for (uint i = 0; i < collateralAvailable.length; i++) {
            for (uint j = stakeIndex[_contributor][collateralAvailable[i]]; j < redeemedCollateral[collateralAvailable[i]].length; j++) {
                sum += redeemedCollateral[collateralAvailable[i]][j];
            }
            if (sum > 0) {
                if (collateralAvailable[i] == thisContract) {
                    sumMatic += sum * balanceOf(_contributor) / totalSupply();
                } else {
                    uint256 bal = IERC20Upgradeable(collateralAvailable[i]).balanceOf(address(this))
                    uint256 refundedCollateral = sum * balanceOf(_contributor) / totalSupply();
                    if (refundedCollateral > bal) refundedCollateral = bal;
                    ERC20lib.transfer(collateralAvailable[i], _contributor, refundedCollateral);
                }
                emit CollateralRefunded(_contributor, collateralAvailable[i], refundedCollateral);
            }
            stakeIndex[_contributor][collateralAvailable[i]] = redeemedCollateral[collateralAvailable[i]].length;
            sum = 0;
        }
        if (sumMatic > 0) {
            if (sumMatic > address(this).balance) sumMatic = address(this).balance;
            transferMaticOrWmatic(_contributor, sumMatic);
        }
        emit Claimed(
            _contributor,
            sumToken,
            sumGhst,
            sumMatic
        );
        if (finalAuctionStatus == FinalAuctionStatus.ENDED) {
            claimedCounter++;
            burn(_contributor, balanceOf(_contributor));
            if (claimedCounter == ownersAddress.length) {
                claimedCounter = 0;
                if (erc20Tokens.length + nfts.length + erc1155Tokens.length > maxExtTokensLength) {
                    finalAuctionStatus = FinalAuctionStatus.DELETINGTOKENS;
                else {
                    delete erc20Tokens;
                    delete nfts;
                    delete erc1155Tokens;
                    finalAuctionStatus = FinalAuctionStatus.INACTIVE;
                }
                firstRound = true;
            }
        }
    }

    function deleteTokens() external {
        require(
            finalAuctionStatus == FinalAuctionStatus.DELETINGTOKENS, 
            "deleteTokens: no tokens to cash out"
        );
        if (erc20Tokens.length > 0) {
            delete erc20Tokens;
        } else if (nfts.length > 0) {
            delete nfts;
        } else if (erc1155Tokens.length > 0) {
            delete erc1155Tokens;
        } else {
            finalAuctionStatus = FinalAuctionStatus.INACTIVE;
        }
    }

    function claimAll(address _contributor) external nonReentrant {
        uint256 startIndex;
        uint256 endIndex = ownersAddress.length;
        if (split == 0) {
            maxOwnersArrayLength = ISettings(settingsContract).maxOwnersArrayLength();
            if (ownersAddress.length > maxOwnersArrayLength {
                endIndex = maxOwnersArrayLength;
                if (ownersAddress.length % maxOwnersArrayLength > 0) {
                    multiple = ownersAddress.length / maxOwnersArrayLength + 1;
                } else {
                    multiple = ownersAddress.length / maxOwnersArrayLength;
                }
                split = 8;
                splitCounter++;
            }
        } else {
            if (ownersAddress.length % maxOwnersArrayLength > 0 && splitCounter == multiple - 1) {
                startIndex = splitCounter * maxOwnersArrayLength + 1;
                endIndex = ownersAddress.length;
            } else {
                startIndex = splitCounter * maxOwnersArrayLength + 1;
                endIndex = (splitCounter + 1) * maxOwnersArrayLength;
            }
            splitCounter++;
        }
        if (splitCounter == multiple) {
            split = 0;
            splitCounter = 0;
            multiple = 0;
            emit ClaimedAll(address(this));
        }
        if (endIndex > ownersAddress.length) endIndex = ownersAddress.length;
        if (startIndex > ownersAddress.length) return;
        for (uint i = 0; i < ownersAddress.length; i++) {
            claim(ownersAddress[i]);
        }
        feesContributor[msg.sender]++;
        if (feesContributor[msg.sender] == ISettings(settingsContract).feesRewardTrigger()) {
            mint(msg.sender, ISettings(settingsContract).feesReward());
            feesContributor[msg.sender] = 0;
        }
    }    

    // ======== External: Auction funding =========

    function startBid(
        address _auctionTarget, 
        uint256 _quantity,
        uint256 _usedTreasury
    ) external {
        require(
            fundingStatus == FundingStatus.INACTIVE,
            "startBid: FrAactionHub not fractionalized yet"
        );
        require(
            finalAuctionStatus == FinalAuctionStatus.INACTIVE, 
            "startBid: Final auction already started"
        );
        require(
            portalFundingStatus == PortalFundingStatus.INACTIVE,
            "startBid: FrAactionHub already having a new portal funding"
        );
        if (firstRound) {
            require(
                initiator == msg.sender,
                "startBid: not the FrAactionHub initiator"
            );
            fundingStatus = fundingStatus.FUNDING;
        } else {
            require(
                balanceOf(msg.sender) > 0,
                "startBid: not a FrAactionHub owner"
            );
            fundingStatus = fundingStatus.ACTIVE;
        }
        bool inGhst = FraactionInterface(auctionTarget).checkExitTokenType();
        if (inGhst) {
            require(
                _usedTreasury <= totalTreasuryInGhst,
                "startBid: value higher than the current treasury"
            );
            fundingInGhst[fundingNumber] = inGhst;
        } else {
            require(
                _usedTreasury <= totalTreasuryInMatic,
                "startBid: value higher than the current treasury"
            );
        }
        auctionTarget = _auctionTarget;
        fundingNumber++;
        usedTreasury = _usedTreasury;
        totalContributedToFunding = 0;
        isBid[fundingNumber] = true;
        emit StartAuction(auctionTarget);
    }
    
     /**
     * @notice Contribute to the initial bid on another FrAactionHub
     * while the initial funding is still open
     * @dev Emits a ContributedBid event upon success; callable by anyone
     */
    function contributeBid(uint256 _value) external payable nonReentrant {
        require(
            fundingStatus == FundingStatus.FUNDING, 
            "contributeBid: FrAactionHub is not bidding yet"
        );
        if (privateHub) {
            require(
                balanceOf(msg.sender) > 0 ||
                whitelisted[msg.sender], 
                "contributePurchase: user not an owner or whitelisted member of the FrAactionHub"
            );
        }
        uint256 value;
        if (fundingInGhst[fundingNumber]) {
            value = _value;
        } else {
            value = msg.value;
        }
        require(
            value > 0, 
            "contributePurchase: must contribute more than 0"
        );
        contributions[_contributor].push(_contribution);
        if (ownerContributedToFunding[msg.sender][fundingNumber] = 0) fundingContributor[_contributor].push(fundingNumber);
        if (fundingInGhst[fundingNumber]) {
            ownerTotalContributedInGhst[msg.sender] += value;
            currentBalanceInGhst += value;
            ERC20lib.transferFrom(ghstContract, msg.sender, address(this), value);
        } else {
            ownerTotalContributedInMatic[msg.sender] += value;
            currentBalanceInMatic += value;
        }
        ownerContributedToFunding[msg.sender][fundingNumber] += value;
        totalContributedToFunding += value;
        // add contribution to contributor's array of contributions
        Contribution memory _contribution =
            Contribution({
                amount: value,
                previousTotalContributedToFraactionHub: totalContributedToFunding
            });
        emit ContributedAuction(
            _contributor,
            value,
            ownerContributedToFunding[_contributor][fundingNumber]
        );
    }
    
    /**
     * @notice submit the bid to FraactionHub target
     * @dev Emits a SubmitBid event upon success; callable by anyone
     */
    function submitBid() external nonReentrant {
        require(
            fundingStatus == FundingStatus.FUNDING, 
            "submitBid: FrAactionHub is not bidding yet"
        );
        bool checkOpenBid = FraactionInterface(auctionTarget).openForBid();
        uint256 submittedBid = FraactionInterface(auctionTarget).getMinBid();
        ERC20Upgradeable(auctionTarget).approve(auctionTarget, MAX_INT);
        require(
            submittedBid <= _getMaxBid(), 
            "submitBid: bid amount must be less than the maximum bid possible"
        );
        if (checkOpenBid) {
            if (fundingInGhst[fundingNumber]) {
                FraactionInterface(auctionTarget).bid(); 
            } else {
                FraactionInterface(auctionTarget).bid{value: submittedBid}();
            }
        } else {
            if (fundingInGhst[fundingNumber]) {
                FraactionInterface(auctionTarget).startFinalAuction();
            } else {
                FraactionInterface(auctionTarget).startFinalAuction{value: submittedBid}();
            }
        }
        fundingStatus = FundingStatus.SUBMITTED;
        emit SubmitBid(submittedBid);
    }
    
     /**
     * @notice Finalize the state of the initial auction
     * @dev Emits a FinalizedBid event upon success; callable by anyone
     */
    function finalizeBid() external nonReentrant {
        require(
            fundingStatus == FundingStatus.FUNDING ||
            fundingStatus == FundingStatus.SUBMITTED,
            "finalizeBid: initial auction not live"
        );
        require(
            FraactionInterface(auctionTarget).finalAuctionStatus() == FinalAuctionStatus.ENDED,
            "finalizeBid: auction still live"
        );
        ERC20Upgradeable(auctionTarget).approve(auctionTarget, 0);
        fundingStatus = FraactionInterface(auctionTarget).winning() == address(this) ? FundingStatus.COMPLETED : FundingStatus.FAILED;
        uint256 fee;
        // if the purchase was completed,
        if (fundingStatus == FundingStatus.COMPLETED) {
            // transfer the fee to FrAactionDAO
            submittedAmount[fundingNumber] = totalContributedToFunding;
            fee = getFundingFee(submittedBid);
            fundingResult[fundingNumber] = 1;
            if (fundingInGhst[fundingNumber]) {
                ERC20lib.transfer(ghstContract, fraactionDaoMultisig, fee);
                totalContributedToFraactionHubInGhst += totalContributedToFunding;
            } else {
                transferMaticOrWmatic(fraactionDaoMultisig, fee);
                totalContributedToFraactionHubInMatic += totalContributedToFunding;
            }
            if (firstRound == true) {
                // mint fractional ERC-20 tokens
                initializeVault(
                    valueToTokens(totalContributedToFunding, fundingInGhst[fundingNumber]), 
                    totalContributedToFunding, 
                    name, 
                    symbol
                );
                firstRound = false;
            } else {
                mint(address(this), valueToTokens(totalContributedToFunding, fundingInGhst[fundingNumber]));
            }
        } else {
            fundingResult[fundingNumber] = 0;
        }
        fundingStatus = FundingStatus.INACTIVE;
        // set the contract status & emit result
        emit FinalizedBid(auctionStatus, fee, submittedBid);
    }
    
    // ======== External: Portal funding and staking =========

    /**
     * @notice Initiate a new funding round in order to summon the appointed Aavegotchi 
     * @dev Emits a NewAavegotchiFunding event upon success; callable by anyone
     */
    function startPortalFunding(uint256 _tokenId) external {
        require(
            aavegotchi[_tokenId] > 0,
            "startPortalFunding: Aavegotchi not appointed yet by the FrAactionHub owners"
        );
        require(
            finalAuctionStatus == FinalAuctionStatus.INACTIVE, 
            "startPortalFunding: Final auction already started"
        );
        require(
            portalFundingStatus == PortalFundingStatus.INACTIVE ||
            portalFundingStatus == PortalFundingStatus.FRACTIONALIZED,
            "startPortalFunding: FrAactionHub already having a new portal funding"
        );
        require(
            balanceOf(msg.sender) > 0,
            "startPortalFunding: not a FrAactionHub owner"
        );
        portalFundingStatus = PortalStatus.FUNDING;
        portalFundingTarget = _tokenId;
        portalFundingNumber++;
        PortalAavegotchiTraitsIO[] memory portalInfo = DiamondInterface(diamondContract).portalAavegotchiTraits(_tokenId);
        collateralType = portalInfo[aavegotchi[portalFundingTarget]].collateralType;
        maxContribution = portalInfo[aavegotchi[portalFundingTarget]].minimumStake;
        portalFundingEnd = block.timestamp + (ISettings(settingsContract).maxNumberDaysPortalFunding() * 1 days);
        totalContributedToPortalFunding = 0;
        portalFundingStatus = PortalFundingStatus.FUNDING;
        emit PortalFunding(
            _tokenId, 
            _option, 
            collateralType
        );
    }
    
     /**
     * @notice Contribute in order to summon the appointed Aavegotchi 
     * @dev Emits a ContributedAavegotchi event upon success; 
     */
    function contributePortalFunding(uint256 _stakeAmount) external nonReentrant {
        require(
            portalFundingStatus == PortalFundingStatus.FUNDING,
            "contributePortalFunding: FrAactionHub portal funding not active"
        );
        require(
            balanceOf(msg.sender) > 0,
            "contributePortalFunding: not a FrAactionHub owner"
        );
        require(
            block.timestamp <= portalFundingEnd,
            "contributePortalFunding: Aavegotchi funding round expired"
        );
        require(
            totalContributedToPortalFunding + _stakeAmount <= maxContribution,
            "contributePortalFunding: can't contribute more than the gross contribution"
        );
        ERC20lib.transferFrom(collateralType, msg.sender, address(this), _stakeAmount);
        // convert collateral to GHST
        uint256 convertedCollateralToGhst = _stakeAmount * (ISettings(settingsContract).collateralTypeToGhst(collateralType) / 10**8);
        ownerContributedCollateral[msg.sender][portalFundingNumber] += _stakeAmount;
        ownerCollateralType[msg.sender][portalFundingNumber] = collateralType;
        ownerContributedToPortalFunding[msg.sender][portalFundingNumber] += convertedCollateralToGhst;
        totalContributedToPortalFunding += convertedCollateralToGhst;
        ownerTotalContributedInGhst[msg.sender] += convertedCollateralToGhst;
        currentBalanceInGhst += convertedCollateralToGhst;
        portalFundingContributor[msg.sender].push(portalFundingNumber);
        emit ContributedPortalFunding(
            msg.sender,
            collateralType,
            _stakeAmount
        );
    }
    
    /**
     * @notice claim an appointed Aavegotchi
     * @dev Reverts if insufficient funds to claim the Aavegotchi and pay FrAactionDAO fees
     * Emits a Summoned event upon success.
     * Callable by anyone
     */
    function claimAavegotchi() external nonReentrant {
        require(
            portalFundingStatus == PortalFundingStatus.FUNDING,
            "claimAavegotchi: FrAactionHub portal funding not active"
        );
        require(
            maxContribution == totalContributedToPortalFunding,
            "claimAavegotchi: insufficient funds to purchase"
        );
        (bool success, bytes memory returnData) =
            diamondContract.call(
                abi.encodeWithSignature("claimAavegotchi(uint256,uint256,uint256)", 
                portalFundingTarget, 
                aavegotchi[portalFundingTarget], 
                maxContribution
            )
        );
        require(
            success,
            string(
                abi.encodePacked(
                    "claimAavegotchi: claim order failed: ",
                    returnData
                )
            )
        );
        portalFundingStatus = PortalFundingStatus.CLAIMED;
        emit ClaimedAavegotchi(maxContribution);
    }
    
    /**
     * @notice Finalize the state of the Aavegotchi claim
     * @dev Emits a FinalizedAavegotchi event upon success; callable by anyone
     */
    function finalizePortalFunding() external nonReentrant {
        require(
            portalFundingStatus == PortalFundingStatus.CLAIMED,
            "finalizePortalFunding: FrAactionHub Aavegotchi target not claimed yet"
        );
        portalFundingStatus = DiamondInterface(diamondContract).getERC721Category(diamondContract, portalTarget) == 3 ? PortalFundingStatus.COMPLETED: PortalFundingStatus.FUNDING;
        uint256 _fee;
        // if the Aavegotchi claim was completed,
        if (portalFundingStatus == PortalFundingStatus.COMPLETED) {
            // transfer the fee to FrAactionDAO
            _fee = _getFundingFee(totalContributedToPortalFunding);
            ERC20lib.transfer(collateralType, fraactionDaoMultisig, _fee);
            mint(address(this), valueToTokens(totalContributedToPortalFunding));
            portalFundingResult[portalFundingNumber] = 1;
            totalContributedToFraactionHubInGhst += totalContributedToPortalFunding;
        } else {
            portalFundingResult[portalFundingNumber] = 0;
        }
        portalFundingStatus = PortalFundingStatus.INACTIVE;
        // set the contract status & emit result
        emit FinalizedPortalFunding(
            portalFundingStatus, 
            _fee, 
            totalContributedToPortalFunding
        );
    }
    
    // ======== External: final auction =========
    
    /// @notice kick off an auction. 
    function startFinalAuction(uint256 _value) external payable {
        require(
            finalAuctionStatus == FinalAuctionStatus.INACTIVE, 
            "startFinalAuction: no auction starts"
        );
        require(
            fundingStatus == FundingStatus.INACTIVE,
            "startFinalAuction: FrAactionHub already having a new funding"
        );
        require(
            portalFundingStatus == PortalFundingStatus.INACTIVE,
            "startFinalAuction: FrAactionHub already having a new portal funding"
        );
        uint256 value;
        if (exitInGhst) {
            value = _value;
        } else {
            value = msg.value;
        }
        require(
            value >= reservePrice(), 
            "startFinalAuction: too low bid"
        );
        require(
            votingTokens * 1000 >= ISettings(settingsContract).minVotePercentage() * totalSupply(), 
            "startFinalAuction: not enough voters"
        );
        if (exitInGhst) {
            ERC20lib.transferFrom(ghstContract, msg.sender, address(this), value);
            currentBalanceInGhst += value;
        } else {
            currentBalanceInMatic += value;
        }
        auctionEnd = block.timestamp + ISettings(settingsContract).auctionLength();
        finalAuctionStatus = FinalAuctionStatus.ACTIVE;
        livePrice = value;
        winning = msg.sender;
        emit Start(msg.sender, value);
    }

    /// @notice an external function to bid on purchasing the SPDAO assets. The _value is the bid amount
    function bid(uint256 _value) external payable nonReentrant {
        require(
            finalAuctionStatus == FinalAuctionStatus.ACTIVE, 
            "bid: auction is not live"
        );
        uint256 value;
        if (exitInGhst) {
            value = _value;
        } else {
            value = msg.value;
        }
        require(
            value >= minBid(), 
            "bid: too low bid"
        );
        require(
            block.timestamp < auctionEnd, 
            "bid: auction ended"
        );
        if (exitInGhst) {
            ERC20lib.transferFrom(ghstContract, msg.sender, address(this), value);
            ERC20lib.transferFrom(ghstContract, address(this), winning, livePrice);
            currentBalanceInGhst += value - livePrice;
        } else {
            transferMaticOrWmatic(winning, livePrice);
            currentBalanceInMatic += value - livePrice;
        }
        FraactionInterface(winning).notifyOverbid(livePrice);
        // If bid is within 15 minutes of auction end, extend auction
        if (auctionEnd - block.timestamp <= 15 minutes) {
            auctionEnd += 15 minutes;
        }
        livePrice = value;
        winning = msg.sender;
        emit Bid(msg.sender, value);
    }

    /// @notice an external function to end an auction after the timer has run out and transfer all the assets of the FrAactionHub to the winner
    function endFinalAuction(
        uint256[] calldata _extNftsId,  
        uint256[] calldata _ext1155Id,
        uint256[] calldata _ext1155Quantity,
        address[] calldata _extNftsAddress, 
        address[] calldata _ext1155Address
    ) external nonReentrant {
        require(
            finalAuctionStatus == FinalAuctionStatus.ACTIVE, 
            "endFinalAuction: vault has already closed"
        );
        require(
            block.timestamp >= auctionEnd, 
            "endFinalAuction: auction live"
        );
        require(
            _extNftsId.length == _extNftsAddress.length &&
            _ext1155Id.length == _ext1155Quantity.length &&
            _ext1155Quantity.length == _ext1155Address.length,
            "endFinalAuction: each NFT ID needs a corresponding token address"
        );
        if (mergerStatus == MergerStatus.INACTIVE) {
            mergerStatus = MergerStatus.ACTIVE;
            target = winning;
            emit Won(winning, livePrice);
        }
        uint256[] memory realmsId = DiamondInterface(realmsContract).tokenIdsOfOwner(address(this));
        uint32[] memory nftsId = DiamondInterface(diamondContract).tokenIdsOfOwner(address(this));
        ItemIdIO[] memory itemsDiamond = DiamondInterface(diamondContract).itemBalances(address(this));
        uint256[] memory itemsStaking = DiamondInterface(stakingContract).balanceOfAll(address(this));
        bool checkTickets;
        for (uint i = 0; i < itemsStaking.length; i++) {
            if (itemsStaking[i] != 0) {
                checkTickets = true;
                break;
            }
        }
        if (realmsId.length > 0 && split == 0 || split == 1) {
            transferRealms();
        } else if (nftsId.length > 0 && split == 0 || split == 2) {
            transferNfts();
        } else if (itemsDiamond.length > 0 && split == 0 || 
            split == 3 || 
            checkTickets == true
            ) {
            transferItems();
        } else if (_extNftsId.length > 0 && split == 0 || split == 4) {
            transferExternalNfts(_extNftsAddress, _extNftsId);
        } else if (_ext1155Id.length > 0 && split == 0 || split == 5) {
            transferExternal1155(_ext1155Address, _ext1155Id, _ext1155Quantity);
        } else if (_extErc20Value.length > 0 && split == 0 || split == 6) {
            transferExternalErc20(_extErc20Address, _extErc20Value);
        } else {
            if (totalNumberExtAssets != extAssetsTansferred) return;
            if (totalTreasuryInGhst > 0) ERC20lib.transferFrom(ghstContract, address(this), target, totalTreasuryInGhst);
            if (totalTreasuryInMatic > 0) transferMaticOrWmatic(target, totalTreasuryInMatic);
            totalTreasuryInGhst = 0;
            totalTreasuryInMatic = 0;
            mergerStatus = MergerStatus.INACTIVE;
            finalAuctionStatus = FinalAuctionStatus.ENDED;
            uint256 bal = ERC20Upgradeable(ghstContract).balanceOf(address(this));
            residualGhst = bal - currentBalanceInGhst;
            residualMatic = address(this).balance - currentBalanceInMatic;
            if (exitInGhst) {
                redeemedCollateral[ghstContract].push(livePrice + residualGhst);
                if (collateralToRedeem[ghstContract] == 0) {
                    collateralToRedeem[ghstContract] = true;
                    collateralAvailable.push(ghstContract);
                }
            } else {
                redeemedCollateral[thisContract].push(livePrice + residualMatic);
                if (collateralToRedeem[thisContract] == 0) {
                    collateralToRedeem[thisContract] = true;
                    collateralAvailable.push(thisContract);
                }
            }
            emit MergerFinalized(target);
        }
    }
    
    function notifyOverbid(uint256 _value) external {
        require(
            msg.sender == auctionTarget, 
            "notifyOverbid: caller not the auction target"
        );
        if (fundingInGhst[fundingNumber]) {
            totalTreasuryInGhst += _value;
        } else {
            totalTreasuryInMatic += _value;
        }
        fundingStatus = FundingStatus.FUNDING;
        emit Overbidden(msg.sender);
    }
    // ======== External: final functions =========
    
    /// @notice an external function to burn all the FrAactionSPDAO ERC20 tokens to receive the ERC721 and (if any) ERC1155/ERC20 tokens
    function redeem() external nonReentrant {
        require(
            finalAuctionStatus == FinalAuctionStatus.INACTIVE, 
            "redeem: no auction starts"
        );
        require(
            fundingStatus == FundingStatus.INACTIVE,
            "redeem: FrAactionHub already having a new funding"
        );
        require(
            portalFundingStatus == PortalFundingStatus.INACTIVE,
            "redeem: FrAactionHub already having a new portal funding"
        );
        require(
            balanceOf(msg.sender) == totalSupply(),
            "redeem: caller do not own the entire token supply"
        );
        require(
            mergerStatus == MergerStatus.INACTIVE ||
            msg.sender == target, 
            "redeem: merger is active"
        );
        require(
            demergerStatus == DemergerStatus.INACTIVE, 
            "redeem: demerger is active"
        );
        if (mergerStatus == MergerStatus.INACTIVE) {
            target = msg.sender;
            mergerStatus = MergerStatus.ACTIVE
            emit MergerInitiated(target);
        }
        uint256[] memory realmsId = DiamondInterface(realmsContract).tokenIdsOfOwner(address(this));
        uint32[] memory nftsId = DiamondInterface(diamondContract).tokenIdsOfOwner(address(this));
        ItemIdIO[] memory itemsDiamond = DiamondInterface(diamondContract).itemBalances(address(this));
        uint256[] memory itemsStaking = DiamondInterface(stakingContract).balanceOfAll(address(this));
        bool checkTickets;
        for (uint i = 0; i < itemsStaking.length; i++) {
            if (itemsStaking[i] != 0) {
                checkTickets = true;
                    break;
            }
        }
        if (realmsId.length > 0 && split == 0 || split == 1) {
            transferRealms();
        } else if (nftsId.length > 0 && split == 0 || split == 2) {
            transferNfts();
        } else if (
            itemsDiamond.length > 0 && split == 0 || 
            split == 3 || 
            checkTickets == true
            ) 
        {
            transferItems();
        } else if (!extNftsTransferred || split = 4) {
            transferExternalNfts();
            if (split == 0) extNftsTransferred = true;
        } else if (!ext1155Transferred || split = 5) {
            transferExternal1155();
            if (split == 0) ext1155Transferred = true;
        } else if (!extErc20Transferred || split = 6) {
            transferExternalErc20();
            if (split == 0) extErc20Transferred = true; 
        } else {
            extNftsTransferred = false;
            ext1155Transferred = false;
            extErc20Transferred = false;
            if (totalNumberExtAssets != extAssetsTansferred) return;
            uint256 bal = ERC20Upgradeable(ghstContract).balanceOf(address(this));
            if (bal > 0) ERC20lib.transferFrom(ghstContract, address(this), msg.sender, bal);
            if (address(this).balance > 0) transferMaticOrWmatic(msg.sender, address(this).balance);
            _burn(msg.sender, totalSupply());
            mergerStatus == MergerStatus.INACTIVE;
            emit Redeemed(msg.sender);
        }
    }
    
    // ======== External: staking functions =========
    
    /// @notice an external function to increase an Aavegotchi staked collateral amount
    function contributeStaking(uint256 _tokenId, uint256 _stakeAmount) external nonReentrant {
        require(
            balanceOf(msg.sender) > 0,
            "contributeStaking: not a FrAactionHub owner"
        );
        require(
           _stakeAmount > 0,
            "contributeStaking: staked amount must be greater than 0"
        );
        require(
            finalAuctionStatus == FinalAuctionStatus.INACTIVE, 
            "contributeStaking: an auction is live"
        );
        stakingContributor = msg.sender;
        address collateral = DiamondInterface(diamondContract).collateralBalance(_tokenId).collateralType_;
        uint256 stakeToGhst = ISettings(settingsContract).collateralTypeToGhst(collateral);
        uint256 convertedCollateralToGhst = _stakeAmount * (stakeToGhst / 10**8);
        ownerTotalContributed[stakingContributor] += convertedCollateralToGhst;
        totalContributedToFraactionHubInGhst += convertedCollateralToGhst;
        ERC20lib.transferFrom(collateral, stakingContributor, address(this), _stakeAmount);
        mint(stakingContributor, valueToTokens(convertedCollateralToGhst));
        emit ContributedStaking(stakingContributor, _tokenId, _stakeAmount);
        (bool success, bytes memory returnData) =
            diamondContract.call(
                abi.encodeWithSignature("increaseStake(uint256,uint256)", 
                _tokenId, 
                _stakeAmount
            )
        );
        require(
            success,
            string(
                abi.encodePacked(
                    "increaseStake: staking order failed: ",
                    returnData
                )
            )
        );
        emit StakeIncreased(
            stakingContributor, 
            _tokenId, 
            _stakeAmount,
            convertedCollateralToGhst
        );
    }
    
    // ======== External: Aavegotchi GHST claiming function =========
    
    function claimAavegotchiGhst(uint256 _tokenId, uint256 _ghstAmount) external nonReentrant {
        require(
            balanceOf(msg.sender) > 0,
            "claimAavegotchiGhst: not a FrAactionHub owner"
        );
        require(
            _ghstAmount < DiamondInterface(diamondContract).escrowBalance(_tokenId, ghstContract),
            "claimAavegotchiGhst: not enough GHST tokens in the escrow"
        );
        (bool success, bytes memory returnData) =
            diamondContract.call(
                abi.encodeWithSignature("transferEscrow(uint256,address,address,uint256)", 
                _tokenId, 
                ghstContract,
                this.address,
                _ghstAmount
            )
        );
        require(
            success,
            string(
                abi.encodePacked(
                    "claimAavegotchiGhst: staking order failed: ",
                    returnData
                )
            )
        );
        currentBalanceInGhst += _ghstAmount;
        redeemedCollateral[ghstContract].push(_ghstAmount);
        if (collateralToRedeem[ghstContract] == 0) {
            collateralToRedeem[ghstContract] = true;
            collateralAvailable.push(ghstContract);
        }
        emit ClaimedAavegotchiGhst(_tokenId, _ghstAmount);
    }

    // ======== External: Emergency Escape Hatches (FrAactionDAO Multisig Only) =========
    
     /**
     * @notice Escape hatch: in case of emergency,
     * FrAactionDAO can use forceFinalized to force a 
     * final contract status to allow contributors
     * to access all the contract functions and 
     * let them claim their funds back
     */
    
     function forceFinalized() 
         external
         onlyFraactionDao
    {
        fundingStatus = FundingStatus.INACTIVE;
        mergerStatus = MergerStatus.INACTIVE;
        demergerStatus = DemergerStatus.INACTIVE;
        portalFundingStatus = PortalFundingStatus.INACTIVE;
        finalAuctionStatus = FinalAuctionStatus.INACTIVE;
    }

    /**
     * @notice Escape hatch: in case of emergency,
     * FrAactionDAO can use emergencyWithdrawGhst to withdraw
     * GHST stuck in the contract
     */
    function emergencyWithdrawGhst(uint256 _value)
        external
        onlyFraactionDao
    {
        ERC20lib.transfer(diamondContract, fraactionDaoMultisig, _value);
    }

    /**
     * @notice Escape hatch: in case of emergency,
     * FrAactionAO can use emergencyCall to call an external contract
     * (e.g. to withdraw a stuck NFT or stuck ERC-20s)
     */
    function emergencyCall(address _contract, bytes memory _calldata)
        external
        onlyFraactionDao
        returns (bool _success, bytes memory _returnData)
    {
        (_success, _returnData) = _contract.call(_calldata);
        require(_success, string(_returnData));
    }

    // ======== Public: Utility Calculations =========

    /**
     * @notice Convert GHST value to equivalent token amount
     */
    function valueToTokens(uint256 _value)
        public
        pure
        returns (uint256 _tokens)
    {
        _tokens = _value * TOKEN_SCALE;
    }

    // ============ Internal: Price and fees ============
    
     /**
     * @notice The gross price to be submitted
     * during the funding round and including 
     * the fee for FrAactionDAO
     * @return _grossPrice the submitted price
     */
    function getFundingGrossPrice() internal view returns (uint256 _grossPrice) {
        if (isNft == true) {
            _grossPrice = priceInWei * (1000 + ISettings(settingsContract).fundingFee()) / 1000;
        } else {
            _grossPrice = priceInWei * quantity * (1000 + ISettings(settingsContract).fundingFee()) / 1000;
        }
    }
    
    /**
     * @notice Calculate funding fee for FrAactionDAO
     */
    function getFundingFee(uint256 _amount) internal view returns (uint256 _fee) {
        _fee = _amount * ISettings(settingsContract).fundingFee() / 1000;
    }
    
       /**
     * @notice The maximum bid to be submitted
     * while leaving the fee for FrAactionDAO
     * @return _maxBid the maximum submitted bid
     */
    function getMaxBid() internal view returns (uint256 _maxBid) {
       _maxBid = ((totalContributedToFunding + usedTreasury) * 1000) / (1000 + ISettings(settingsContract).fundingFee());
    }
   
    // ============ Internal: claim ============

    /**
     * @notice Calculate the amount of fractional NFT tokens owed to the contributor
     * based on how much GHST or MATIC they contributed towards the funding round
     * @param _contributor the address of the contributor
     * @return _tokenAmount the amount of fractional NFT tokens owed to the contributor
     * @return _GhstAmount the amount of GHST or MATIC owed to the contributor
     */
    function calculateTokensOwed(
        address _contributor, 
        bool _successFunding, 
        uint256 _fundingNumber
    )
        internal
        view
        returns (uint256 _tokenAmount, uint256 _ghstOrMaticAmount)
    {
        uint256 contribution = ownerContributedToFunding[_contributor][_fundingNumber];
        if (contribution > 0) {
            if (_successFunding == true) {
                if (isBid(_fundingNumber)) {
                    uint256 _totalUsedForBid = _totalGhstOrMaticUsedForBid(_contributor, _fundingNumber);
                    if (_totalUsedForBid > 0) {
                        _tokenAmount = valueToTokens(_totalUsedForBid);
                    }
                    // the rest of the contributor's GHST or MATIC should be returned
                    _ghstOrMaticAmount = contribution - _totalUsedForBid;
                } else {
                    _tokenAmount = valueToTokens(contribution);
                }
                if (newOwner[_contributor] == true) {
                    ownersAddress.push(_contributor);
                    newOwner[_contributor] = false;
                }
            } else {
                // if the new funding was not completed before the deadline of 7 days from the contract deployement or the new funding failed, no GHST or MATIC was spent;
                // all of the contributor's GHST or MATIC for this last new funding round should be returned
                _ghstOrMaticAmount = contribution;
                if (fundingInGhst[_fundingNumber]) {
                    ownerTotalContributedInGhst[_contributor] -= _ghstOrMaticAmount;
                    currentBalanceInGhst -= _ghstOrMaticAmount;
                } else {
                    ownerTotalContributedInMatic[_contributor] -= _ghstOrMaticAmount;
                    currentBalanceInMatic -= _ghstOrMaticAmount;
                }
            }
        }
    }
    
    /**
     * @notice Calculate the amount of fractional NFT tokens owed to the contributor
     * based on how much GHST they contributed towards the new Aavegotchi portal funding round
     * @param _contributor the address of the contributor
     * @return _tokenAmount the amount of fractional NFT tokens owed to the contributor
     * @return _GhstAmount the amount of GHST owed to the contributor
     */
     function portalCalculateTokensOwed(
        address _contributor, 
        bool _successPortalFunding, 
        uint256 _portalFundingNumber
    )
        internal
        view
        returns (uint256 _tokenAmount, uint256 _collateralAmount, address _collateralType)
    {
        uint256 contribution = ownerContributedToPortalFunding[_contributor][_portalFundingNumber];
        if (contribution > 0) {  
            if (_successPortalFunding == true) {
                _tokenAmount = valueToTokens(contribution);
            } else {
                _collateralAmount = ownerContributedCollateral[_contributor][_portalFundingNumber];
                _collateralType = ownerCollateralType[_contributor][_portalFundingNumber];
                ownerTotalContributedInGhst[_contributor] -= contribution;
                currentBalanceInGhst -= contribution;
            }
        }
    }
    
    /**
     * @notice Calculate the total amount of a contributor's funds that were
     * used towards the winning auction bid
     * @param _contributor the address of the contributor
     * @return _total the sum of the contributor's funds that were
     * used towards the winning auction bid
     */
    function totalGhstOrMaticUsedForBid(address _contributor, _fundingNumber)
        internal
        view
        returns (uint256 _total)
    {
        // get all of the contributor's contributions
        Contribution[] memory _contributions = contributions[_contributor];
        for (uint256 i = 0; i < _contributions.length; i++) {
            // calculate how much was used from this individual contribution
            uint256 _amount = ghstOrMaticUsedForBid(_contributions[i], _fundingNumber);
            // if we reach a contribution that was not used,
            // no subsequent contributions will have been used either,
            // so we can stop calculating to save some gas
            if (_amount == 0) break;
            _total = _total + _amount;
        }
    }

    /**
     * @notice Calculate the amount that was used towards
     * the winning auction bid from a single Contribution
     * @param _contribution the Contribution struct
     * @return the amount of funds from this contribution
     * that were used towards the winning auction bid
     */
    function ghstOrMaticUsedForBid(Contribution memory _contribution, uint256 _fundingNumber)
        internal
        view
        returns (uint256)
    {
        if (
            _contribution.previousTotalContributedToFraactionHub + _contribution.amount <= submittedAmount[_fundingNumber]
        ) {
            // contribution was fully used
            return _contribution.amount;
        } else if (
            _contribution.previousTotalContributedToFraactionHub < submittedAmount[_fundingNumber]
        ) {
            // contribution was partially used
            return _totalSpent - _contribution.previousTotalContributedToFraactionHub;
        }
        // contribution was not used
        return 0;
    }
    
    // ============ Internal: TransferTokens ===================

    /**
    * @notice Transfer tokens to a recipient
    * @param _to recipient of tokens
    * @param _value amount of tokens
    */
    function transferTokens(address _to, uint256 _value) internal {
        // guard against rounding errors;
        // if token amount to send is greater than contract balance,
        // send full contract balance
        uint256 _fraactionBalance = balanceOf(address(this));
        if (_value > _fraactionBalance) {
            _value = _fraactionBalance;
        }
        transfer(_to, _value);
    }

    // ============ Internal: ConvertTreasuryTokens ====================

    function convertTreasuryTokens(bool _maticInGhst, uint256 _amount, address[] _path) internal {
        require(
            _amount > 0 &&
            _path.length == 3,
            "convertTreasuryTokens: converted amount has to be positive and path length equal to 3"
        );
        uint256[] memory amountOut = getAmountsOut(_path);
        if (_maticInGhst) {
            require(
                _path[0] == wrappedMaticContract && 
                totalTreasuryInMatic >= _amount,
                "convertTreasuryTokens: not enough Matic or wrong path parameter"
            );
            uint256 initialGhstBal = IERC20Upgradeable(ghstContract).balanceOf(address(this));
            QuickSwapInterface(quickSwapRouterContract).swapExactETHForTokensSupportingFeeOnTransferTokens(amountOut[2], _path, address(this), block.timestamp){value: _amount};
            uint256 postGhstBal = IERC20Upgradeable(ghstContract).balanceOf(address(this));
            require(
                postGhstBal - initialGhstBal > 0,
                "convertTreasuryTokens: GHST balance has to increase"
            );
            totalTreasuryInMatic -= _amount;
            currentBalanceInMatic -= _amount;
            totalContributedToFraactionHubInGhst += postGhstBal - initialGhstBal;
            currentBalanceInGhst += postGhstBal - initialGhstBal;
        } else {
            require(
                _path[0] == wrappedMaticContract && 
                totalTreasuryInMatic >= _amount,
                "convertTreasuryTokens: not enough Matic or wrong path parameter"
            );
            uint256 initialGhstBal = IERC20Upgradeable(ghstContract).balanceOf(address(this));
            QuickSwapInterface(quickSwapRouterContract).swapExactETHForTokensSupportingFeeOnTransferTokens(amountOut[2], _path, address(this), block.timestamp){value: _amount};
            uint256 postGhstBal = IERC20Upgradeable(ghstContract).balanceOf(address(this));
            require(
                postGhstBal - initialGhstBal > 0,
                "convertTreasuryTokens: GHST balance has to increase"
            );
            totalTreasuryInMatic -= _amount;
            currentBalanceInMatic -= _amount;
            totalContributedToFraactionHubInGhst += postGhstBal - initialGhstBal;
            currentBalanceInGhst += postGhstBal - initialGhstBal;
        }
        emit ConvertedTreasuryTokens(_maticInGhst, _amount, amountOut[2]);
    }

    // ============ Internal: TransferMaticOrWmatic ============

    /**
     * @notice Attempt to transfer MATIC to a recipient;
     * if transferring MATIC fails, transfer WMATIC insteads
     * @param _to recipient of MATIC or WMATIC
     * @param _value amount of MATIC or WMATIC
     */
    function transferMaticOrWmatic(address _to, uint256 _value) internal {
        // skip if attempting to send 0 MATIC
        if (_value == 0) {
            return;
        }
        // guard against rounding errors;
        // if MATIC amount to send is greater than contract balance,
        // send full contract balance
        if (_value > address(this).balance) {
            _value = address(this).balance;
        }
        // Try to transfer MATIC to the given recipient.
        if (!maticTransfer(_to, _value)) {
            // If the transfer fails, wrap and send as WMATIC
            wrappedMaticContract.deposit{value: _value}();
            wrappedMaticContract.transfer(_to, _value);
            // At this point, the recipient can unwrap WMATIC.
        }
    }

    /**
     * @notice Attempt to transfer MATIC to a recipient
     * @dev Sending MATIC is not guaranteed to succeed
     * this method will return false if it fails.
     * We will limit the gas used in transfers, and handle failure cases.
     * @param _to recipient of MATIC
     * @param _value amount of MATIC
     */
    function maticTransfer(address _to, uint256 _value)
        internal
        returns (bool)
    {
        // Here increase the gas limit a reasonable amount above the default, and try
        // to send MATIC to the recipient.
        // NOTE: This might allow the recipient to attempt a limited reentrancy attack.
        (bool success, ) = _to.call{value: _value, gas: 40000}("");
        return success;
    }
}