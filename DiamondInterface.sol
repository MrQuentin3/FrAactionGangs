// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

/**
 * @title Diamond Interface
 * @author Quentin for FrAaction Gangs
 */

interface DiamondInterface {

  // Struct from the Aavegotchi LibAavegotchi library
    struct AavegotchiInfo {
        uint256 tokenId;
        string name;
        address owner;
        uint256 randomNumber;
        uint256 status;
        int16[6] numericTraits;
        int16[6] modifiedNumericTraits;
        uint16[16] equippedWearables;
        address collateral;
        address escrow;
        uint256 stakedAmount;
        uint256 minimumStake;
        uint256 kinship; //The kinship value of this Aavegotchi. Default is 50.
        uint256 lastInteracted;
        uint256 experience; //How much XP this Aavegotchi has accrued. Begins at 0.
        uint256 toNextLevel;
        uint256 usedSkillPoints; //number of skill points used
        uint256 level; //the current aavegotchi level
        uint256 hauntId;
        uint256 baseRarityScore;
        uint256 modifiedRarityScore;
        bool locked;
        ItemTypeIO[] items;
    }   
    
    struct PortalAavegotchiTraitsIO {
        uint256 randomNumber;
        int16[6] numericTraits;
        address collateralType;
        uint256 minimumStake;
    }
    
    // Structs from the Aavegotchi LibAppStorage library
    struct ERC721Listing {
        uint256 listingId;
        address seller;
        address erc721TokenAddress;
        uint256 erc721TokenId;
        uint256 category; // 0 is closed portal, 1 is vrf pending, 2 is open portal, 3 is Aavegotchi
        uint256 priceInWei;
        uint256 timeCreated;
        uint256 timePurchased;
        bool cancelled;
    }
    
    struct ERC1155Listing {
        uint256 listingId;
        address seller;
        address erc1155TokenAddress;
        uint256 erc1155TypeId;
        uint256 category; // 0 is wearable, 1 is badge, 2 is consumable, 3 is tickets
        uint256 quantity;
        uint256 priceInWei;
        uint256 timeCreated;
        uint256 timeLastPurchased;
        uint256 sourceListingId;
        bool sold;
        bool cancelled;
    }
    
    // Struct from the Aavegotchi itemsFacet contract
    struct ItemIdIO {
        uint256 itemId;
        uint256 balance;
    }
    
    // function signatures from the Aavegotchi ERC1155MarketplaceFacet contract
    function getERC1155Listing(uint256 _listingId) external view returns (ERC1155Listing memory listing_);
    // function signatures from Aavegotchi ERC721MarketplaceFacet contract
    function getERC721Listing(uint256 _listingId) external view returns (ERC721Listing memory listing_);
    function getERC721Category(address _erc721TokenAddress, uint256 _erc721TokenId) public view returns (uint256 category_);
    // function signatures from AavegotchiFacet contract
    function getAavegotchi(uint256 _tokenId) external view returns (AavegotchiInfo memory aavegotchiInfo_);
    function setApprovalForAll(address _operator, bool _approved) external;
    function tokenIdsOfOwner(address _owner) external view returns (uint32[] memory tokenIds_);
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external {
        address sender = LibMeta.msgSender();
        internalTransferFrom(sender, _from, _to, _tokenId);
        LibERC721.checkOnERC721Received(sender, _from, _to, _tokenId, "");
    };
    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] calldata _tokenIds,
        bytes calldata _data
    ) external;
    // function signatures from Aavegotchi itemsFacet contract
    function balanceOfToken(
        address _tokenContract,
        uint256 _tokenId,
        uint256 _id
    ) external view returns (uint256 value);
    function balanceOf(address _owner, uint256 _id) external view returns (uint256 bal_);
    function itemBalances(address _account) external view returns (ItemIdIO[] memory bals_);
    function equipWearables(uint256 _tokenId, uint16[16] calldata _wearablesToEquip) external;
    function useConsumables(
        uint256 _tokenId,
        uint256[] calldata _itemIds,
        uint256[] calldata _quantities
    ) external;
    // function signatures from Aavegotchi itemsTransferFacet contract
    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external;
    // function signature from Aavegotchi GHSTFacet contract
    function approve(address _spender, uint256 _value) public returns (bool success);
    // function signature from Aavegotchi VRFFacet contract
    function openPortals(uint256[] calldata _tokenIds) external;
    // function signatures from Aavegotchi AavegotchiGameFacet contract
    function portalAavegotchiTraits(uint256 _tokenId) external view returns (PortalAavegotchiTraitsIO[10] memory portalAavegotchiTraits_);
    function setAavegotchiName(uint256 _tokenId, string calldata _name) external;
    function aavegotchiNameAvailable(string calldata _name) external view returns (bool available_);
    function claimAavegotchi(
        uint256 _tokenId,
        uint256 _option,
        uint256 _stakeAmount
    ) external;
    function spendSkillPoints(uint256 _tokenId, int16[4] calldata _values) external;
    function availableSkillPoints(uint256 _tokenId) public view returns (uint256);
    function interact(uint256[] calldata _tokenIds) external;
    // function signatures from Aavegotchi CollateralFacet contract
    function collateralBalance(uint256 _tokenId) external view returns (
        address collateralType_,
        address escrow_,
        uint256 balance_
    );
    // function signature from Aavegotchi EscrowFacet contract
    function escrowBalance(uint256 _tokenId, address _erc20Contract) external view returns (uint256);
    // function signature from Aavegotchi GHST Staking contract
    function balanceOfAll(address _owner) external view returns (uint256[] memory balances_);
        
}