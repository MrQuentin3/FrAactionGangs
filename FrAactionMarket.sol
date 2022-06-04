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

    // Category = 0: realms, 1: aavegotchi & portals, 2: items, 3: tickets, 4: non-Aavegotchi NFTs, 5: non-Aavegotchi ERC1155 tokens, 6: ERC20 tokens
    function addToken(
        bool _forSale, 
        bool _inGhst,
        uint256[] calldata _childTokensId, 
        uint256[] calldata _childTokensQuantity,
        uint256 _tokenId, 
        uint256 _category, 
        uint256 _gotchiCategory,
        uint256 _quantity, 
        uint256 _numberOfDays, 
        uint256 _priceInWei,
        address _tokenAddress
    ) external payable nonReentrant {
        if (_category == 2 || _category == 3 || _category == 5) {
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
        listingId++;
        if (_forSale) {
            if (_category == 0 || _category == 1 || _category == 4) {
                require(DiamondInterface(_tokenAddress).ownerOf(_tokenId) == msg.sender,
                    "addToken: caller not owner of this nft"
                );
                sellingNfts[_tokenId] = true;
            } else if (_category == 2 || _category == 3 || _category == 5 || _category == 6) {
                require(DiamondInterface(_tokenAddress).balanceOf(msg.sender, _tokenId) == _quantity,
                    "addToken: caller not owner of this amount of this item type"
                );
                token[listingId].quantity = _quantity;
                sellingFungible[_tokenId] += _quantity;
            }
            token[listingId].forSale = true;
        } else {
            uint256 price;
            if (_category == 0 || _category == 1 || _category == 4) {
                price = _priceInWei;
                buyingNfts[_tokenId] = true;
            }
            if (_category == 2 || _category == 3 || _category == 5 || _category == 6) {
                token[listingId].quantity = _quantity;
                price = _quantity * _priceInWei;
                buyingFungible[_tokenId] += _quantity;
            }
            if (_inGhst) {
                ERC20lib.transferFrom(ghstContract, msg.sender, address(this), price);
            } else {
                transferMaticOrWmatic(address(this), price);
            }
            buyerFunding[msg.sender][listingId] = price;
        }
        if (SettingsInterface(settingsContract).fraactionHubRegistry[msg.sender] != 0) token[listingId].isHub = true;
        if (_inGhst) token[listingId].inGhst = true;
        token[listingId].tokenId = _tokenId;
        token[listingId].active = true;
        token[listingId].author = msg.sender;
        token[listingId].tokenAddress = _tokenAddress;
        token[listingId].category = _category;
        token[listingId].gotchiCategory = _category;
        token[listingId].priceInWei = _priceInWei;
        token[listingId].childTokensId = _childTokensId;
        token[listingId].childTokensQuantity = _childTokensQuantity;
        token[listingId].listingEnd = block.timestamp * days * _numberOfDays;
        emit TokenAdded(msg.sender, _forSale, _tokenId, _category, tokenNumber);
    }

    function removeToken(uint256 _listingId) external {
        Token memory params = token[_listingId];
        require(
            msg.sender == params.author,
            "removeToken: not the owner of the listed token"
        );
        if (!params.forSale) {
            if (params.inGhst) {
                ERC20lib.transferFrom(ghstContract, address(this), msg.sender, buyerFunding[msg.sender][_listingId]);
            } else {
                transferMaticOrWmatic(msg.sender, buyerFunding[msg.sender][_listingId]);
            }
        }
        if (params.category == 0 || params.category == 1 || params.category == 4) {
            if (params.forSale) {
                delete sellingNfts[params.tokenId];
            } else {
                delete buyingNfts[params.tokenId];
            }
        } else if (params.category == 2 || params.category == 3 || params.category == 5 || _category == 6) {
            if (params.forSale) {
                sellingFungible[params.tokenId] -= params.quantity;
            } else {
                buyingFungible[params.tokenId] -= params.quantity;
            }
        }
        delete token[_listingId];
        emit TokenRemoved(msg.sender, _listingId);
    }

    function executeTokenTransaction(uint256 _listingId) external nonReentrant {
        Token memory params = token[_listingId];
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
                    "executeTokenTransaction: NFT not owner of this item"
                );
            }
        }
        uint256 price;
        if (params.category == 0 || params.category == 1 || params.category == 4) {
            require(DiamondInterface(params.tokenAddress).ownerOf(params.tokenId) == seller,
                "executeTokenTransaction: caller not owner of this nft"
            );
        } else if (params.category == 2 || params.category == 3 || params.category == 5) {
            require(DiamondInterface(params.tokenAddress).balanceOf(seller, params.tokenId) == params.quantity,
                "executeTokenTransaction: caller not owner of this amount of this item type"
            );
            price = params.tokenId * params.quantity;
        }
        if (params.inGhst) {
            ERC20lib.transferFrom(ghstContract, buyer, seller, price);
        } else {
            transferMaticOrWmatic(seller, price);
        }
        if (!params.forSale) buyer = params.author;
        if (params.category == 0 || params.category == 1 || params.category == 4) {
            IERC721Upgradeable(params.tokenAddress).safeTransferFrom(seller, buyer, tokenParams.tokenId);
            if (params.forSale) {
                delete sellingNfts[params.tokenId];
            } else {
                delete buyingNfts[params.tokenId];
            }
        } else (params.category == 2 || params.category == 3 || params.category == 5 || params.category == 6) {
            if (params.category != 6) IERC1155Upgradeable(params.tokenAddress).safeTransferFrom(seller, buyer, params.tokenId, params.quantity, new bytes(0));
            if (params.category == 6) libERC20.transferFrom.transferFrom(params.tokenAddress, seller, buyer, params.quantity);
            if (params.forSale) {
                sellingFungible[params.tokenId] -= params.quantity;
            } else {
                buyingFungible[params.tokenId] -= params.quantity;
            }
        } 
        params.active = false;
        emit ExecutedTransaction(buyer, seller, _listingId, price);
    }
