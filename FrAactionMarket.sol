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
        uint256 quantity;
        uint256 priceInWei;
        uint256 listingEnd;
        uint256[] childTokensId;
        uint256[] childTokensQuantity;
    }

    struct FraactionToken {
        bool active;
        bool forSale;
        bool inGhst;
        bool isHub;
        address author;
        address tokenAddress;
        uint256 hubOrGangId;
        uint256 quantity;
        uint256 priceInWei;
        uint256 listingEnd;
    }

    address diamondContract = 0x86935F11C86623deC8a25696E1C19a8659CbF95d;
    address settingsContract = ;
    mapping(uint256 => Token) public token;
    mapping(uint256 => FraactionToken) public fraactionToken;
    mapping(uint256 => bool) public sellingNfts;
    mapping(uint256 => uint256) public sellingItems;
    mapping(uint256 => bool) public buyingNfts;
    mapping(uint256 => uint256) public buyingItems;

    // Category = 0: realms, 1: aavegotchi & portals, 2: items, 3: tickets, 4: non-Aavegotchi NFTs, 5: 1155 non-Aavegotchi
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
    ) external nonReentrant {
        require(
            _tokenId != 0,
            "addToken: token ID has to be valid"
        );
        if (_category == 2 || _category == 3) {
            require(
                _quantity > 0,
                "addToken: quantity has to be superior to zero"
            );
        }
        require(
            _childTokensId.length + _childTokensQuantity.length + _childTokensCategory.length + _childTokensAddress.length < ISettings(settingsContract).MaxTransferLimit(), 
            "addToken: cannot add more tokens than the GovSettings allowed limit"
        );
        require(
            _numberOfDays > ISettings(settingsContract).minSaleLength(),
            "addToken: token ID has to be valid"
        );
        tokenNumber++;
        if (_forSale) {
            if (_category == 0 || _category == 1 || _category == 4) {
                require(DiamondInterface(_tokenAddress).ownerOf(_tokenId) == msg.sender,
                    "addToken: caller not owner of this nft"
                );
                sellingNfts[_tokenId] = true;
            } else if (_category == 2 || _category == 3) {
                require(DiamondInterface(_tokenAddress).balanceOf(msg.sender, _tokenId) == _quantity,
                    "addToken: caller not owner of this amount of this item type"
                );
                token[tokenNumber].quantity = _quantity;
                sellingItems[_tokenId] += _quantity;
            }
            token[tokenNumber].forSale = true;
        } else {
            uint256 price;
            if (_category == 0 || _category == 1 || _category == 4) {
                price = _priceInWei;
                buyingNfts[_tokenId] = true;
            }
            if (_category == 2 || _category == 3 || _category == 5) {
                token[tokenNumber].quantity = _quantity;
                price = _quantity * _priceInWei;
                buyingItems[_tokenId] += _quantity;
            }
            ERC20lib.transferFrom(ghstContract, msg.sender, address(this), price);
            buyerFunding[msg.sender][tokenNumber] = price;
        }
        if (SettingsInterface(settingsContract).fraactionHubRegistry[msg.sender] != 0) token[tokenNumber].isHub = true;
        if (_inGhst) token[tokenNumber].inGhst = true;
        token[tokenNumber].tokenId = _tokenId;
        token[tokenNumber].active = true;
        token[tokenNumber].author = msg.sender;
        token[tokenNumber].tokenAddress = _tokenAddress;
        token[tokenNumber].category = _category;
        token[tokenNumber].priceInWei = _priceInWei;
        token[tokenNumber].childTokensId = _childTokensId;
        token[tokenNumber].childTokensQuantity = _childTokensQuantity;
        token[tokenNumber].listingEnd = block.timestamp * days * _numberOfDays;
        emit TokenAdded(msg.sender, _forSale, _tokenId, _category, tokenNumber);
    }

    function removeToken(uint256 _tokenNumber) external {
        Token memory params = token[_tokenNumber];
        require(
            msg.sender == params.author,
            "removeToken: not the owner of the listed token"
        );
        if (!params.forSale) {
            ERC20lib.transferFrom(ghstContract, address(this), msg.sender, buyerFunding[msg.sender][_tokenNumber]);
        }
        if (params.category == 0 || params.category == 1 || params.category == 4) {
            if (params.forSale) {
                delete sellingNfts[params.tokenId];
            } else {
                delete buyingNfts[params.tokenId];
            }
        } else if (params.category == 2 || params.category == 3 || params.category == 5) {
            if (params.forSale) {
                sellingItems[params.tokenId] -= params.quantity;
            } else {
                buyingItems[params.tokenId] -= params.quantity;
            }
        }
        delete token[_tokenNumber];
        emit TokenRemoved(msg.sender, _tokenNumber);
    }

    function executeTokenTransaction(uint256 _tokenNumber) external payable nonReentrant {
        Token memory params = token[_tokenNumber];
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
        ERC20lib.transferFrom(ghstContract, buyer, seller, price);
        if (!params.forSale) buyer = params.author;
        if (params.category == 0 || params.category == 1 || params.category == 4) {
            IERC721Upgradeable(params.tokenAddress).safeTransferFrom(seller, buyer, tokenParams.tokenId);
            if (params.forSale) {
                delete sellingNfts[params.tokenId];
            } else {
                delete buyingNfts[params.tokenId];
            }
        } else (params.category == 2 || params.category == 3 || params.category == 5) {
            IERC1155Upgradeable(params.tokenAddress).safeTransferFrom(seller, buyer, params.tokenId, params.quantity);
            if (params.forSale) {
                sellingItems[params.tokenId] -= params.quantity;
            } else {
                buyingItems[params.tokenId] -= params.quantity;
            }
        }
        params.active = false;
        emit ExecutedTransaction(buyer, seller, _saleNumber, price);
    }

    function addFraactionToken(
        address _tokenAddress, 
        uint256 _hubOrGangId, 
        uint256 _value, 
        uint256 _priceInWei, 
        uint256 _numberOfDays,  
        bool _inGhst
    ) external nonReentrant {
        require(
            _hubOrGangId != 0,
            "addFraactionToken: hubOrGangId ID has to be valid"
        );
        require(
            _value > 0,
            "addFraactionToken: quantity has to be superior to zero"
        );
        require(
            _numberOfDays > ISettings(settingsContract).minSaleLength(),
            "addFraactionToken: token ID has to be valid"
        );
        fraactionTokenNumber++;
        if (_forSale) {
            require(IERC20Upgradeable(_tokenAddress).balanceOf(msg.sender) >= _value
                "addFraactionToken: caller not owner of this nft"
            );
            fraactionToken[fraactionTokenNumber].value = _value;
            fraactionToken[fraactionTokenNumber].forSale = true;
        } else {
            uint256 price = _value * _priceInWei;
            if ()
            ERC20lib.transferFrom(ghstContract, msg.sender, address(this), price);
            buyerFunding[msg.sender][fraactionTokenNumber] = price;
        }
        if (SettingsInterface(settingsContract).fraactionHubRegistry[msg.sender] != 0) fraactionToken[fraactionTokenNumber].isHub = true;
        if (_inGhst) fraactionToken[fraactionTokenNumber].inGhst = true;
        fraactionToken[fraactionTokenNumber].hubOrGangId = _hubOrGangId;
        fraactionToken[fraactionTokenNumber].active = true;
        fraactionToken[fraactionTokenNumber].author = msg.sender;
        fraactionToken[fraactionTokenNumber].tokenAddress = _tokenAddress;
        fraactionToken[fraactionTokenNumber].priceInWei = _priceInWei;
        fraactionToken[fraactionTokenNumber].listingEnd = block.timestamp * days * _numberOfDays;
        emit FraactionTokenAdded(msg.sender, _forSale, _tokenId, _category, fraactionTokenNumber);
    }
}



require(
            _erc721TokenAddress == address(this) ||
                erc721Token.isApprovedForAll(owner, address(this)) ||
                erc721Token.getApproved(_erc721TokenId) == address(this),
            "ERC721Marketplace: Not approved for transfer"
        );