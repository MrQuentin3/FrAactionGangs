// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

/*
FrAactionMarket v1.0
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

contract FraactionMarket is ReentrancyGuardUpgradeable {

    struct Token {
        bool active;
        bool forSale;
        bool inGhst;
        bool isHub;
        address author;
        address tokenAddress;
        uint256 tokenId;
        uint256 category;
        uint256 gotchiCategory;
        uint256 quantity;
        uint256 priceInWei;
        uint256 listingEnd;
        uint256[] childTokensId;
        uint256[] childTokensQuantity;
    }

    address diamondContract = 0x86935F11C86623deC8a25696E1C19a8659CbF95d;
    address settingsContract = ;
    mapping(uint256 => Token) public token;
    mapping(uint256 => FraactionToken) public fraactionToken;
    mapping(uint256 => bool) public sellingNfts;
    mapping(uint256 => uint256) public sellingFungible;
    mapping(uint256 => bool) public buyingNfts;
    mapping(uint256 => uint256) public buyingFungible;

    // Category = 0: realms, 1: aavegotchi, 2: closed portals, 3: open portals, 4: items, 5: tickets, 6: non-Aavegotchi NFTs, 7: non-Aavegotchi ERC1155 tokens, 8: ERC20 tokens
    function addToken(
        bool _forSale, 
        bool _inGhst,
        uint256[] calldata _childTokensId, 
        uint256[] calldata _childTokensQuantity,
        uint256 _tokenId, 
        uint256 _category, 
        uint256 _quantity, 
        uint256 _numberOfDays, 
        uint256 _priceInWei,
        address _tokenAddress
    ) external payable nonReentrant {
        if (_category == 4 || _category == 5 || _category == 7 || _category == 8) {
            require(
                _quantity > 0,
                "addToken: quantity has to be superior to zero"
            );
        }
        require(
            _childTokensId.length < ISettings(settingsContract).MaxTransferLimit(), 
            "addToken: cannot add more tokens than the GovSettings allowed limit"
        );
        require(
            _numberOfDays > ISettings(settingsContract).minSaleLength(),
            "addToken: listing length has to be valid"
        );
        if (_category == 1 || _category == 2 || _category == 3) {
            require(
                DiamondInterface(diamondContract).getERC721Category(diamondContract, _tokenId) == _category,
                "addToken: invalid gotchi category"
            );
        }
        Token memory token;
        listingId++;
        token.priceInWei = _priceInWei * (1000 + ISettings(settingsContract).buyerFee()) / 1000;
        token.quantity = _quantity;
        if (_forSale) {
            if (_category == 1) {
                for (uint i = 0; i < params.childTokensId.length; i++) {
                    require(DiamondInterface(diamondContract).balanceOfToken(diamondContract, params.tokenId, params.childTokensId[i]) == params.childTokensQuantity[i],
                        "addToken: NFT not owner of this child token"
                    );
                }
            } else if (_category == 0 || _category == 2 || _category == 3 || _category == 6) {
                IERC721Upgradeable(_tokenAddress).safeTransferFrom(msg.sender, address(this), _tokenId);
            } else if (_category == 8) {
                libERC20.transferFrom(_tokenAddress, msg.sender, address(this), _quantity);
            } else if (_category == 4 || _category == 5 || _category == 7) {
                IERC1155Upgradeable(_tokenAddress).safeTransferFrom(msg.sender, address(this), _quantity, new bytes(0));
            }
            token.forSale = true;
        } else {
            uint256 price;
            if (_category == 0 || _category == 1 || _category == 2 || _category == 3 || _category == 6) {
                price = _priceInWei;
            }
            if (_category == 4 || _category == 5 || _category == 7 || _category == 8) {
                price = _quantity * _priceInWei;
            }
            if (_inGhst) {
                ERC20lib.transferFrom(ghstContract, msg.sender, address(this), price);
            } else {
                transferMaticOrWmatic(address(this), price);
            }
        }
        if (SettingsInterface(settingsContract).fraactionHubRegistry[msg.sender] != 0) token.isHub = true;
        if (_inGhst) token.inGhst = true;
        token.tokenId = _tokenId;
        token.active = true;
        token.author = msg.sender;
        token.tokenAddress = _tokenAddress;
        token.category = _category;
        token.childTokensId = _childTokensId;
        token.childTokensQuantity = _childTokensQuantity;
        token.listingEnd = block.timestamp * 1 days * _numberOfDays;
        activeListing.push(token);
        listingIdToListingIndex[listingId] = activeListing.length - 1;
        ownerActiveTx[msg.sender].push(listingId);
        listingIdToOwnerIndex[listingId] = ownerActiveTx[msg.sender].length - 1;
        activeCategoryListing[_category].push(listingId);
        listingIdToCategoryIndex[listingId] = activeCategoryListing[_category].length - 1;
        emit TokenAdded(msg.sender, listingId, _forSale, _category, _tokenAddress, _tokenId, _quantity);
    }

    function removeToken(uint256 _listingId) external {
        uint256 tokenIndex = ownerActiveTx[msg.sender][listingIdToOwnerIndex[_listingId]]; 
        Token memory params = activeListing[tokenIndex];
        require(
            params.active == true,
            "removeToken: listingId not active"
        );
        require(
            msg.sender == params.author,
            "removeToken: not the owner of the listed token"
        );
        uint256 price;
        if (params.forSale) {
            if (params.category == 0 || params.category == 2 || params.category == 3 || params.category == 6) {
                IERC721Upgradeable(params.tokenAddress).safeTransferFrom(address(this), params.author, _tokenId);
            } else if (params.category == 8) {
                libERC20.transferFrom(params.tokenAddress, address(this), params.author, _quantity);
            } else if (params.category == 4 || params.category == 5 || params.category == 7) {
                IERC1155Upgradeable(params.tokenAddress).safeTransferFrom(address(this), params.author, _quantity, new bytes(0));
            }
        } else {
            if (params.category == 0 || params.category == 1 || params.category == 2 || params.category == 3 || params.category == 6) {
                price = _priceInWei;
            } else if (params.category == 4 || params.category == 5 || params.category == 7 || params.category == 8) {
                price = _quantity * _priceInWei;
            }
            if (params.inGhst) {
                ERC20lib.transferFrom(ghstContract, address(this), msg.sender, price);
            } else {
                transferMaticOrWmatic(msg.sender, price);
            }
        }
        activeListing[listingIdToListingIndex[_listingId]] = activeListing[activeListing.length - 1];
        listingIdToListingIndex[listingId] = listingIdToListingIndex[_listingId];
        activeListing.pop();
        ownerActiveTx[msg.sender][listingIdToOwnerIndex[_listingId]] = ownerActiveTx[msg.sender][ownerActiveTx.length - 1];
        listingIdToOwnerIndex[ownerActiveTx[msg.sender][ownerActiveTx.length - 1]] = listingIdToOwnerIndex[_listingId];
        ownerActiveTx.pop();
        activeCategoryListing[params.category][listingIdToCategoryIndex[_listingId]] = activeCategoryListing[params.category][listingIdToCategoryIndex[activeCategoryListing.length - 1]];
        listingIdToCategoryIndex[activeCategoryListing[params.category][listingIdToCategoryIndex[activeCategoryListing.length - 1]]] = listingIdToCategoryIndex[_listingId];
        activeCategoryListing.pop();
        delete listingIdToListingIndex[_listingId];
        delete listingIdToOwnerIndex[_listingId];
        delete listingIdToCategoryIndex[_listingId];
        emit TokenRemoved(msg.sender, _listingId);
    }

    function executeTokenTransaction(uint256 _listingId) external nonReentrant {
        uint256 tokenIndex = ownerActiveTx[msg.sender][listingIdToOwnerIndex[_listingId]]; 
        Token memory = activeListing[tokenIndex];
        require(
            block.timestamp < params.listingEnd,
            "executeTokenTransaction: listing expired"
        );
        require(
            params.active == true,
            "executeTokenTransaction: token already purchased"
        );
        address seller;
        address buyer;
        if (params.forSale) {
            seller = params.author;
            buyer = msg.sender;
        } else {
            seller = msg.sender;
            buyer = address(this);
            for (uint i = 0; i < params.childTokensId.length; i++) {
                require(DiamondInterface(diamondContract).balanceOfToken(diamondContract, params.tokenId, params.childTokensId[i]) == params.childTokensQuantity[i],
                    "executeTokenTransaction: NFT not owner of this child token"
                );
            }
        }
        uint256 price;
        if (params.category == 0 || params.category == 1 || params.category == 2 || params.category == 3 || params.category == 6) {
            price = params.priceInWei;
        } else if (params.category == 4 || params.category == 5 || params.category == 7 || params.category == 8) {
            price = params.priceInWei * params.quantity;
        }
        uint256 fee = ((ISettings(settingsContract).sellerFee() + ISettings(settingsContract).buyerFee())) / 1000 * price;
        uint256 sellerProfit = price - fee;
        if (params.inGhst) {
            ERC20lib.transferFrom(ghstContract, buyer, fraactionDaoMultisig, fee);
            ERC20lib.transferFrom(ghstContract, buyer, seller, sellerProfit);
        } else {
            transferMaticOrWmatic(fraactionDaoMultisig, fee);
            transferMaticOrWmatic(seller, sellerProfit);
        }
        if (params.forSale && params.category != 1) {
            seller = address(this);
        } else if (!params.forSale) {
            buyer = params.author;
        }
        if (params.category == 0 || params.category == 1 || params.category == 2 || params.category == 3 || params.category == 6) {
            IERC721Upgradeable(params.tokenAddress).safeTransferFrom(seller, buyer, tokenParams.tokenId);
        } else (params.category == 4 || params.category == 5 || params.category == 7 || params.category == 8) {
            if (params.category != 8) IERC1155Upgradeable(params.tokenAddress).safeTransferFrom(seller, buyer, params.tokenId, params.quantity, new bytes(0));
            if (params.category == 8) libERC20.transferFrom(params.tokenAddress, seller, buyer, params.quantity);
        } 
        activeListing[listingIdToListingIndex[_listingId]] = activeListing[activeListing.length - 1];
        listingIdToListingIndex[listingId] = listingIdToListingIndex[_listingId];
        activeListing.pop();
        ownerActiveTx[msg.sender][listingIdToOwnerIndex[_listingId]] = ownerActiveTx[msg.sender][ownerActiveTx.length - 1];
        listingIdToOwnerIndex[ownerActiveTx[msg.sender][ownerActiveTx.length - 1]] = listingIdToOwnerIndex[_listingId];
        ownerActiveTx.pop();
        activeCategoryListing[params.category][listingIdToCategoryIndex[_listingId]] = activeCategoryListing[params.category][listingIdToCategoryIndex[activeCategoryListing.length - 1]];
        listingIdToCategoryIndex[activeCategoryListing[params.category][listingIdToCategoryIndex[activeCategoryListing.length - 1]]] = listingIdToCategoryIndex[_listingId];
        activeCategoryListing.pop();
        delete listingIdToListingIndex[_listingId];
        delete listingIdToOwnerIndex[_listingId];
        delete listingIdToCategoryIndex[_listingId];
        if (params.isHub) FraactionInterface(msg.sender).notifyTxFromMarket(params.tokenAddress, params.tokenId, sellerProfit);
        emit ExecutedTransaction(buyer, seller, _listingId, price);
    }
