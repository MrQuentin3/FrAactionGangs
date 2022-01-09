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
    
    // All state variables located in FrAactionSPDAO.sol
    
    // ============ Diamond Interface variables ============
    
    // Interface variables with the Aavegotchi Diamond contract
    ERC721Listing internal diamond;
    ERC1155Listing internal diamondItem;
  
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
        fraactionDaoMultisig = _fraactionDaoMultisig;
        diamondContract = 0x86935F11C86623deC8a25696E1C19a8659CbF95d;
        ghstContract = 0x385eeac5cb85a38a9a07a70c73e0a3271cfb54a7;
        stakingContract = 0xA02d547512Bb90002807499F05495Fe9C4C3943f;
        realmsContract = 0x1D0360BaC7299C86Ec8E99d0c1C9A95FEfaF2a11;
        rafflesContract = 0x6c723cac1E35FE29a175b287AE242d424c52c1CE;
        marketContract = ;
        settingsContract = ;
        wrappedMaticContract = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
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
    
    // ======== External: Funding =========

    function startFundraising(bool _inGhst) external {
        require(
            balanceOf(msg.sender) > 0,
            "startFundraising: not a FrAactionHub owner"
        );
        require(
            fundingStatus == FundingStatus.INACTIVE,
            "startFundraising: FrAactionHub not fractionalized yet"
        );
        require(
            finalAuctionStatus == FinalAuctionStatus.INACTIVE, 
            "startFundraising: Final auction already started"
        );
        require(
            portalStatus == PortalStatus.INACTIVE,
            "startFundraising: FrAactionHub already having a new portal funding"
        );
        if (_inGhst) fundraisingInGhst = _inGhst;
        if (balanceOf(address(this)) == 0) {
            if (fundraisingInGhst) exitInGhst = true;
        }
        fundingTime = block.timestamp;
        fundingStatus = fundingStatus.ACTIVE;
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
            fundingStatus == FundingStatus.ACTIVE ||
            auctionStatus == AuctionStatus.ACTIVE, 
            "confirmFunding: fundraising or auction not active"
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
        if (block.timestamp > FundingTime + (ISettings(settingsContract).maxNumberDaysFunding() * 1 days)) {
            fundingStatus = fundingStatus.INACTIVE;
            if (fundraisingInGhst) fundraisingInGhst = 0;
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
                totalTreasuryInGhst += _value;
                totalContributedToFunding += _value;
                mint(msg.sender, valueToTokens(_value));
                emit ContributedFundraising(msg.sender, _value);
            } else {
                require(
                    msg.value > 0, 
                    "contributeFundraising: must contribute more than 0"
                );
                ownerTotalContributedInMatic[_contributor] += msg.value;
                totalContributedToFraactionHubInMatic += msg.value;
                totalTreasuryInMatic += msg.value;
                totalContributedToFunding += msg.value;
                mint(msg.sender, valueToTokens(msg.value));
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
        if (firstRound == true && 
            fundingNumber > 0 &&
            fundingResult[fundingNumber] == 0 &&
            allClaimed == false
        ) {
            require(
                allClaimed == true, 
                "startPurchase: tokens have to be claimed to restart the first funding"
            );
        }
        require(
            fundingStatus == FundingStatus.INACTIVE,
            "startPurchase: funding already active"
        );
        require(
            finalAuctionStatus == FinalAuctionStatus.INACTIVE, 
            "startPurchase: Final auction already started"
        );
        require(
            balanceOf(msg.sender) > 0,
            "startPurchase: not a FrAactionHub owner"
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
        if (_usedTreasury > 0) usedTreasury = _usedTreasury;
        if (_baazaarPurchase) fromBaazaar = true;
        listingId = _listingId;
        if (fromBaazaar) {
            isNft = _isNft;
            if (isNft == true) {
                diamond = DiamondInterface(diamondContract).getERC721Listing(listingId);
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
                diamondItem = DiamondInterface(diamondContract).getERC1155Listing(listingId);
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
        if (balanceOf(address(this)) == 0) {
            if (fundingInGhst[fundingNumber]) exitInGhst = true;
        }
        fundingTime = block.timestamp;
        totalContributedToFunding = 0;
        fundingStatus = fundingStatus.ACTIVE;
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
            block.timestamp <= FundingTime + (ISettings(settingsContract).maxNumberDaysFunding() * 1 days),
            "contributePurchase: funding round expired"
        );
         require(
            balanceOf(msg.sender) > 0,
            "contributePurchase: not a FrAactionHub contributor"
        );
        uint256 value;
        if (fundingInGhst) {
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
        if (fundingInGhst && !fromBaazaar ||
            fromBaazaar
        ) {
            ownerTotalContributedInGhst[msg.sender] += _value;
            totalContributedToFraactionHubInGhst += _value;
            ERC20lib.transferFrom(ghstContract, msg.sender, address(this), _value);
        } else {
            ownerTotalContributedInMatic[msg.sender] += msg.value;
            totalContributedToFraactionHubInMatic += msg.value;
        }
        ownerContributedToFunding[msg.sender][fundingNumber] += value;
        totalContributedToFunding += value;
        require(
            totalContributedToFunding + value <= getFundingGrossPrice() - usedTreasury,
            "contributePurchase: cannot contribute more than the gross price"
        );
        if (ownerContributedToFunding[msg.sender][fundingNumber] = 0) contributorFunding.push(fundingNumber);  
        fundingContributor[msg.sender].push(fundingNumber);
        claimed[msg.sender] = false;
        if (allClaimed == true) allClaimed = false;
        if (GangInterface().FraactionGangster[msg.sender] == true) newOwner[msg.sender] == true;
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
        require(
            block.timestamp > fundingTime + (ISettings(settingsContract).minNumberDaysFunding() * 1 days),
            "purchase: funding round minimum duration not reached"
        );
        if (fromBaazaar) {
            if (isNft == true) {
                // ensure there is enough GHST to order the purchase including FrAactionDAO fee
                require(
                    priceInWei == getFundingNetPrice(),
                    "purchase: insufficient funds to purchase"
                );
                // submit the purchase order to the ERC721marketplaceFacet smart contract
                (bool success, bytes memory returnData) =
                    diamondContract.call(
                        abi.encodeWithSignature("executeERC721Listing(uint256)", 
                        listingId
                    )
                );
            } else {
                // ensure there is enough GHST to order the purchase including FrAactionDAO fee
                require(
                    priceInWei * quantity == getFundingNetPrice(),
                    "purchase: insufficient funds to purchase"
                );
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
    function finalize() external nonReentrant {
        require(
            fundingStatus == fundingStatus.SUBMITTED,
            "finalize: funding target not purchased"
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
            // transfer the fee to FrAactionDAO
            fee = _getFundingFee(totalContributedToFunding);
            ERC20lib.transfer(ghstContract, fraactionDaoMultisig, fee);
            if (firstRound == true) {
                // mint fractional ERC-20 tokens
                initializeVault(
                    valueToTokens(totalContributedToFraactionHub), 
                    totalContributedToFraactionHub, 
                    name, 
                    symbol
                );
            } else {
                mint(address(this), valueToTokens(totalContributedToFunding));
            }
            numberOfAssets++;
            fundingResult[fundingNumber] = 1;
            if (firstRound == true) firstRound = false;
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
            block.timestamp > fundingTime + (ISettings(settingsContract).maxNumberDaysFunding() * 1 days
        ) {
            fundingResult[fundingNumber] = 0;
            fundingStatus = FundingStatus.FRACTIONALIZED;
        }
        require(
            fundingStatus == FundingStatus.FRACTIONALIZED,
            "claim: FrAactionHub still having a funding"
        );
        require(
            portalStatus == PortalStatus.INACTIVE,
            "claim: FrAactionHub still having an Aavegotchi funding"
        );
        require(claimed[_contributor] == false,
            "claim: already claimed"
        );
        // calculate the amount of fractional NFT tokens owed to the user
        // based on how much GHST they contributed towards the new funding,
        // or the amount of GHST owed to the user if the FrAactionHub deadline is reached
        uint256 sumToken;
        uint256 sumGhst;
        uint256 sumCollateral;
        {
            uint256 portalLength;
            if (portalStatus != PortalStatus.INACTIVE &&
                ownerContributedCollateral[msg.sender][aavegotchiNumber] > 0
            ) {
                portalLength = portalContributor[_contributor].length - 1;
            } else {
                portalLength = portalContributor[_contributor].length;
            }
            for (uint i = 0; i < portalLength; i++) {
                (uint256 tokenAmount, uint256 collateralAmount, address collateralAddress) = 
                    _portalCalculateTokensAndGhstOwed(
                        _contributor, 
                        portalResult[portalContributor[_contributor][i]], 
                        portalContributor[_contributor][i]
                    );
                // transfer tokens to contributor for their portion of GHST used
                if (tokenAmount > 0) {
                    sumToken += tokenAmount;
                }
                if (collateralAmount > 0) {
                    if (collateralAmount > IERC20Upgradeable(collateralAddress).balanceOf(address(this))) collateralAmount = IERC20Upgradeable(collateralAddress).balanceOf(address(this));
                    ERC20lib.transfer(collateralAddress, _contributor, collateralAmount);
                }
            }
            if (portalStatus != PortalStatus.INACTIVE &&
                ownerContributedToFunding[_contributor][fundingNumber] &&
                portalLength > 0
            ) {
                delete portalContributor[_contributor];
                portalContributor[_contributor].push(portalNumber);
            }
        }
        {
            uint256 fundingLength;
            if (fundingStatus != FundingStatus.INACTIVE &&
                ownerContributedCollateral[msg.sender][aavegotchiNumber] > 0
            ) {
                fundingLength = fundingContributor[_contributor].length - 1;
            } else {
                fundingLength = fundingContributor[_contributor].length;
            }
            for (uint i = 0; i < fundingLength; i++) {
                (uint256 tokenAmount, uint256 ghstAmount) = 
                    _calculateTokensAndGhstOwed(
                        _contributor, 
                        fundingResult[fundingContributor[_contributor][i]], 
                        fundingContributor[_contributor][i]
                    );
                // transfer tokens to contributor for their portion of GHST used
                if (tokenAmount > 0) {
                    sumToken += tokenAmount;
                }
                // if the new funding deadline is reached or the repurchase failed then return all the GHST to the contributor
                if (ghstAmount > 0) {
                    sumGhst += ghstAmount;
                }
            }
            if (portalStatus != PortalStatus.INACTIVE &&
                ownerContributedToFunding[_contributor][fundingNumber] &&
                fundingLength > 0
            ) {
                delete fundingContributor[_contributor];
                fundingContributor[_contributor].push(fundingNumber);
            }
        }
        if (sumToken > 0) _transferTokens(_contributor, sumToken);
        if (sumGhst > 0) {
            if (sumGhst > IERC20Upgradeable(ghstContract).balanceOf(address(this))) sumGhst = IERC20Upgradeable(ghstContract).balanceOf(address(this));
            ERC20lib.transfer(ghstContract, _contributor, sumGhst);
        }
        emit Claimed(
            _contributor,
            sumToken,
            sumGhst,
        );
        uint256 sum;
        for (uint i = 0; i < collateralAvailable.length; i++) {
            for (uint j = stakeIndex[_contributor][collateralAvailable[i]]; j < redeemedCollateral[collateralAvailable[i]].length; j++) {
                sum += redeemedCollateral[collateralAvailable[i]][j];
            }
            if (sum > 0) {
                uint256 refundedCollateral = collateralAvailable[i] * balanceOf(_contributor) / totalSupply() ;
                if (refundedCollateral > IERC20Upgradeable(collateralAvailable[i]).balanceOf(address(this))) refundedCollateral = IERC20Upgradeable(collateralAvailable[i]).balanceOf(address(this));
                ERC20lib.transfer(collateralAvailable[i], _contributor, refundedCollateral);
                emit CollateralRefunded(_contributor, collateralAvailable[i], refundedCollateral);
            }
            stakeIndex[_contributor][collateralAvailable[i]] = i;
            sum = 0;
        }
        claimed[_contributor] = true;
        bool noneClaimed;
        for (uint i = 0; i < ownersAddress.length; i++) {
            if (claimed[ownersAddress[i]] == false) {
                claimed = true;
                break;
            }
        }
        if (noneClaimed == false) allClaimed = true;
    }

    function claimAll(address _contributor) external nonReentrant {
        require(
            fundingStatus == FundingStatus.FRACTIONALIZED,
            "claimAll: FrAactionHub still having a funding"
        );
        require(
            portalStatus == PortalStatus.INACTIVE,
            "claimAll: FrAactionHub still having an Aavegotchi funding"
        );
        require(
            !allClaimed,
            "claimAll: already all claimed"
        );
        uint256 max = ISettings(settingsContract).maxOwnersArrayLength();
        uint256 startIndex = 0;
        uint256 endIndex = ownersAddress.length;
        if (split == false) {
            if (ownersAddress.length > max) {
                if (ownersAddress.length % max > 0) {
                    multiple = ownersAddress.length / max + 1;
                } else {
                    multiple = ownersAddress.length / max;
                }
                split = true;
                startIndex = splitCounter * max;
                endIndex = (splitCounter + 1) * max;
            }
        } else {
            if (ownersAddress.length % max > 0) {
                if (splitCounter < multiple - 1) {
                    startIndex = splitCounter * max + 1;
                    endIndex = (splitCounter + 1) * max;
                } else {
                    startIndex = splitCounter * max + 1;
                    endIndex = ownersAddress.length;
                }
            } else {
                startIndex = splitCounter * max + 1;
                endIndex = (splitCounter + 1) * max;
            }
            splitCounter++;
            if (splitCounter == multiple) {
                split = false;
                splitCounter = 0;
                multiple = 0;
                allClaimed = true;
                emit ClaimedAll(address(this));
            }
        }
        if (endIndex > ownersAddress.length) endIndex = ownersAddress.length;
        if (startIndex > ownersAddress.length) return;
        for (uint i = 0; i < ownersAddress.length; i++) {
            claim(ownerAddress[i]);
            if (allClaimed) break;
        }
        if (splitCounter == 0 && split == false) {
            allClaimed = true;
            emit ClaimedAll(address(this));
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
        if (firstRound == true && 
            fundingNumber > 0 &&
            fundingResult[fundingNumber] == 0 &&
            allClaimed == false
        ) {
            require(
                allClaimed == true, 
                "startBid: tokens have to be claimed to restart the first funding"
            );
        }
        require(
            _usedTreasury <= totalTreasury,
            "startBid: value higher than the current treasury"
        );
        require(
            fundingStatus == FundingStatus.INACTIVE,
            "startBid: FrAactionHub not fractionalized yet"
        );
        require(
            auctionStatus == AuctionStatus.INACTIVE, 
            "startBid: Final auction already started"
        );
        require(
            portalStatus == PortalStatus.INACTIVE,
            "startBid: FrAactionHub already having a new portal funding"
        );
        require(
            balanceOf(msg.sender) > 0,
            "startBid: not a FrAactionHub owner"
        );
        auctionTarget = _auctionTarget;
        fundingNumber++;
        usedTreasury = _usedTreasury;
        fundingTime = block.timestamp;
        totalContributedToFunding = 0;
        fundingStatus = FundingStatus.ACTIVE;
        emit StartAuction(auctionTarget);
    }
    
     /**
     * @notice Contribute to the initial bid on another FrAactionHub
     * while the initial funding is still open
     * @dev Emits a ContributedBid event upon success; callable by anyone
     */
    function contributeBid(uint256 _value) external nonReentrant {
        require(
            fundingStatus == FundingStatus.FUNDING, 
            "contributeBid: FrAactionHub is not bidding yet"
        );
        require(
            FraactionInterface(fraactionHubTarget).openForBid() == true, 
            "contributeBid: no bidding yet allowed by the FrAactionHub target"
        );
        require(
            _value > 0, 
            "contributeBid: must contribute more than 0"
        );
        require(
            _value + totalContributedToFunding <= FraactionInterface(auctionTarget).getMinBid() - usedTreasury, 
            "contributeBid: bid amount must be less than the maximum bid possible"
        );
        address _contributor = msg.sender;
        ERC20lib.transferFrom(ghstContract, _contributor, address(this), _value);
        // add contribution to contributor's array of contributions
        Contribution memory _contribution =
            Contribution({
                amount: _amount,
                previousTotalContributedToFraactionHub: _previousTotalContributedToFraactionHub
            });
        contributions[_contributor].push(_contribution);
        // add to contributor's total contribution
        ownerContributedToFunding[_contributor][fundingNumber] += _value;
        totalContributedToFunding += _value;
        fundingContributor[_contributor].push(fundingNumber);
        ownerTotalContributed[_contributor] += _value;
        if (!isBid[fundingNumber]) isBid[fundingNumber] = true;
        // add to FrAactionHub's total contribution & emit event
        totalContributedToFraactionHub += _value;
        claimed[_contributor] == false;
        if (allClaimed == true) allClaimed = false;
        emit ContributedAuction(
            _contributor,
            _value,
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
        require(
            FraactionInterface(auctionTarget).openForBid() == true, 
            "submitBid: no bidding yet allowed by the FrAactionHub target"
        );
        submittedBid = FraactionInterface(auctionTarget).getMinBid();
        require(
            submittedBid <= _getMaxBid(), 
            "submitBid: bid amount must be less than the maximum bid possible"
        );
        (bool success, bytes memory returnData) =
            auctionTarget.call(
                abi.encodeWithSignature("bid(uint256)", 
                submittedBid
            )
        );
        require(
            success,
            string(
                abi.encodePacked(
                    "submitBid: place bid failed: ",
                    returnData
                )
            )
        );
        fundingStatus = FundingStatus.SUBMITTED;
        emit SubmitBid(submittedBid);
    }
    
     /**
     * @notice Finalize the state of the initial auction
     * @dev Emits a FinalizedBid event upon success; callable by anyone
     */
    function finalizeBid(
        uint256[] calldata _extNftsIds,  
        uint256[] calldata _ext1155Ids,
        uint256[] calldata _ext1155Quantity,
        address[] calldata _extNftsAddress, 
        address[] calldata _ext1155Address
    ) external nonReentrant {
        require(
            fundingStatus == FundingStatus.SUBMITTED,
            "finalizeBid: initial auction not live"
        );
        require(
            FraactionInterface(auctionTarget).finalAuctionStatus() == FinalAuctionStatus.ENDED,
            "finalizeBid: auction still live"
        );
        require(
            _extNftsIds.length == _extNftsAddress.length &&
            _ext1155Ids.length == _ext1155Quantity.length
            _ext1155Quantity.length == _ext1155Address.length,
            "finalizeBid: each NFT ID needs a corresponding token address"
        );
        fundingStatus = FraactionInterface(auctionTarget).winning() == address(this) ? FundingStatus.COMPLETED : AuctionStatus.FAILED;
        uint256 fee;
        // if the purchase was completed,
        if (fundingStatus == FundingStatus.COMPLETED) {
            // transfer the fee to FrAactionDAO
            fee = getFundingFee(submittedBid);
            ERC20lib.transfer(ghstContract, fraactionDaoMultisig, fee);
            mergerStatus = MergerStatus.ACTIVE;
            fundingResult[fundingNumber] = 1;
            if (gameType == true) {
                
            }
            postAuctionMerge(
                _extNftsIds,  
                _ext1155Ids,
                _ext1155Quantity,
                _extNftsAddress, 
                _ext1155Address
            );
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
            _option < 10,
            "startPortalFunding: only 10 options possible"
        );
        require(
            aavegotchi[_tokenId] > 0,
            "startPortalFunding: Aavegotchi not appointed yet by the FrAactionHub owners"
        );
        require(
            finalAuctionStatus == FinalAuctionStatus.INACTIVE, 
            "startPortalFunding: Final auction already started"
        );
        require(
            portalStatus == PortalStatus.INACTIVE ||
            portalStatus == PortalStatus.FRACTIONALIZED,
            "startPortalFunding: FrAactionHub already having a new portal funding"
        );
        require(
            balanceOf(msg.sender) > 0,
            "startPortalFunding: not a FrAactionHub owner"
        );
        portalStatus = PortalStatus.FUNDING;
        portalTarget = _tokenId;
        portalOption = aavegotchi[_tokenId];
        portalNumber++;
        PortalAavegotchiTraitsIO[] memory minStake = DiamondInterface(diamondContract).portalAavegotchiTraits(_tokenId);
        collateralType = DiamondInterface(diamondContract).portalAavegotchiTraits(_tokenId).collateralType;
        maxContribution = minStake[_option].minimumStake;
        portalFundingTime = block.timestamp;
        totalContributedToPortalFunding = 0;
        portalStatus = PortalStatus.FUNDING;
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
    function contributePortal(uint256 _stakeAmount) external nonReentrant {
        require(
            portalStatus == PortalStatus.FUNDING,
            "contributePortal: FrAactionHub portal funding not active"
        );
        require(
            balanceOf(msg.sender) > 0,
            "contributePortal: not a FrAactionHub owner"
        );
        require(
            block.timestamp <= portalFundingTime + (ISettings(settingsContract).maxNumberDaysPortalFunding() * 1 days),
            "contributePortal: Aavegotchi funding round expired"
        );
        require(
            totalContributedToPortalFunding + _stakeAmount <= maxContribution,
            "contributePortal: can't contribute more than the gross contribution"
        );
        ERC20lib.transferFrom(collateralType, msg.sender, address(this), _stakeAmount);
        // convert collateral to GHST
        uint256 convertedCollateralToGhst = _stakeAmount * (ISettings(settingsContract).collateralTypeToGhst(collateralType) / 10**8);
        ownerContributedCollateral[msg.sender][aavegotchiNumber] += _stakeAmount;
        ownerCollateralType[msg.sender][aavegotchiNumber] = collateralType;
        ownerContributedToPortalFunding[msg.sender][aavegotchiNumber] += convertedCollateralToGhst;
        totalContributedToPortalFunding += convertedCollateralToGhst;
        ownerTotalContributed[msg.sender] += convertedCollateralToGhst;
        totalContributedToFraactionHub += convertedCollateralToGhst;
        portalContributor[msg.sender].push(portalNumber);
        claimed[msg.sender] = false;
        if (allClaimed == true) allClaimed = false;
        emit ContributedPortal(
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
            portalStatus == PortalStatus.FUNDING,
            "claimAavegotchi: FrAactionHub portal funding not active"
        );
        require(
             block.timestamp > portalFundingTime + (ISettings(settingsContract).minNumberDaysPortalFunding() * 1 days),
            "claimAavegotchi: Aavegotchi funding round minimum duration not reached"
        );
        require(
            maxContribution == totalContributedToPortalFunding,
            "claimAavegotchi: insufficient funds to purchase"
        );
        (bool success, bytes memory returnData) =
            diamondContract.call(
                abi.encodeWithSignature("claimAavegotchi(uint256,uint256,uint256)", 
                portalTarget, 
                portalOption, 
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
        portalStatus = PortalStatus.CLAIMED;
        emit ClaimedAavegotchi(maxContribution);
    }
    
    /**
     * @notice Finalize the state of the Aavegotchi claim
     * @dev Emits a FinalizedAavegotchi event upon success; callable by anyone
     */
    function finalizePortal() external nonReentrant {
        require(
            portalStatus == PortalStatus.CLAIMED,
            "finalizePortal: FrAactionHub Aavegotchi target not claimed yet"
        );
        portalStatus = DiamondInterface(diamondContract).getERC721Category(diamondContract, portalTarget) == 3 ? PortalStatus.COMPLETED: PortalStatus.FUNDING;
        uint256 _fee;
        // if the Aavegotchi claim was completed,
        if (portalStatus == PortalStatus.COMPLETED) {
            // transfer the fee to FrAactionDAO
            _fee = _getFundingFee(totalContributedToPortalFunding);
            ERC20lib.transfer(collateralType, fraactionDaoMultisig, _fee);
            mint(address(this), valueToTokens(totalContributedToPortalFunding));
            portalResult[portalNumber] = 1;
        } else {
            portalResult[portalNumber] = 0;
        }
        portalStatus = PortalStatus.INACTIVE;
        // set the contract status & emit result
        emit FinalizedPortal(
            portalStatus, 
            _fee, 
            totalContributedToPortalFunding
        );
    }
    
    // ======== External: final auction =========
    
    /// @notice kick off an auction. Must send reservePrice in GHST
    function startAuction(uint256 _value) external {
        require(
            finalAuctionStatus == FinalAuctionStatus.INACTIVE, 
            "startAuction: no auction starts"
        );
        require(
            fundingStatus == FundingStatus.FRACTIONALIZED,
            "startAuction: FrAactionHub already having a new funding"
        );
        require(
            portalStatus == PortalStatus.INACTIVE ||
            portalStatus == PortalStatus.FRACTIONALIZED,
            "startAuction: FrAactionHub already having a new portal funding"
        );
        require(
            _value >= reservePrice(), 
            "startAuction: too low bid"
        );
        require(
            votingTokens * 1000 >= ISettings(settingsContract).minVotePercentage() * totalSupply(), 
            "startAuction: not enough voters"
        );
        ERC20lib.transferFrom(ghstContract, msg.sender, address(this), _value);
        fundingTime = block.timestamp + ISettings(settingsContract).auctionLength();
        finalAuctionStatus = FinalAuctionStatus.ACTIVE;
        livePrice = _value;
        winning = msg.sender;
        emit Start(msg.sender, _value);
    }

    /// @notice an external function to bid on purchasing the SPDAO assets. The _value is the bid amount
    function bid(uint256 _value) external nonReentrant {
        require(
            finalAuctionStatus == FinalAuctionStatus.ACTIVE, 
            "bid: auction is not live"
        );
        require(
            _value >= minBid(), 
            "bid: too low bid"
        );
        require(
            block.timestamp < auctionEnd, 
            "bid: auction ended"
        );
        ERC20lib.transferFrom(ghstContract, msg.sender, address(this), _value);
        ERC20lib.transferFrom(ghstContract, address(this), winning, livePrice);
        FraactionInterface(winning).notifyOverbid();
        // If bid is within 15 minutes of auction end, extend auction
        if (fundingTime - block.timestamp <= 15 minutes) {
            fundingTime += 15 minutes;
        }
        livePrice = _value;
        winning = msg.sender;
        emit Bid(msg.sender, _value);
    }

    /// @notice an external function to end an auction after the timer has run out and transfer all the assets of the FrAactionHub to the winner
    function endAuction() external nonReentrant {
        require(
            fauctionStatus == AuctionStatus.ACTIVE, 
            "end: vault has already closed"
        );
        require(
            block.timestamp >= fundingTime, 
            "end: auction live"
        );
        auctionStatus = AuctionStatus.ENDED;
        mergeTo = winning;
        finalTreasury = IERC20Upgradeable(ghstContract).balanceOf(address(this));
        emit Won(winning, livePrice);
    }
    
    function notifyOverbid() external {
        require(
            msg.sender == auctionTarget, 
            "notifyOverbid: caller not the auction target"
        );
        overbidden = true;
        fundingStatus = FundingStatus.FUNDING;
        emit Overbidden(msg.sender);
    }
    // ======== External: final functions =========
    
    /// @notice an external function to burn ERC20 tokens to receive GHST and/or MATIC from ERC721 token purchase when the final auction is completed
    function finalClaim(address _contributor) external nonReentrant {
        require(
            auctionStatus == AuctionStatus.ENDED, 
            "finalClaim: vault not closed yet"
        );
        require(
            allClaimed == true,
            "finalClaim: initial funding not claimed"
        );
        uint256 bal = balanceOf(_contributor);
        require(bal > 0, "finalClaim: no tokens to cash out");
        uint256 share = bal * IERC20Upgradeable(ghstContract).balanceOf(address(this)) / totalSupply(); // + MATIC
        _burn(_contributor, bal);
        ERC20lib.transfer(ghstContract, _contributor, share);
        if (IERC20Upgradeable(ghstContract).balanceOf(address(this)) == 0) auctionStatus = AuctionStatus.INACTIVE;
        emit Cash(_contributor, share);
    }
    
    /// @notice an external function to burn all the FrAactionSPDAO ERC20 tokens to receive the ERC721 and (if any) ERC1155/ERC20 tokens
    function redeem() external nonReentrant {
        require(
            auctionStatus == AuctionStatus.INACTIVE, 
            "redeem: no auction starts"
        );
        require(
            fundingStatus == FundingStatus.FRACTIONALIZED,
            "redeem: FrAactionHub already having a new funding"
        );
        require(
            portalStatus == PortalStatus.INACTIVE ||
            portalStatus == PortalStatus.FRACTIONALIZED,
            "redeem: FrAactionHub already having a new portal funding"
        );
        require(
            balanceOf(msg.sender) == totalSupply(),
            "redeem: caller do not own the entire token supply"
        );
        require(
            mergerStatus == MergerStatus.INACTIVE || 
            target == _mergerTarget, 
            "redeem: merger already active"
        );
        _burn(msg.sender, totalSupply());
        if (mergerStatus == MergerStatus.INACTIVE) {
            target = msg.sender;
            mergerStatus = MergerStatus.ACTIVE
            emit MergerInitiated(mergerTarget);
        }
        uint256[] memory realmsIds = DiamondInterface(realmsContract).tokenIdsOfOwner(target);
        uint32[] memory nftIds = DiamondInterface(diamondContract).tokenIdsOfOwner(target);
        ItemIdIO[] memory itemsDiamond = DiamondInterface(diamondContract).itemBalances(target);
        uint256[] memory tickets = DiamondInterface(stakingContract).balanceOfAll(target);
        bool checkTickets;
        for (uint i = 0; i < tickets.length; i++) {
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
            target.call(abi.encodeWithSignature("transferNfts()"));
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
            target.call(abi.encodeWithSignature("transferItems()"));
            require(
                success,
                string(
                    abi.encodePacked(
                        "voteForMerger: initiating merger order failed: ",
                        returnData
                    )
                )
            );
            // transfer money remaining in the Hub
        } else {
            mergerStatus == MergerStatus.INACTIVE;
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
        emit Redeem(msg.sender);
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
        totalContributedToFraactionHub += convertedCollateralToGhst;
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
     * @notice The net price to be submitted
     * during the funding round and after 
     * deduction of the fee for FrAactionDAO
     * @return _netPrice the submitted price
     */
    function getFundingNetPrice() internal view returns (uint256 _netPrice) {
        _netPrice = ((totalContributedToFunding + usedTreasury) * 1000) / (1000 + ISettings(settingsContract).fundingFee());
    }
    
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
       _maxBid = ((totalContributedToFunding + _value) * 1000) / (1000 + ISettings(settingsContract).fundingFee());
    }
   
    // ============ Internal: claim ============

    /**
     * @notice Calculate the amount of fractional NFT tokens owed to the contributor
     * based on how much GHST they contributed towards the funding round
     * @param _contributor the address of the contributor
     * @return _tokenAmount the amount of fractional NFT tokens owed to the contributor
     * @return _GhstAmount the amount of GHST owed to the contributor
     */
    function calculateTokensAndGhstOwed(
        address _contributor, 
        bool _successFunding, 
        uint256 _fundingNumber
    )
        internal
        view
        returns (uint256 _tokenAmount, uint256 _ghstAmount)
    {
        uint256 contribution = ownerContributedToFunding[_contributor][_fundingNumber];
        if (!contribution) {
            continue;
        } else { 
            if (_successFunding == true) {
                if (isBid(_fundingNumber)) {
                    uint256 _totalUsedForBid = _totalGhstUsedForBid(_contributor);
                    if (_totalUsedForBid > 0) {
                        _tokenAmount = valueToTokens(_totalUsedForBid);
                    }
                    // the rest of the contributor's GHST should be returned
                    _ghstAmount = contribution - _totalUsedForBid;
                } else {
                    _tokenAmount = valueToTokens(contribution);
                }
                if (newOwner[_contributor] == true) {
                        numberOfOwners++;
                        newOwner[_contributor] = false;
                }
            } else {
                // if the new funding was not completed before the deadline of 7 days from the contract deployement or the new funding failed, no GHST was spent;
                // all of the contributor's GHST for this last new funding round should be returned
                _ghstAmount = contribution;
                ownerTotalContributed[_contributor] -= _ghstAmount;
                totalContributedToFrAactionHub -= _ghstAmount;
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
     function portalCalculateTokensAndGhstOwed(
         address _contributor, 
         bool _successPortalFunding, 
         uint256 _portalFundingNumber
    )
        internal
        view
        returns (uint256 _tokenAmount, uint256 _collateralAmount, address _collateralType)
    {
        uint256 contribution = ownerContributedToPortalFunding[_contributor][_portalFundingNumber];
        if (!contribution) {
            continue;
        } else {  
            if (_successPortalFunding == true) {
                _tokenAmount = valueToTokens(contribution);
            } else {
                _collateralAmount = ownerContributedCollateral[_contributor][_portalFundingNumber];
                _collateralType = ownerCollateralType[_contributor][_portalFundingNumber];
                ownerTotalContributed[_contributor] -= contribution;
                totalContributedToFraactionHub -= contribution;
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
    function totalGhstUsedForBid(address _contributor)
        internal
        view
        returns (uint256 _total)
    {
        // get all of the contributor's contributions
        Contribution[] memory _contributions = contributions[_contributor];
        for (uint256 i = 0; i < _contributions.length; i++) {
            // calculate how much was used from this individual contribution
            uint256 _amount = _ghstUsedForBid(_contributions[i]);
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
    function ghstUsedForBid(Contribution memory _contribution)
        internal
        view
        returns (uint256)
    {
        // load total amount spent once from storage
        uint256 _totalSpent = submittedBid;
        if (
            _contribution.previousTotalContributedToFraactionHub + _contribution.amount <= _totalSpent
        ) {
            // contribution was fully used
            return _contribution.amount;
        } else if (
            _contribution.previousTotalContributedToFraactionHub < _totalSpent
        ) {
            // contribution was partially used
            return _totalSpent - _contribution.previousTotalContributedToFraactionHub;
        }
        // contribution was not used
        return 0;
    }
    
    // ============ Internal: TransferTokens ============

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
            weth.deposit{value: _value}();
            weth.transfer(_to, _value);
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
        (bool success, ) = _to.call{value: _value, gas: 30000}("");
        return success;
    }
}