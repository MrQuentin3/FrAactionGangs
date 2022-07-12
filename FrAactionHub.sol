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
    ) external initializer {
        // initialize ReentrancyGuard and ERC721Holder
        __ReentrancyGuard_init();
        __ERC721Holder_init();
        __ERC1155Holder_init();
        thisContract = address.this;
        fraactionDaoMultisig = ;
        diamondContract = 0x86935F11C86623deC8a25696E1C19a8659CbF95d;
        ghstContract = 0x385eeac5cb85a38a9a07a70c73e0a3271cfb54a7;
        stakingContract = 0xA02d547512Bb90002807499F05495Fe9C4C3943f;
        realmsContract = 0x1D0360BaC7299C86Ec8E99d0c1C9A95FEfaF2a11;
        rafflesContract = 0x6c723cac1E35FE29a175b287AE242d424c52c1CE;
        marketContract = ;
        settingsContract = ;
        usdcContract = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
        quickSwapRouterContract = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;
        aavePoolContract = 0x794a61358D6845594F94dc1DB02A252b5b4814aD;
        aaveProtocolDataProviderContract = 0x69FA688f1Dc47d4B5d8029D5a35FB7a548310654;
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

    function donateFungibleTokens(address[] calldata _tokenAddress, uint256[] calldata _value) external payable {
        require(
            _tokenAddress.length =< ISettings(settingsContract).MaxTransferLimit(),
            "donateFungibleTokens: too many tokens transferred for a single call"
        );
        for (uint i = 0; i < _tokenAddress.length; i++) {
            if (_tokenAddress == ghstContract) {
                ERC20lib.transferFrom(_tokenAddress[i], msg.sender, address(this), _value[i]);
                totalTreasuryInGhst += _value[i];
            } else if (_tokenAddress[i] == address(this) && msg.value > 0) {
                totalTreasuryInMatic += msg.value;
            } else {
                ERC20lib.transferFrom(_tokenAddress[i], msg.sender, address(this), _value[i]);
                if (ownedErc20[_tokenAddress[i]] == 0 && erc20Index[_tokenAddress[i]] == 0) {
                    erc20tokens.push(_tokenAddress[i]);
                    erc20Index[_tokenAddress[i]] = erc20tokens.length - 1;
                }
                ownedErc20[_tokenAddress[i]] += value[i];
            }
        }
        emit DonatedErc20(_tokenAddress, _value);
    }

    function donateExtNfts(address[] calldata _tokenAddress, uint256[] calldata _id) external {
        require(
            _tokenAddress.length =< ISettings(settingsContract).MaxTransferLimit(),
            "donateExtNfts: too many tokens transferred for a single call"
        );
        for (uint i = 0; i < _tokenAddress.length; i++) {
            require(
                _tokenAddress[i] != diamondContract &&
                _tokenAddress[i] != realmsContract,
                "donateExtNfts: Aavegotchi NFTs can be donated to the FrAactionHub with a simple ERC721 transfer"
            );
            ERC721Upgradeable(_tokenAddress[i]).transferFrom(_tokenAddress[i], msg.sender, address(this), _id[i]);
            if (ownedErc721[_tokenAddress[i]][_id[i]] == 0) {
                Nft memory newNft = Nft(_tokenAddress[i], _id[i]);
                nfts.push(newNft);
                nftsIndex[_tokenAddress[i]] = nfts.length - 1;
            }
            ownedNfts[_tokenAddress[i]][_id[i]] = true;
        }
        emit DonatedExtNft(_tokenAddress, _id);
    }

    function donateErcExt1155(address[] calldata _tokenAddress, uint256[] calldata _id, uint256[] calldata _value) external {
        require(
            _tokenAddress.length =< ISettings(settingsContract).MaxTransferLimit(),
            "donateErcExt1155: too many tokens transferred for a single call"
        );
        for (uint i = 0; i < _tokenAddress.length; i++) {
            require(
                _tokenAddress[i] != diamondContract &&
                _tokenAddress[i] != stakingContract,
                "donateErcExt1155: Aavegotchi items can be donated to the FrAactionHub with a simple ERC1155 transfer"
            );
            ERC1155Upgradeable(_tokenAddress[i]).transferFrom(_tokenAddress[i], msg.sender, address(this), _id[i], _value[i]);
            if (ownedErc1155[_tokenAddress[i]][_id[i]] == 0) {
                Erc1155 memory newErc1155 = Erc1155(_tokenAddress[i], _id[i], _value[i]);
                erc1155Tokens.push(newErc1155);
                erc1155Index[_tokenAddress[i]] = erc1155Tokens.length - 1;
            }
            ownedErc1155[_tokenAddress[i]][_id[i]] += _value[i];
        }
        emit DonatedExtErc1155(_tokenAddress, _id, _value);
    }

    function acknowledgeFungibleTokens(address[] calldata _tokenAddress) external {
        require(
            _tokenAddress.length =< ISettings(settingsContract).MaxTransferLimit(),
            "acknowledgeFungibleTokens: too many tokens transferred for a single call"
        );
        for (uint i = 0; i < _tokenAddress.length; i++) {
            uint256 balance = IERC721Upgradeable(_tokenAddress[i]).balanceOf(address(this));
            uint256 value;
            if (_tokenAddress[i] == ghstContract) {
                require(
                    balance >= currentBalanceInGhst,
                    "acknowledgeFungibleTokens: insufficient GHST balance"
                );
                value = balance - currentBalanceInGhst;
                totalTreasuryInGhst += value;
            } else if (_tokenAddress[i] == address(this) && msg.value > 0) {
                require(
                    address(this).balance >= currentBalanceInMatic,
                    "acknowledgeFungibleTokens: insufficient MATIC balance"
                );
                value = balance - currentBalanceInMatic;
                totalTreasuryInMatic += value;
            } else {
                require(
                    balance >= ownedErc20[_tokenAddress[i]],
                    "acknowledgeFungibleTokens: insufficient ERC20 token balance"
                );
                if (ownedErc20[_tokenAddress[i]] == 0 && erc20Index[_tokenAddress[i]] == 0) {
                    erc20Tokens.push(_tokenAddress[i]);
                    erc20Index[_tokenAddress[i]] = erc20tokens.length - 1;
                }
                value = balance - ownedErc20[_tokenAddress[i]]
                ownedErc20[_tokenAddress[i]] += value;
            }
        }
        emit AcknwoledgedExtErc20(_tokenAddress, value);
    }

    function acknowledgeExtNfts(address[] calldata _tokenAddress, uint256[] calldata _id) external {
        require(
            _tokenAddress.length =< ISettings(settingsContract).MaxTransferLimit(),
            "acknowledgeExtNfts: too many tokens transferred for a single call"
        );
        for (uint i = 0; i < _tokenAddress.length; i++) {
            require(
                _tokenAddress[i] != diamondContract &&
                _tokenAddress[i] != realmsContract,
                "acknowledgeExtNfts: Aavegotchi NFTs are natively acknowledged by the FrAactionHub"
            );
            require(
                ERC721Upgradeable(_tokenAddress[i]).ownerOf(_id[i]) == address(this),
                "acknowledgeExtNfts: FrAactionHub not owner of this NFT"
            );
            if (!ownedErc721[_tokenAddress[i]][_id[i]]) {
                Nft memory newNft = Nft(_tokenAddress[i], _id[i]);
                nfts.push(newNft);
                nftsIndex[_tokenAddress[i]] = nfts.length - 1;
            }
            ownedNfts[_tokenAddress[i]][_id[i]] = true;
        }
        emit AcknowledgedExtNft(_tokenAddress, _id);
    }
    
    function acknowledgeExt1155(address[] calldata _tokenAddress, uint256[] calldata _id, uint256[] calldata _value) external {
        require(
            _tokenAddress.length =< ISettings(settingsContract).MaxTransferLimit(),
            "acknowledgeExt1155: too many tokens transferred for a single call"
        );
        for (uint i = 0; i < _tokenAddress.length; i++) {
            require(
                _tokenAddress[i] != diamondContract &&
                _tokenAddress[i] != stakingContract,
                "acknowledgeExtErc1155: Aavegotchi items are natively acknowledged by the FrAactionHub"
            );
            require(
                ERC1155Upgradeable(_tokenAddress[i]).balanceOf(address(this), _id[i]) == _value[i],
                "acknowledgeExtErc1155: FrAactionHub not owner of this NFT"
            );
            if (ownedErc1155[_tokenAddress[i]][_id[i]] == 0) {
                Erc1155 memory newErc1155 = Erc1155(_tokenAddress[i], _id[i], _value[i]);
                erc1155Tokens.push(newErc1155);
                erc1155Index[_tokenAddress[i]] = erc1155Tokens.length - 1;
            }
            ownedErc1155[_tokenAddress[i]][_id[i]] += _value[i];
        }
        emit AcknwoledgedExtErc1155(_tokenAddress, _id, _value);
    }
    
    // ======== External: Funding =========

    function voteForFundraising(bool _inGhst) external {
        require(
            fundRaisingStatus != FundingStatus.FUNDRAISING,
            "voteForFundraising: FrAactionHub not fractionalized yet"
        );
        require(
            finalAuctionStatus == FinalAuctionStatus.INACTIVE, 
            "voteForFundraising: Final auction already started"
        );
        if (_inGhst) fundraisingInGhst = _inGhst;
        if (firstRound) {
            require(
                initiator == msg.sender,
                "voteForFundraising: not the FrAactionHub initiator"
            );
        } else {
            require(
                balanceOf(msg.sender) > 0,
                "voteForFundraising: not a FrAactionHub owner"
            );
        }
        fundRaisingEnd = block.timestamp + (ISettings(settingsContract).maxNumberDaysFunding() * 1 days);
        fundRaisingStatus = fundingStatus.FUNDRAISING;
        totalContributedToFundraising = 0;
        emit StartedFundraising(msg.sender);
    }

    function contributeFundraising(uint256 _value) external payable nonReentrant {
        require(
            fundRaisingStatus == FundingStatus.FUNDRAISING,
            "contributeFundraising: FrAactionHub not fractionalized yet"
        );
        if (privateHub) {
            require(
                balanceOf(msg.sender) > 0 ||
                whitelisted[msg.sender], 
                "contributeFundraising: user not an owner or whitelisted member of the FrAactionHub"
            );
        }
        if (block.timestamp > fundRaisingEnd) {
            fundRaisingStatus = fundingStatus.INACTIVE;
        } else {
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
                totalContributedToFundraising += _value;
                if (firstRound == true) {
                    // mint fractional ERC-20 tokens
                    initializeVault(
                        valueToTokens(totalContributedToFraactionHubInGhst, fundraisingInGhst), 
                        totalContributedToFraactionHubInGhst, 
                        name, 
                        symbol
                    );
                    exitInGhst = true;
                    firstRound = false;
                } else {
                    mint(msg.sender, valueToTokens(_value, fundraisingInGhst));
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
                totalContributedToFundraising += msg.value;
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
     * @dev Emits a Funding event upon success; callable by anyone
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
            finalAuctionStatus == FinalAuctionStatus.INACTIVE, 
            "startPurchase: Final auction already started"
        );
        fundingNumber++;
        if (_inGhst) {
            require(
                _usedTreasury <= totalTreasuryInGhst - totalUsedTreasuryInGhst,
                "startPurchase: value higher than the current treasury"
            );
            usedTreasuryInGhst[fundingNumber] = _usedTreasury;
            fundingInGhst[fundingNumber] = _inGhst;
            totalUsedTreasuryInGhst += _usedTreasury;
        } else {
            require(
                _usedTreasury <= totalTreasuryInMatic - totalUsedTreasuryInMatic,
                "startPurchase: value higher than the current treasury"
            );
            require(
                !_baazaarPurchase,
                "startPurchase: cannot purchase from the Baazaar with MATIC"
            );
            usedTreasuryInMatic[fundingNumber] = _usedTreasury;
            totalUsedTreasuryInMatic += _usedTreasury;
        }
        if (firstRound) {
            require(
                initiator == msg.sender,
                "startPurchase: not the FrAactionHub initiator"
            );
        } else {
            require(
                balanceOf(msg.sender) > 0,
                "startPurchase: not a FrAactionHub owner"
            );
        }
        fundingStatus[fundingNumber] = fundingStatus.FUNDING;
        if (globalFundingStatus == fundingStatus.INACTIVE) globalFundingStatus = fundingStatus.FUNDING;
        currentFunding++;
        fundingTarget[fundingNumber] = _listingId;
        if (_baazaarPurchase) {
            fromBaazaar[fundingNumber] = true;
            isNft[fundingNumber] = _isNft;
            if (_isNft) {
                ERC721Listing memory diamond = DiamondInterface(diamondContract).getERC721Listing(_listingId);
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
                quantity[fundingNumber] = _quantity;
                ERC1155Listing memory diamondItem = DiamondInterface(diamondContract).getERC1155Listing(_listingId);
                priceInWei[fundingNumber] = diamondItem.priceInWei;
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
        fundingEnd[fundingNumber] = block.timestamp + (ISettings(settingsContract).maxNumberDaysFunding() * 1 days);
        emit Funding(
            fundingTarget[fundingNumber], 
            priceInWei[fundingNumber], 
            quantity[fundingNumber]
        );
    }
        
    /**
     * @notice Contribute to the FrAaction's treasury
     * while the funding round is still open
     * @dev Emits a Contributed event upon success; 
     */
    function contributePurchase(uint256 _value, uint256 _fundingNumber) external payable nonReentrant {
        require(
            fundingStatus == FundingStatus.FUNDING,
            "contributePurchase: funding round not active"
        );
        require(
            block.timestamp <= fundingEnd[_fundingNumber],
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
        if (fundingInGhst[_fundingNumber]) {
            value = _value;
        } else {
            value = msg.value;
        }
        require(
            value > 0, 
            "contributePurchase: must contribute more than 0"
        );
        if (fromBaazaar[_fundingNumber]) {
            if (isNft[_fundingNumber]) {
                ERC721Listing memory diamond = DiamondInterface(diamondContract).getERC721Listing(fundingTarget[_fundingNumber]);
                if (diamond.timePurchased != 0 ||
                    diamond.cancelled == true ||
                    diamond.timeCreated == 0
                ) {
                    fundingStatus[_fundingNumber] = FundingStatus.SUBMITTED;
                    emit contributed(
                        msg.sender,
                        0,
                        0
                    );
                    return;
                }
            } else {
                ERC1155Listing memory diamondItem = DiamondInterface(diamondContract).getERC1155Listing(fundingTarget[_fundingNumber]);
                if (diamondItem.sold == true ||
                    diamondItem.cancelled == true ||
                    diamondItem.timeCreated == 0
                ) {
                    fundingStatus[_fundingNumber] = FundingStatus.SUBMITTED;
                    emit contributed(
                        msg.sender,
                        0,
                        0
                    );
                    return;
                }
            }
        }
        if (fundingInGhst[_fundingNumber]) {
            require(
                totalContributedToFunding[_fundingNumber] + value <= getFundingGrossPrice() - usedTreasuryInGhst[_fundingNumber],
                "contributePurchase: cannot contribute more than the gross price"
            );
            ownerTotalContributedInGhst[msg.sender] += value;
            currentBalanceInGhst += value;
            ERC20lib.transferFrom(ghstContract, msg.sender, address(this), value);
        } else {
            require(
                totalContributedToFunding[_fundingNumber] + value <= getFundingGrossPrice() - usedTreasuryInMatic[_fundingNumber],
                "contributePurchase: cannot contribute more than the gross price"
            );
            ownerTotalContributedInMatic[msg.sender] += value;
            currentBalanceInMatic += value;
        }
        ownerContributedToFunding[msg.sender][_fundingNumber] += value;
        totalContributedToFunding[_fundingNumber] += value;
        if (ownerContributedToFunding[msg.sender][_fundingNumber] = 0) fundingContributor.push(_fundingNumber);  
        emit contributed(
            msg.sender,
            value,
            ownerContributedToFunding[msg.sender][_fundingNumber]
        );
    }

    /**
     * @notice Submit a purchase order to the Market
     * @dev Reverts if insufficient funds to purchase the item and pay FrAactionDAO fees
     * Emits a Purchased event upon success.
     * Callable by anyone
     */
    function purchase(uint256 _fundingNumber) external nonReentrant {
        require(
            fundingStatus == FundingStatus.FUNDING,
            "purchase: funding round not active"
        );
        require(
            block.timestamp <= fundingEnd[_fundingNumber],
            "purchase: funding round expired"
        );
        // ensure there is enough GHST or MATIC to order the purchase including FrAactionDAO fee
        if (fundingInGhst[_fundingNumber]) {
            require(
                totalContributedToFunding[_fundingNumber] + usedTreasuryInGhst[_fundingNumber] == getFundingGrossPrice(),
                "purchase: insufficient funds to purchase"
            );
        } else {
            require(
                totalContributedToFunding[_fundingNumber] + usedTreasuryInMatic[_fundingNumber] == getFundingGrossPrice(),
                "purchase: insufficient funds to purchase"
            );
        }
        if (fromBaazaar[_fundingNumber]) {
            if (isNft[_fundingNumber] == true) {
                ERC721Listing memory diamond = DiamondInterface(diamondContract).getERC721Listing(fundingTarget[_fundingNumber]);
                if (diamond.timePurchased != 0 ||
                    diamond.cancelled == true ||
                    diamond.timeCreated == 0
                ) {
                    fundingStatus[_fundingNumber] = FundingStatus.SUBMITTED;
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
                        fundingTarget[_fundingNumber]
                    )
                );
            } else {
                ERC1155Listing memory diamondItem = DiamondInterface(diamondContract).getERC1155Listing(fundingTarget[_fundingNumber]);
                if (diamondItem.sold == true ||
                    diamondItem.cancelled == true ||
                    diamondItem.timeCreated == 0
                ) {
                    fundingStatus[_fundingNumber] = FundingStatus.SUBMITTED;
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
                        initialNumberOfItems[_fundingNumber] = 
                            item[i].balance - MarketInterface(marketContract).sellingItems[item[i].itemId] + MarketInterface(marketContract).buyingItems[item[i].itemId];
                        break;
                    }
                }
                // submit the purchase order to the ERC1155marketplaceFacet smart contract
                (bool success, bytes memory returnData) =
                    diamondContract.call(
                        abi.encodeWithSignature("executeERC1155Listing(uint256)", 
                        fundingTarget[_fundingNumber], 
                        quantity[_fundingNumber], 
                        priceInWei[_fundingNumber]
                    )
                );
            }
        } else {
            MarketInterface(fraactionMarketContract).executeTokenTransaction(fundingTarget[_fundingNumber]);
        }
        fundingStatus = FundingStatus.SUBMITTED;
        emit Purchase(totalContributedToFunding[_fundingNumber]);
    }

    /**
     * @notice Finalize the state of the new purchase
     * @dev Emits a Finalized event upon success; callable by anyone
     */
    function finalizePurchase(uint256 _fundingNumber) external nonReentrant {
        require(
            fundingStatus[_fundingNumber] == fundingStatus.SUBMITTED,
            "finalizePurchase: funding target not purchased"
        );
        bool existingItem;
        uint256 tokenId;
        if (isNft[_fundingNumber]) {
            tokenId = diamond.erc721TokenId;
            fundingStatus[_fundingNumber] = DiamondInterface(diamondContract).ownerOf(tokenId) == address(this) ? FundingStatus.COMPLETED: FundingStatus.FAILED;
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
            fundingStatus[_fundingNumber] = quantity == (numberOfItems - initialNumberOfItems[_fundingNumber]) ? FundingStatus.COMPLETED: FundingStatus.FAILED;
        }
        uint256 fee;
        // if the repurchase was completed,
        if (fundingStatus[_fundingNumber] == FundingStatus.COMPLETED) {
            fundingResult[_fundingNumber] = 1;
            // transfer the fee to FrAactionDAO
            fee = _getFundingFee(totalContributedToFunding[_fundingNumber]);
            if (fundingInGhst[_fundingNumber]) {
                ERC20lib.transfer(ghstContract, fraactionDaoMultisig, fee);
                totalContributedToFraactionHubInGhst += totalContributedToFunding[_fundingNumber];
                totalUsedTreasuryInGhst -= usedTreasuryInGhst[_fundingNumber];
            } else {
                transferMaticOrWmatic(fraactionDaoMultisig, fee);
                totalContributedToFraactionHubInMatic += totalContributedToFunding[_fundingNumber];
                totalUsedTreasuryInMatic -= usedTreasuryInMatic[_fundingNumber];
            }
            uint256 tokensToMint = valueToTokens(totalContributedToFunding[_fundingNumber], fundingInGhst[_fundingNumber]);
            if (firstRound == true) {
                // mint fractional ERC-20 tokens
                initializeVault(
                    tokensToMint, 
                    totalContributedToFunding[_fundingNumber], 
                    name, 
                    symbol
                );
                if (fundingInGhst[_fundingNumber]) exitInGhst = true;
                firstRound = false;
            } else {
                mint(address(this), tokensToMint);
            }
            mintedTokens[_fundingNumber] = tokensToMint;
        } else {
            fundingResult[_fundingNumber] = 0;
        }
        emit Finalized(
            fundingStatus[_fundingNumber], 
            fee,
            totalContributedToFunding[_fundingNumber]
        );
        fundingStatus[_fundingNumber] = FundingStatus.INACTIVE;
        currentFunding--;
        if (currentFunding == 0) {
            globalFundingStatus = FundingStatus.INACTIVE;
        }
    }

    /**
     * @notice claim the tokens owed
     * to each contributor after the purchase and frationalization has ended
     * @dev Emits a Claimed event upon success
     * callable by anyone (doesn't have to be the contributor)
     * @param _contributor the address of the contributor
     */
    function claim(address _contributor, uint256 _fundingNumber) external nonReentrant {
        if (fundingStatus[_fundingNumber] == FundingStatus.FUNDING &&
            block.timestamp > fundingEnd[_fundingNumber] &&
            !isBid[_fundingNumber]
        ) {
            fundingResult[_fundingNumber] = 0;
            fundingStatus[_fundingNumber] = FundingStatus.INACTIVE;
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
            uint256 index;
            uint256[] memory activeIds;
            for (uint i = 0; i < fundingContributor[_contributor].length; i++) {
                if (fundingStatus[fundingContributor[_contributor][i]] == fundingStatus.INACTIVE) {
                    (uint256 tokenAmount, uint256 ghstOrMaticAmount) = 
                        calculateTokensOwed(
                            _contributor, 
                            fundingResult[fundingContributor[_contributor][i]], 
                            fundingContributor[_contributor][i]
                        );
                    // transfer tokens to contributor for their portion of GHST used
                    sumToken += tokenAmount;
                    // if the new funding deadline is reached or the repurchase failed then return all the GHST or MATIC to the contributor
                    if (ghstOrMaticAmount > 0) {
                        if (fundingInGhst[fundingContributor[_contributor][i]]) {
                            sumGhst += ghstOrMaticAmount;
                        } else {
                            sumMatic += ghstOrMaticAmount;
                        }
                    }
                } else {
                    activeIds[index] = fundingContributor[_contributor][i];
                    index++;
                }
            }
            delete fundingContributor[_contributor];
            if (activeIds.length > 0) {
                for (uint i = 0; i < activeIds.length; i++) {
                    fundingContributor[_contributor].push(activeIds[i]);
                }
            }
        }
        if (sumToken > 0) _transferTokens(_contributor, sumToken);
        if (sumGhst > 0) {
            uint256 bal = IERC20Upgradeable(ghstContract).balanceOf(address(this));
            if (sumGhst > bal) sumGhst = bal;
            ERC20lib.transfer(ghstContract, _contributor, sumGhst);
        }
        uint256 userShare = balanceOf(_contributor) / totalSupply() * 1000;
        for (uint i = 0; i < collateralAvailable.length; i++) {
            uint256 splitProfit;
            uint256 minIndex;
            uint256 sum;
            uint256 numberClaimed;
            if (minimumCollateralIndex[collateralAvailable[i]] > collateralIndex[_contributor][collateralAvailable[i]]) {
                minIndex = minimumCollateralIndex[collateralAvailable[i]];
            } else {
                minIndex = collateralIndex[_contributor][collateralAvailable[i]];
            }
            for (uint j = minIndex; j < redeemedCollateral[collateralAvailable[i]].length; j++) {
                if (j != redeemedCollateral[collateralAvailable[i]].length - 1 || redeemedCollateral[collateralAvailable[i]][j] > 0) {
                    if (userShare / 1000 * redeemedCollateral[collateralAvailable[i]][j] + currentRedeemedCollateral[collateralAvailable[i]][j] >= redeemedCollateral[collateralAvailable[i]][j]) {
                        splitProfit += redeemedCollateral[collateralAvailable[i]][j] - currentRedeemedCollateral[collateralAvailable[i]][j];
                        delete redeemedCollateral[collateralAvailable[i]][j]; 
                        delete currentRedeemedCollateral[collateralAvailable[i]][j];
                        if (j < redeemedCollateral[collateralAvailable[i]].length - 1) {
                            minimumCollateralIndex[collateralAvailable[i]] = j + 1;
                        } else {
                            numberClaimed++;
                        }
                    } else {
                        sum += redeemedCollateral[collateralAvailable[i]][j];
                        currentRedeemedCollateral[collateralAvailable[i]][j] += userShare / 1000 * redeemedCollateral[collateralAvailable[i]][j];
                    }
                } else {
                    numberClaimed++;
                }
            }
            if (sum > 0) {
                if (collateralAvailable[i] == thisContract) {
                    sumMatic += sum * userShare / 1000 + splitProfit;
                } else {
                    uint256 bal = IERC20Upgradeable(collateralAvailable[i]).balanceOf(address(this))
                    uint256 refundedCollateral = sum * userShare / 1000 + splitProfit;
                    if (refundedCollateral > bal) refundedCollateral = bal;
                    ERC20lib.transfer(collateralAvailable[i], _contributor, refundedCollateral);
                }
                emit CollateralRefunded(_contributor, collateralAvailable[i], refundedCollateral);
            }
            collateralIndex[_contributor][collateralAvailable[i]] = redeemedCollateral[collateralAvailable[i]].length;
        }
        if (numberClaimed == collateralAvailable.length) allCollateralClaimed = true;
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
        if (mergerStatus == MergerStatus.ENDED) {
            claimedCounter++;
            burn(_contributor, balanceOf(_contributor));
            delete ownersAddress[ownersAddressIndex[_contributor]];
            if (claimedCounter == ownersAddress.length) {
                claimedCounter = 0;
                firstRound = true;
                delete ownersAddress;
                if (proposedTakeoverFrom[target] || 
                    finalAuctionStatus == FinalAuctionStatus.ACTIVE && takenover
                ) {
                    mergerStatus == MergerStatus.TAKINGOVER;
                } else {
                    mergerStatus == MergerStatus.INACTIVE;
                }
                finalAuctionStatus = FinalAuctionStatus.INACTIVE;
                emit FinalClaim(mergerStatus);
            }
        }
    }

    function claimReward(address _ownerAddress) internal {
        mint(_ownerAddress, rewardInWei);
    }

    function takingover() internal {
        require(
            mergerStatus == MergerStatus.TAKINGOVER, 
            "takingover: cannot takeover before previous owners claimed and burnt their tokens"
        );
        demergerStatus = DemergerStatus.ASSETSTRANSFERRED;
        finalizeDemerger();
        if (split == 0) {
            delete proposedTakeoverFrom[target];
            delete takenover;
            mergerStatus == MergerStatus.INACTIVE;
            FraactionInterface(target).finalizeTakeover();
            emit Takenover(address(this));
        }
    }

    function claimAll(address[] calldata _contributors) external nonReentrant {
        require(
            _contributors <= ISettings(settingsContract).maxOwnersArrayLength(), 
            "claimAll: too many contributors' addresses to claim"
        );
        uint256 startIndex;
        uint256 endIndex; 
        if (_contributors.length > 0) {
            endIndex = _contributors.length;
        } else {
            endIndex = ownersAddress.length;
        }
        if (split == 0) {
            maxOwnersArrayLength = ISettings(settingsContract).maxOwnersArrayLength();
            if (endIndex > maxOwnersArrayLength {
                endIndex = maxOwnersArrayLength;
                if (endIndex % maxOwnersArrayLength > 0) {
                    multiple = endIndex / maxOwnersArrayLength + 1;
                } else {
                    multiple = endIndex / maxOwnersArrayLength;
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
        if (_contributors.length == 0) {
            if (endIndex > ownersAddress.length) endIndex = ownersAddress.length;
            if (startIndex > ownersAddress.length) return;
            for (uint i = 0; i < endIndex; i++) {
                claim(ownersAddress[i]);
            }
        } else {
            for (uint i = 0; i < endIndex; i++) {
                claim(_contributors[i]);
            }
        }
        claimReward(msg.sender);
    }    

    // ======== External: Auction funding =========

    function startBid(
        address _auctionTarget, 
        uint256 _quantity,
        uint256 _usedTreasury
    ) external {
        require(
            finalAuctionStatus == FinalAuctionStatus.INACTIVE, 
            "startBid: Final auction already started"
        );
        require(
            FraactionInterface(_auctionTarget).openForBidOrMerger(),
            "startBid: FrAactionHub not open for merger or bid"
        );
        fundingNumber++;
        if (firstRound) {
            require(
                initiator == msg.sender,
                "startBid: not the FrAactionHub initiator"
            );
        } else {
            require(
                balanceOf(msg.sender) > 0,
                "startBid: not a FrAactionHub owner"
            );
        }
        bool inGhst = FraactionInterface(_auctionTarget).checkExitTokenType();
        if (inGhst) {
            require(
                _usedTreasury <= totalTreasuryInGhst - totalUsedTreasuryInGhst,
                "startBid: value higher than the current treasury"
            );
            usedTreasuryInGhst[fundingNumber] = _usedTreasury;
            fundingInGhst[fundingNumber] = inGhst;
            totalUsedTreasuryInGhst += _usedTreasury;
        } else {
            require(
                _usedTreasury <= totalTreasuryInMatic - totalUsedTreasuryInMatic,
                "startBid: value higher than the current treasury"
            );
            usedTreasuryInMatic[fundingNumber] = _usedTreasury;
            totalUsedTreasuryInMatic += _usedTreasury;
        }
        fundingStatus[fundingNumber] = FundingStatus.FUNDING;
        if (globalFundingStatus == fundingStatus.INACTIVE) globalFundingStatus = FundingStatus.FUNDING;
        currentFunding++;
        auctionTarget[fundingNumber] = _auctionTarget;
        auctionTargetToNumber[_auctionTarget] = fundingNumber;
        usedTreasury[fundingNumber] = _usedTreasury;
        isBid[fundingNumber] = true;
        emit StartAuction(_auctionTarget);
    }
    
     /**
     * @notice Contribute to the initial bid on another FrAactionHub
     * while the initial funding is still open
     * @dev Emits a ContributedBid event upon success; callable by anyone
     */
    function contributeBid(uint256 _value, uint256 _fundingNumber) external payable nonReentrant {
        require(
            fundingStatus[_fundingNumber] == FundingStatus.FUNDING, 
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
        if (fundingInGhst[_fundingNumber]) {
            value = _value;
        } else {
            value = msg.value;
        }
        require(
            value > 0, 
            "contributePurchase: must contribute more than 0"
        );
        contributions[_contributor].push(_contribution);
        if (ownerContributedToFunding[msg.sender][_fundingNumber] = 0) fundingContributor[_contributor].push(_fundingNumber);
        if (fundingInGhst[_fundingNumber]) {
            ownerTotalContributedInGhst[msg.sender] += value;
            currentBalanceInGhst += value;
            ERC20lib.transferFrom(ghstContract, msg.sender, address(this), value);
        } else {
            ownerTotalContributedInMatic[msg.sender] += value;
            currentBalanceInMatic += value;
        }
        ownerContributedToFunding[msg.sender][_fundingNumber] += value;
        totalContributedToFunding[_fundingNumber] += value;
        // add contribution to contributor's array of contributions
        Contribution memory _contribution =
            Contribution({
                amount: value,
                previousTotalContributedToFraactionHub: totalContributedToFunding[_fundingNumber]
            });
        emit ContributedAuction(
            _contributor,
            value,
            ownerContributedToFunding[_contributor][_fundingNumber]
        );
    }
    
    /**
     * @notice submit the bid to FraactionHub target
     * @dev Emits a SubmitBid event upon success; callable by anyone
     */
    function submitBid(uint256 _fundingNumber) external nonReentrant {
        require(
            fundingStatus[_fundingNumber] == FundingStatus.FUNDING, 
            "submitBid: FrAactionHub is not bidding yet"
        );
        if (!FraactionInterface(auctionTarget[_fundingNumber]).openForBidOrMerger()) fundingStatus[_fundingNumber] = FundingStatus.SUBMITTED;
        bool checkActiveBid = FraactionInterface(auctionTarget[_fundingNumber]).activeBid();
        uint256 submittedBid = FraactionInterface(auctionTarget[_fundingNumber]).getMinBid();
        ERC20Upgradeable(auctionTarget[_fundingNumber]).approve(fundingTarget[_fundingNumber], MAX_INT);
        require(
            submittedBid <= _getMaxBid(), 
            "submitBid: bid amount must be less than the maximum bid possible"
        );
        if (checkActiveBid) {
            if (fundingInGhst[_fundingNumber]) {
                FraactionInterface(auctionTarget[_fundingNumber]).bid(); 
            } else {
                FraactionInterface(auctionTarget[_fundingNumber]).bid{value: submittedBid}();
            }
        } else {
            if (fundingInGhst[_fundingNumber]) {
                FraactionInterface(auctionTarget[_fundingNumber]).startFinalAuction();
            } else {
                FraactionInterface(auctionTarget[_fundingNumber]).startFinalAuction{value: submittedBid}();
            }
        }
        finalBidAmount[_fundingNumber] = submittedBid;
        fundingStatus[_fundingNumber] = FundingStatus.SUBMITTED;
        emit SubmitBid(submittedBid);
    }
    
     /**
     * @notice Finalize the state of the initial auction
     * @dev Emits a FinalizedBid event upon success; callable by anyone
     */
    function finalizeBid(uint256 _fundingNumber) external nonReentrant {
        require(
            fundingStatus[_fundingNumber] == FundingStatus.FUNDING ||
            fundingStatus[_fundingNumber] == FundingStatus.SUBMITTED,
            "finalizeBid: initial auction not live"
        );
        require(
            FraactionInterface(auctionTarget[_fundingNumber]).finalAuctionStatus() == FinalAuctionStatus.ENDED,
            "finalizeBid: auction still live"
        );
        ERC20Upgradeable(auctionTarget[_fundingNumber]).approve(auctionTarget[_fundingNumber], 0);
        fundingStatus = FraactionInterface(auctionTarget[_fundingNumber]).winning() == address(this) ? FundingStatus.COMPLETED : FundingStatus.FAILED;
        uint256 fee;
        // if the purchase was completed,
        if (fundingStatus == FundingStatus.COMPLETED) {
            // transfer the fee to FrAactionDAO
            fee = getFundingFee(finalBidAmount[_fundingNumber]);
            fundingResult[_fundingNumber] = 1;
            if (fundingInGhst[_fundingNumber]) {
                ERC20lib.transfer(ghstContract, fraactionDaoMultisig, fee);
                totalContributedToFraactionHubInGhst += totalContributedToFunding[_fundingNumber];
            } else {
                transferMaticOrWmatic(fraactionDaoMultisig, fee);
                totalContributedToFraactionHubInMatic += totalContributedToFunding[_fundingNumber];
            }
            uint256 tokensToMint = valueToTokens(finalBidAmount[_fundingNumber], fundingInGhst[_fundingNumber]);
            if (firstRound == true) {
                // mint fractional ERC-20 tokens
                initializeVault(
                    tokensToMint, 
                    totalContributedToFunding[_fundingNumber], 
                    name, 
                    symbol
                );
                firstRound = false;
                if (fundingInGhst[_fundingNumber]) exitInGhst = true;
            } else {
                mint(address(this), tokensToMint);
            }
            mintedTokens[_fundingNumber] = tokensToMint;
        } else {
            fundingResult[_fundingNumber] = 0;
        }
        if (takingover) mergerStatus = MergerStatus.WAITINGTAKEOVER;
        fundingStatus = FundingStatus.INACTIVE;
        currentFunding--;
        if (currentFunding == 0) {
            globalFundingStatus = FundingStatus.INACTIVE;
        }
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
            balanceOf(msg.sender) > 0,
            "startPortalFunding: not a FrAactionHub owner"
        );
        fundingNumber++;
        fundingStatus[fundingNumber] = FundingStatus.FUNDING;
        fundingTarget[fundingNumber] = _tokenId;
        if (globalFundingStatus == fundingStatus.INACTIVE) globalFundingStatus = FundingStatus.FUNDING;
        currentFunding++;
        PortalAavegotchiTraitsIO[10] memory portalInfo = DiamondInterface(diamondContract).portalAavegotchiTraits(_tokenId);
        collateralType[fundingNumber] = portalInfo[aavegotchi[_tokenId]].collateralType;
        maxContribution[fundingNumber] = portalInfo[aavegotchi[_tokenId]].minimumStake;
        fundingEnd[fundingNumber] = block.timestamp + (ISettings(settingsContract).maxNumberDaysPortalFunding() * 1 days);
        emit PortalFunding(
            _tokenId, 
            aavegotchi[_tokenId], 
            collateralType
        );
    }
    
     /**
     * @notice Contribute in order to summon the appointed Aavegotchi 
     * @dev Emits a ContributedAavegotchi event upon success; 
     */
    function contributePortalFunding(uint256 _fundingNumber, uint256 _stakeAmount) external nonReentrant {
        require(
            fundingStatus[_fundingNumber] == FundingStatus.FUNDING,
            "contributePortalFunding: FrAactionHub portal funding not active"
        );
        require(
            balanceOf(msg.sender) > 0,
            "contributePortalFunding: not a FrAactionHub owner"
        );
        require(
            block.timestamp <= fundingEnd[_fundingNumber],
            "contributePortalFunding: Aavegotchi funding round expired"
        );
        require(
            totalContributedToFunding[_fundingNumber] + _stakeAmount <= maxContribution[_fundingNumber],
            "contributePortalFunding: can't contribute more than the gross contribution"
        );
        ERC20lib.transferFrom(collateralType[_fundingNumber], msg.sender, address(this), _stakeAmount);
        // convert collateral to GHST
        uint256 convertedCollateralToGhst = _stakeAmount * (ISettings(settingsContract).collateralTypeToGhst(collateralType) / 10**8);
        ownerContributedCollateral[msg.sender][_fundingNumber] += _stakeAmount;
        ownerCollateralType[msg.sender][_fundingNumber] = collateralType;
        ownerContributedToFunding[msg.sender][_fundingNumber] += convertedCollateralToGhst;
        totalContributedToFunding[_fundingNumber] += convertedCollateralToGhst;
        ownerTotalContributedInGhst[msg.sender] += convertedCollateralToGhst;
        currentBalanceInGhst += convertedCollateralToGhst;
        fundingContributor[msg.sender].push(_fundingNumber);
        emit ContributedPortalFunding(
            msg.sender,
            collateralType[_fundingNumber],
            _stakeAmount
        );
    }
    
    /**
     * @notice claim an appointed Aavegotchi
     * @dev Reverts if insufficient funds to claim the Aavegotchi and pay FrAactionDAO fees
     * Emits a Summoned event upon success.
     * Callable by anyone
     */
    function claimAavegotchi(uint256 _fundingNumber) external nonReentrant {
        require(
            fundingStatus[_fundingNumber] == FundingStatus.FUNDING,
            "claimAavegotchi: FrAactionHub portal funding not active"
        );
        require(
            maxContribution[_fundingNumber] == totalContributedToFunding[_fundingNumber],
            "claimAavegotchi: insufficient funds to purchase"
        );
        (bool success, bytes memory returnData) =
            diamondContract.call(
                abi.encodeWithSignature("claimAavegotchi(uint256,uint256,uint256)", 
                fundingTarget[_fundingNumber], 
                aavegotchi[fundingTarget[_fundingNumber]], 
                maxContribution[_fundingNumber]
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
        fundingStatus[_fundingNumber] = FundingStatus.CLAIMED;
        emit ClaimedAavegotchi(maxContribution[_fundingNumber]);
    }
    
    /**
     * @notice Finalize the state of the Aavegotchi claim
     * @dev Emits a FinalizedAavegotchi event upon success; callable by anyone
     */
    function finalizePortalFunding(uint256 _fundingNumber) external nonReentrant {
        require(
            fundingStatus[_fundingNumber] == FundingStatus.CLAIMED,
            "finalizePortalFunding: FrAactionHub Aavegotchi target not claimed yet"
        );
        fundingStatus[_fundingNumber] = DiamondInterface(diamondContract).getERC721Category(diamondContract, fundingTarget[_fundingNumber]) == 3 ? FundingStatus.COMPLETED: FundingStatus.FUNDING;
        uint256 fee;
        // if the Aavegotchi claim was completed,
        if (fundingStatus == FundingStatus.COMPLETED) {
            // transfer the fee to FrAactionDAO
            uint256 tokensToMint = valueToTokens(totalContributedToFunding[_fundingNumber], 1);
            fee = _getFundingFee(totalContributedToFunding[_fundingNumber]);
            ERC20lib.transfer(collateralType[_fundingNumber], fraactionDaoMultisig, fee);
            mint(address(this), tokensToMint);
            mintedTokens[_fundingNumber] = tokensToMint;
            fundingResult[_fundingNumber] = 1;
            totalContributedToFraactionHubInGhst += totalContributedToFunding[_fundingNumber];
        } else {
            fundingResult[_fundingNumber] = 0;
        }
        fundingStatus[_fundingNumber] = FundingStatus.INACTIVE;
        currentFunding--;
        if (currentFunding == 0) {
            globalFundingStatus = FundingStatus.INACTIVE;
        }
        // set the contract status & emit result
        emit FinalizedPortalFunding(
            fundingStatus[_fundingNumber], 
            fee, 
            totalContributedToFunding[_fundingNumber]
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
        auctionEnd = block.timestamp + (ISettings(settingsContract).auctionLength() * 1 days);
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
    function endFinalAuction() external nonReentrant {
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
        if (!takenover) {
            transferToHub = ISettings(settingsContract).isHub(target);
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
            if (realmsId.length > 0) {
                transferRealms();
            } else if (nftsId.length > 0) {
                transferNfts();
            } else if (checkTickets == true) {
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
                if (totalTreasuryInGhst > 0) ERC20lib.transferFrom(ghstContract, address(this), target, totalTreasuryInGhst);
                if (totalTreasuryInMatic > 0) transferMaticOrWmatic(target, totalTreasuryInMatic);
                currentBalanceInGhst -= totalTreasuryInGhst;
                currentBalanceInMatic -= totalTreasuryInMatic;
                totalTreasuryInGhst = 0;
                totalTreasuryInMatic = 0;
                mergerStatus = MergerStatus.ENDED;
            }
        } else {
            mergerStatus = MergerStatus.ENDED;
        }
        if (mergerStatus = MergerStatus.ENDED) {
            uint256 bal = ERC20Upgradeable(ghstContract).balanceOf(address(this));
            int residualGhst = bal - currentBalanceInGhst;
            int residualMatic = address(this).balance - currentBalanceInMatic;
            uint256 exitFee = livePrice * ISettings(settingsContract).exitFee() / 1000;
            residualProfit = livePrice  - exitFee;
            uint256 ghstFinalAmount;
            uint256 maticFinalAmount;
            if (exitInGhst) {
                ERC20lib.transferFrom(ghstContract, address(this), fraactionDaoMultisig, exitFee);
                ghstFinalAmount = residualProfit + residualGhst;
            } else {
                transferMaticOrWmatic(fraactionDaoMultisig, exitFee);
                maticFinalAmount = residualProfit + residualMatic;
            }
            if (residualProfit + residualGhst > 0 && inGhst) {
                redeemedCollateral[ghstContract].push(ghstFinalAmount);
                if (collateralToRedeem[ghstContract] == 0) {
                    collateralToRedeem[ghstContract] = true;
                    collateralAvailable.push(ghstContract);
                }
            }
            if (residualProfit + residualMatic > 0 && !inGhst) {
                redeemedCollateral[thisContract].push(maticFinalAmount);
                if (collateralToRedeem[thisContract] == 0) {
                    collateralToRedeem[thisContract] = true;
                    collateralAvailable.push(thisContract);
                }
            }
            allCollateralClaimed = false;
            emit MergerFinalized(target);
        }
    }
    
    function notifyOverbid(uint256 _value) external {
        require(
            msg.sender == fundingTarget[fundingTargetToNumber[msg.sender]], 
            "notifyOverbid: caller not the auction target"
        );
        if (fundingInGhst[fundingTargetToNumber[msg.sender]]) {
            totalTreasuryInGhst += _value;
        } else {
            totalTreasuryInMatic += _value;
        }
        fundingStatus[fundingTargetToNumber[msg.sender]] = FundingStatus.FUNDING;
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
            mergerStatus = MergerStatus.ACTIVE;
            transferToHub = ISettings(settingsContract).isHub(target);
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
        if (realmsId.length > 0) {
            transferRealms();
        } else if (nftsId.length > 0) {
            transferNfts();
        } else if (checkTickets == true) {
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
        mint(stakingContributor, valueToTokens(convertedCollateralToGhst, 1));
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
        allCollateralClaimed = false;
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
     * @notice Convert GHST or MATIC value to equivalent token amount
     */
    function valueToTokens(uint256 _value, bool _inGhst)
        public
        pure
        returns (uint256 _tokens)
    {
        if (exitInGhst == _inGhst) {
            _tokens = totalSupply() / fundingTotal * _value * TOKEN_SCALE;
        } else {
            if (exitInGhst) {
                _tokens = totalSupply() / (fundingTotal * (ISettings(settingsContract).convertFundingPrice(0) / 10**8)) * _value * TOKEN_SCALE;
            } else {
                _tokens = totalSupply() / (fundingTotal * (ISettings(settingsContract).convertFundingPrice(1) / 10**8)) * _value * TOKEN_SCALE;
            }
        }
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
                    uint256 totalUsedForBid = _totalGhstOrMaticUsedForBid(_contributor, _fundingNumber);
                    if (totalUsedForBid > 0) {
                        _tokenAmount = totalUsedForBid / finalBidAmount[fundingNumber] * mintedTokens[_fundingNumber];
                    }
                    // the rest of the contributor's GHST or MATIC should be returned
                    _ghstOrMaticAmount = contribution - totalUsedForBid;
                } else {
                    _tokenAmount = contribution / totalContributedToFunding[_fundingNumber] * mintedTokens[_fundingNumber];
                }
                if (newOwner[_contributor] == true) {
                    ownersAddress.push(_contributor);
                    ownersAddressIndex[_contributor] = ownersAddress.length - 1;
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

    function wrapMaticIntoWmatic(uint256 _amount) internal {
        require(
            totalTreasuryInMatic >= _amount,
            "wrapMaticIntoWmatic: not enough Matic or wrong path parameter"
        );
        WrappedMaticInterface(wrappedMaticContract).deposit{value: _amount}();
    }

    function unwrapWmatic(uint256 _amount) internal {
        require(
            totalTreasuryInMatic >= _amount,
            "convertMaticIntoWmatic: not enough Matic or wrong path parameter"
        );
        WrappedMaticInterface(wrappedMaticContract).withdraw(_amount);
    }

    function convertTreasuryTokens(uint256 _amount, address[] _path) internal {
        require(
            _amount > 0 &&
            _path.length == 3 &&
            _path[1] == usdcContract,
            "convertTreasuryTokens: converted amount has to be positive and path length equal to 3 and second path value be USDC address"
        );
        uint256 tokenDelta;
        uint256[] memory amountOut = getAmountsOut(_amount, _path);
        if (_path[0] == wrappedMaticContract) {
            require(
                _path[0] == wrappedMaticContract && 
                totalTreasuryInMatic >= _amount,
                "convertTreasuryTokens: not enough Matic or wrong path parameter"
            );
            uint256 initialGhstBal = IERC20Upgradeable(ghstContract).balanceOf(address(this));
            QuickSwapInterface(quickSwapRouterContract).swapExactETHForTokensSupportingFeeOnTransferTokens{value: _amount}(
                amountOut[2], 
                _path, 
                address(this), 
                block.timestamp
            );
            uint256 postGhstBal = IERC20Upgradeable(ghstContract).balanceOf(address(this));
            tokenDelta = postGhstBal - initialGhstBal;
            require(
                tokenDelta > 0,
                "convertTreasuryTokens: GHST balance has to increase"
            );
            totalTreasuryInMatic -= _amount;
            currentBalanceInMatic -= _amount;
            totalTreasuryInGhst += tokenDelta;
            currentBalanceInGhst += tokenDelta;
        } else {
            require(
                _path[2] == wrappedMaticContract && 
                totalTreasuryInGhst >= _amount,
                "convertTreasuryTokens: not enough GHST or wrong path parameter"
            );
            uint256 initialMaticBal = address(this).balance;
            IERC20Upgradeable(ghstContract).approve(quickSwapRouterContract, _amount);
            QuickSwapInterface(quickSwapRouterContract).swapExactTokensForETHSupportingFeeOnTransferTokens(
                _amount, 
                amountOut[2], 
                _path, 
                address(this), 
                block.timestamp
            );
            uint256 postMaticBal = address(this).balance;
            tokenDelta = postMaticBal - initialMaticBal;
            require(
                tokenDelta > 0,
                "convertTreasuryTokens: MATIC balance has to increase"
            );
            totalTreasuryInGhst -= _amount;
            currentBalanceInGhst -= _amount;
            totalTreasuryInMatic += tokenDelta;
            currentBalanceInMatic += tokenDelta;
        }
        emit ConvertedTreasuryTokens(_path[0], _amount, tokenDelta);
    }

    function convertTokens(uint256 _unwrappedMatic, uint256 _amount, address[] _path) internal {
        require(
            _amount > 0,
            "convertTokens: converted amount has to be positive"
        );
        require(
            _path[0] != ghstContract &&
            _path[_path.length - 1] != ghstContract,
            "convertTokens: use convertTreasuryTokens() with GHST input or output"
        );
        uint256 tokenDelta;
        uint256[] memory amountOut = getAmountsOut(_path);
        if (_unwrappedMatic == 1) {
            require(
                _path[0] == wrappedMaticContract && 
                totalTreasuryInMatic >= _amount,
                "convertTokens: not enough Matic or wrong path parameter"
            );
            QuickSwapInterface(quickSwapRouterContract).swapExactETHForTokensSupportingFeeOnTransferTokens{value: _amount}(
                amountOut[amountOut.length - 1], 
                _path, 
                address(this), 
                block.timestamp
            );
            totalTreasuryInMatic -= _amount;
            currentBalanceInMatic -= _amount;
        } else if (_unwrappedMatic == 2) {
            require(
                _path[2] == wrappedMaticContract,
                "convertTokens: last path value must be WMATIC"
            );
            require(
                ownedErc20[_path[0]] >= _amount,
                "convertTokens: not enough token balance"
            );
            IERC20Upgradeable(_path[0]).approve(quickSwapRouterContract, _amount);
            uint256 initialMaticBal = address(this).balance;
            QuickSwapInterface(quickSwapRouterContract).swapExactTokensForETHSupportingFeeOnTransferTokens(
                _amount, 
                amountOut[amountOut.length - 1], 
                _path, 
                address(this), 
                block.timestamp
            );
            ownedErc20[_path[0]] -= _amount;
            uint256 postMaticBal = address(this).balance;
            tokenDelta = postMaticBal - initialMaticBal;
            require(
                tokenDelta > 0,
                "convertTokens: MATIC balance has to increase"
            );
            totalTreasuryInMatic += tokenDelta;
            currentBalanceInMatic += tokenDelta;
        } else {
            require(
                ownedErc20[_path[0]] >= _amount,
                "convertTokens: not enough token balance"
            );
            uint256 initialTokenBal = IERC20Upgradeable(_path[_path.length - 1]).balanceOf(address(this));
            IERC20Upgradeable(_path[0]).approve(quickSwapRouterContract, _amount);
            QuickSwapInterface(quickSwapRouterContract).swapExactTokensForTokensSupportingFeeOnTransferTokens(
                _amount, 
                amountOut[amountOut.length - 1],
                _path, 
                address(this), 
                block.timestamp
            );
            uint256 postTokenBal = IERC20Upgradeable(_path[_path.length - 1]).balanceOf(address(this));
            tokenDelta = postTokenBal - initialTokenBal;
            ownedErc20[_path[0]] -= _amount;
            ownedErc20[_path[_path.length - 1]] += tokenDelta;
        }
        emit ConvertedTokens(_unwrappedMatic, _amount, tokenDelta);
    }

    function addLiquidity(address _tokenA, address _tokenB, uint _amountADesired, uint _amountBDesired, uint _maxSlippage) internal {
        require(
            _amountADesired > 0 && _amountBDesired > 0,
            "addLiquidity: amount desired mut be strictly positive"
        );
        address pair = QuickSwapInterface(quickSwapFactoryContract).getPair(_tokenA, _tokenB);
        (uint256 reserveTokenA, uint256 reserveTokenB, ) = QuickSwapInterface(pair).getReserves();
        uint256 amountBOptimized = QuickSwapInterface(quickSwapRouterContract).quote(_tokenA, reserveTokenA, reserveTokenB);
        uint256 minAmountTokensA = _maxSlippage / 1000 * _tokenA;
        uint256 minAmountTokensB = _maxSlippage / 1000 * amountBOptimized;
        if (_tokenA == ghstContract) {
            require(
                totalTreasuryInGhst >= _amountADesired,
                "addLiquidity: not enough GHST"
            );
        } else {
            require(
                ownedErc20[_tokenA] >= _amountADesired,
                "addLiquidity: not enough Token A"
            );
        }
        if (_tokenB == ghstContract) {
            require(
                totalTreasuryInGhst >= amountBOptimized,
                "addLiquidity: not enough GHST "
            );
        } else {
            require(
                ownedErc20[_tokenB] >= amountBOptimized,
                "addLiquidity: not enough Token B"
            );
        }
        IERC20Upgradeable(_tokenA).approve(quickSwapRouterContract, _amountADesired);
        IERC20Upgradeable(_tokenB).approve(quickSwapRouterContract, amountBOptimized);
        (uint256 amountTokenA, uint256 amountTokenB, uint256 liquidityToken) = 
            QuickSwapInterface(quickSwapRouterContract).addLiquidity(
                _tokenA, 
                _tokenB, 
                _amountADesired, 
                amountBOptimized, 
                minAmountTokensA, 
                minAmountTokensB,
                address(this),
                block.timestamp
            );
        if (_tokenA == ghstContract) {
            totalTreasuryInGhst -= amountTokenA;
            currentBalanceInGhst -= amountTokenA;
        } else if (_tokenB == ghstContract) {
            totalTreasuryInGhst -= amountTokenB;
            currentBalanceInGhst -= amountTokenB;
        }
        if (ownedErc20[pair] == 0 && erc20Index[pair] == 0) {
            erc20tokens.push(pair);
            erc20Index[pair] = erc20Tokens.length - 1;
        }
        ownedErc20[pair] += liquidityToken;
        staked[_tokenA] += amountTokenA;
        staked[_tokenB] += amountTokenB;
        ownedErc20[_tokenA] -= amountTokenA;
        ownedErc20[_tokenB] -= amountTokenB;
        emit AddedLiquidity(_tokenA, _tokenB, amountTokenA, amountTokenB, liquidityToken);
    }

    function addETHLiquidity(address _token, address _maticAmount, uint _amountDesired, uint _amountMaticDesired, uint _maxSlippage) internal {
        require(
            _amountDesired > 0 && _amountMaticDesired > 0,
            "addETHLiquidity: amount desired mut be strictly positive"
        );
        address pair = QuickSwapInterface(quickSwapFactoryContract).getPair(_tokenA, wrappedMaticContract);
        (uint256 reserveToken, uint256 reserveWmatic, ) = QuickSwapInterface(pair).getReserves();
        uint256 amountWmaticOptimized = QuickSwapInterface(quickSwapRouterContract).quote(_tokenA, reserveToken, reserveWmatic);
        uint256 minAmountTokens = _maxSlippage / 1000 * _token;
        uint256 minAmountWmatic = _maxSlippage / 1000 * amountWmaticOptimized;
        if (_token == ghstContract) {
            require(
                totalTreasuryInGhst >= _amountDesired,
                "addETHLiquidity: not enough GHST"
            );
        } else {
            require(
                ownedErc20[_token] >= _amountDesired,
                "addETHLiquidity: not enough Token"
            );
        }
        require(
            totalTreasuryInMatic >= amountWmaticOptimized,
            "addETHLiquidity: not enough MATIC"
        );
        IERC20Upgradeable(_token).approve(quickSwapRouterContract, _amountDesired);
        (uint256 amountToken, uint256 amountMatic, uint256 liquidityToken) = 
            QuickSwapInterface(quickSwapRouterContract).addLiquidityETH{value: amountWmaticOptimized}(
                _token,  
                _amountDesired, 
                minAmountTokens, 
                minAmountWmatic,
                address(this),
                block.timestamp
            );
        if (_token == ghstContract) {
            totalTreasuryInGhst -= amountToken;
            currentBalanceInGhst -= amountToken;
        }
        totalTreasuryInGhst -= amountMatic;
        currentBalanceInGhst -= amountMatic;
        if (ownedErc20[pair] == 0) {
            erc20tokens.push(pair);
            erc20Index[pair] = erc20Tokens.length - 1;
        }
        staked[_token] += amountToken;
        ownedErc20[_token] -= amountToken;
        ownedErc20[pair] += liquidityToken;
        emit AddedETHLiquidity(_token, amountToken, amountMatic, liquidityToken);
    }    

    function removeLiquidity(
        address _tokenA, 
        address _tokenB, 
        uint _liquidity, 
        uint _maxSlippage
    ) internal {
        require(
            _liquidity > 0,
            "removeLiquidity: liquidity must be strictly positive"
        );
        address pair = QuickSwapInterface(quickSwapFactoryContract).getPair(_tokenA, _tokenB);
        require(
            ownedErc20[pair] >= _liquidity,
            "removeLiquidity: not enough Token"
        );
        uint256 balance = IERC20Upgradeable(pair).balanceOf(address(this));
        (uint256 reserveTokenA, uint256 reserveTokenB, ) = QuickSwapInterface(pair).getReserves();
        uint256 supply = IERC20Upgradeable(pair).totalSupply();
        uint256 desiredTokenA = (_liquidity * reserveTokenA) / supply;
        uint256 desiredTokenB = (_liquidity * reserveTokenB) / supply;
        uint256 amountAMin = desiredTokenA * (_maxSlippage / 1000);
        uint256 amountBMin = desiredTokenB * (_maxSlippage / 1000);
        (uint256 amountTokenA, uint256 amountTokenB) = 
            QuickSwapInterface(quickSwapRouterContract).removeLiquidity(
                _tokenA,
                _tokenB,
                _liquidity,
                amountAMin,
                amountBMin,
                address(this);
                block.timestamp
            );
        if (_liquidity / balance == 1) {
            erc20tokens[erc20Index[pair]] = erc20tokens[erc20tokens.length - 1];
            erc20Index[erc20tokens.length - 1] = erc20Index[pair];
            delete erc20Index[pair];
            erc20tokens.pop();
        }
        staked[_tokenA] -= staked[_tokenA] * (_liquidity / balance);
        staked[_tokenB] -= staked[_tokenB] * (_liquidity / balance);
        ownedErc20[_tokenA] += amountTokenA;
        ownedErc20[_tokenB] += amountTokenB;
        emit RemovedLiquidity(_tokenA, _tokenB, _liquidity, amountTokenA, amountTokenB);
    }

    function removeLiquidityETH(
        address _token,  
        uint _liquidity, 
        uint _maxSlippage
    ) internal {
        address pair = QuickSwapInterface(quickSwapFactoryContract).getPair(_tokenA, wrappedMaticContract);
        require(
            _liquidity > 0,
            "removeLiquidityETH: liquidity must be strictly positive"
        );
        require(
            ownedErc20[pair] >= _liquidity,
            "removeLiquidityETH: not enough Token"
        );
        uint256 balance = IERC20Upgradeable(pair).balanceOf(address(this));
        (uint256 reserveToken, uint256 reserveWmatic, ) = QuickSwapInterface(pair).getReserves();
        uint256 supply = IERC20Upgradeable(pair).totalSupply();
        uint256 desiredToken = (_liquidity * reserveToken) / supply;
        uint256 desiredMatic = (_liquidity * reserveWmatic) / supply;
        uint256 amountMin = desiredToken * (_maxSlippage / 1000);
        uint256 amountMaticMin = desiredWmatic * (_maxSlippage / 1000);
        (uint256 amountToken, uint256 amountMatic) = 
            QuickSwapInterface(quickSwapRouterContract).removeLiquidityETHSupportingFeeOnTransferTokens(
                _token,
                _liquidity,
                amountMin,
                amountMaticMin,
                address(this);
                block.timestamp
            );
        if (_liquidity / balance == 1) {
            erc20tokens[erc20Index[pair]] = erc20tokens[erc20tokens.length - 1];
            erc20Index[erc20tokens.length - 1] = erc20Index[pair];
            delete erc20Index[pair];
            erc20tokens.pop();
        }
        staked[_token] -= staked[_token] * (_liquidity / balance);
        ownedErc20[_tokenA] += amountToken;
        totalTreasuryInMatic += amountMatic;
        currentBalanceInMatic += amountMatic;
        emit RemovedLiquidity(_token, _tokenB, _liquidity, amountTokenA, amountTokenB);
    }

    function supply(address _asset, uint256 _amount) internal {
        require(
            ownedErc20[_asset] >= _amount,
            "supply: not enough Token"
        );
        require(
            _amount > 0,
            "supply: amount must be strictly positive"
        );
        require(
            _asset != address(0),
            "supply: asset address cannot be null"
        );
        AaveInterface(aavePoolContract).supply(
            _asset,
            _amount,
            address(this),
            0
        );
        ownedErc20[_asset] -= _amount;
        (address aTokenAddress,,) = AaveInterface(aaveProtocolDataProviderContract).getReserveTokensAddresses(_asset);
        if (ownedErc20[aTokenAddress] == 0) {
            erc20tokens.push(aTokenAddress);
            erc20Index[aTokenAddress] = erc20Tokens.length - 1;
        }
        if (assetToATokenAddress[_asset] == address(0)) assetToATokenAddress[_asset] = aTokenAddress;
        ownedErc20[aTokenAddress] += _amount;
        emit Supplied(_asset, _amount, aTokenAddress);
    }

    function withdraw(address _asset, uint256 _amount) internal {
        require(
            _amount > 0,
            "withdraw: amount must be strictly positive"
        );
        require(
            _asset != address(0),
            "withdraw: asset address cannot be null"
        );
        (address aTokenAddress,,) = AaveInterface(aaveProtocolDataProviderContract).getReserveTokensAddresses(_asset);
        require(
            aTokens[aTokenAddress] >= _amount,
            "withdraw: not enough aToken"
        );
        uint256 tokenDelta;
        uint256 initialTokenBal = IERC20Upgradeable(_asset).balanceOf(address(this));
        AaveInterface(aavePoolContract).withdraw(
            _asset,
            _amount,
            address(this)
        );
        uint256 postTokenBal = IERC20Upgradeable(_asset).balanceOf(address(this));
        tokenDelta = postTokenBal - initialTokenBal;
        ownedErc20[_asset] += tokenDelta;
        ownedErc20[aTokenAddress] -= _amount;
        if (ownedErc20[aTokenAddress] == 0) {
            erc20tokens[erc20Index[aTokenAddress]] = erc20tokens[erc20tokens.length - 1];
            erc20Index[erc20tokens.length - 1] = erc20Index[aTokenAddress];
            delete erc20Index[aTokenAddress];
            erc20tokens.pop();
        }
        emit Withdrawn(_asset, _amount, aTokenAddress, tokenDelta);
    }

    function borrow(address _asset, uint256 _amount, uint256 _interestMode) internal {
        require(
            _amount > 0,
            "borrow: amount must be strictly positive"
        );
        require(
            _asset != address(0),
            "borrow: asset address cannot be null"
        );
        require(
            _interestMode == 1 || _interestMode == 2,
            "borrow: interest mode has to be stable or variable (1 or 2 as input)"
        );
        AaveInterface(aavePoolContract).borrow(
            _asset,
            _amount,
            _interestMode,
            0,
            address(this)
        );
        if (ownedErc20[_asset] == 0 && erc20Index[_asset] == 0) {
            erc20tokens.push(_asset);
            erc20Index[_asset] = erc20Tokens.length - 1;
        }
        ownedErc20[_asset] += _amount;
        emit Borrowed(_asset, _amount, _interestMode);
    }

    function repay(address _asset, uint256 _amount, uint256 _interestMode) internal {
        require(
            _amount > 0,
            "repay: amount must be strictly positive"
        );
        require(
            _asset != address(0),
            "repay: asset address cannot be null"
        );
        require(
            _interestMode == 1 || _interestMode == 2,
            "repay: interest mode has to be stable or variable (1 or 2 as input)"
        );
        AaveInterface(aavePoolContract).repay(
            _asset,
            _amount,
            _interestMode,
            address(this)
        );
        ownedErc20[_asset] -= _amount;
        if (ownedErc20[_asset] == 0 && erc20Index[_asset] == 0) {
            erc20tokens[erc20Index[_asset]] = erc20tokens[erc20tokens.length - 1];
            erc20Index[erc20tokens.length - 1] = erc20Index[_asset];
            delete erc20Index[_asset];
            erc20tokens.pop();
        }
        emit Repaid(_asset, _amount, _interestMode);
    }

    function repayWithATokens(address _asset, uint256 _amount, uint256 _interestMode) internal {
        require(
            _amount > 0,
            "repayWithATokens: amount must be strictly positive"
        );
        require(
            _asset != address(0),
            "repayWithATokens: asset address cannot be null"
        );
        require(
            _interestMode == 1 || _interestMode == 2,
            "repayWithATokens: interest mode has to be stable or variable (1 or 2 as input)"
        );
        AaveInterface(aavePoolContract).repayWithATokens(
            _asset,
            _amount,
            _interestMode
        );
        ownedErc20[assetToATokenAddress[_asset]] -= _amount;
        if (ownedErc20[_asset] == 0 && erc20Index[_asset] == 0) {
            erc20tokens[erc20Index[_asset]] = erc20tokens[erc20tokens.length - 1];
            erc20Index[erc20tokens.length - 1] = erc20Index[_asset];
            delete erc20Index[_asset];
            erc20tokens.pop();
        }
        emit RepaidWithATokens(_asset, _amount, _interestMode);
    }

    function swapBorrowRateMode(address _asset, uint256 _interestMode) internal {
        require(
            _asset != address(0),
            "swapBorrowRateMode: asset address cannot be null"
        );
        require(
            _interestMode == 1 || _interestMode == 2,
            "swapBorrowRateMode: interest mode has to be stable or variable (1 or 2 as input)"
        );
        AaveInterface(aavePoolContract).swapBorrowRateMode(
            _asset,
            _interestMode
        );
        emit SwappedBorrowRateMode(_asset, _interestMode);
    }

    function setUserUseReserveAsCollateral(address _asset, bool _useAsCollateral) internal {
        require(
            _asset != address(0),
            "setUserUseReserveAsCollateral: asset address cannot be null"
        );
        AaveInterface(aavePoolContract).setUserUseReserveAsCollateral(_asset,_useAsCollateral);
        emit SetUserUseReserveAsCollateral(_asset, _useAsCollateral);
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
            WrappedMaticInterface(wrappedMaticContract).deposit{value: _value}();
            WrappedMaticInterface(wrappedMaticContract).transfer(_to, _value);
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