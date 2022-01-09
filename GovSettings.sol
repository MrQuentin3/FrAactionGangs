//SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

/**
 * @title FrAactionSPDAO
 * @author Quentin for FrAaction Gangs
 */
 
import {
    IERC721
} from "@OpenZeppelin/contracts/token/ERC721/IERC721.sol";
import {
    Ownable
} from "@OpenZeppelin/contracts/access/Ownable.sol";
import {
    AggregatorV3Interface
} from "./interfaces/IChainLink.sol";

contract Settings is Ownable, ISettings {

    // the initial auctionLength
    uint256 public auctionLength;
    
    // the maximum auction length
    uint256 public maxAuctionLength;

    // the longest an auction can ever be
    uint256 public constant maxMaxAuctionLength = 8 weeks;
    
    // the longest an initial funding round can ever be
    uint256 public constant maxMaxNumberDaysFunding = 8 weeks;
    
    // the longest an new funding round can ever be
    uint256 public constant maxMaxNumberDaysNewFunding = 8 weeks;
    
    // the longest an Aavegotchi funding round can ever be
    uint256 public constant maxMaxNumberDaysAavegotchiFunding = 8 weeks;

    // the minimum auction length
    uint256 public minAuctionLength;

    // the shortest an auction can ever be
    uint256 public constant minMinAuctionLength = 1 days;
    
    // the shortest an initial funding round can ever be
    uint256 public constant minMinNumberDaysFunding = 1 days;
    
    // the shortest a new funding round can ever be
    uint256 public constant minMinNumberDaysNewFunding = 1 days;
    
    // the shortest an Aavegotchi funding round can ever be
    uint256 public constant minMinNumberDaysAavegotchiFunding = 1 days;

    // governance fee max
    uint256 public governanceFee;

    // 10% fee is max
    uint256 public constant maxGovFee = 100;

    // max player fee
    uint256 public maxPlayerFee;

    // the % bid increase required for a new bid
    uint256 public minBidIncrease;

    // 10% bid increase is max
    uint256 public constant maxMinBidIncrease = 100;

    // 1% bid increase is min
    uint256 public constant minMinBidIncrease = 10;

    // the % of tokens required to be voting for an auction to start
    uint256 public minVotePercentage;

    // the % of tokens required to appoint the Player
    uint256 public minPlayerVotePercentage;

    // the max % increase over the initial
    uint256 public maxReserveFactor;

    // the max % decrease from the initial
    uint256 public minReserveFactor;

    // maximum deadline for funding round
    uint256 public maxNumberDaysFunding;
    
    // minimum deadline for funding round
    uint256 public minNumberDaysFunding;
    
    // maximum deadline for Aavegotchi funding round
    uint256 public maxNumberDaysAavegotchiFunding;
    
    // minimum deadline for Aavegotchi funding round
    uint256 public minNumberDaysAavegotchiFunding;

    // FrAactionDAO fee on funding rounds
    uint256 public fundingFee;
    
    // FrAactionDAO fee on funding rounds
    uint256 public playerFee;
    
    // the % of tokens required to change the auction length
    uint256 public minLengthVotePercentage;
    
    // the % of tokens required to change the Player's fee percentage
    uint256 public minPlayerFeeVotePercentage;
    
    // the % of tokens required to change the FrAactionHub type
    uint256 public minTypeVotePercentage;
    
    // the % of tokens required to appoint the Aavegotchi
    uint256 public minAavegotchiVotePercentage;
    
    // the % of tokens required to open a portal
    uint256 public minOpenVotePercentage;
    
    // the % of tokens required to destroy an Aavegotchi
    uint256 public minDestroyVotePercentage;
    
    // the % of tokens required to name an Aavegotchi
    uint256 public minNameVotePercentage;
    
    // FrAactionHub index 
    uint256 public hubId;
    
    // maximum length of the Nft array for each demerge() or merge() iteration
    uint256 public maxNftsArrayLength;
    
    // maximum length of the ownerAddress array for each demerge() or merge() iteration
    uint256 public maxOwnersArrayLength;
    
    // number of times necessary for a contributor to get compensated for paying the gas fees for all the FrAactionHub owners
    uint256 public feesRewardTrigger;
    
    // tokens to be minted as a reward for paying the gas fees
    uint256 public feesReward;

    // the address who receives auction fees
    address public feeReceiver;
    
    // the address of the FrAactionFactory contract
    address public fraactionFactoryContract;
    
    // maDAI collateral address
    address public maDaiCollateral;
    
    // maWETH collateral address
    address public maWethCollateral;
    
    // maAave collateral address
    address public maAaveCollateral;
    
    // maLINK collateral address
    address public maLinkCollateral;
    
    // maLINK collateral address
    address public maLinkCollateral;
    
    // maUSDT collateral address
    address public maUsdtCollateral;
    
    // maUSDC collateral address
    address public maUsdcCollateral;
    
    // maTUSD collateral address
    address public maTusdCollateral;
    
    // maUNI collateral address
    address public maUniCollateral;
    
    // maYFI collateral address
    address public maYfiCollateral;
    
    // amDAI collateral address
    address public amDaiCollateral;
    
    // amWETH collateral address
    address public amWethCollateral;
    
    // amAave collateral address
    address public amAaveCollateral;
    
    // amUSDT collateral address
    address public amUsdtCollateral;
    
    // amUSDC collateral address
    address public amUsdcCollateral;
    
    // amWBTC collateral address
    address public amWbtcCollateral;
    
    // amWMATIC collateral address
    address public amWmaticCollateral;
    
    // DAI oracle address
    address public daiOracle;
    
    // WETH oracle address
    address public wethOracle;
    
    // AAVE oracle address
    address public aaveOracle;
    
    // LINK oracle address
    address public linkOracle;
    
    // USDT oracle address
    address public usdtOracle;
    
    // USDC oracle address
    address public usdcOracle;
    
    // TUSD oracle address
    address public tusdOracle;
    
    // UNI oracle address
    address public uniOracle;
    
    // YFI oracle address
    address public yfiOracle;
    
    // WBTC oracle address
    address public wbtcOracle;
    
    // MATIC oracle address
    address public maticOracle;
    
    // FrAactionHub address => FrAactionHub ID
    mapping(address => uint256) public fraactionHubRegistry;
    
    // FrAactionHub ID => FrAactionHub address
    mapping(uint256 => address) public idToAddress;
    
    // FrAactionHub address => FrAactionHub time of deploy
    mapping(address => uint256) public timeDeployed;

    event UpdateMaxAuctionLength(uint256 _old, uint256 _new);

    event UpdateMinAuctionLength(uint256 _old, uint256 _new);

    event UpdateGovernanceFee(uint256 _old, uint256 _new);

    event UpdatePlayerFee(uint256 _old, uint256 _new);
    
    event UpdateMaxPlayerFee(uint256 _old, uint256 _new);

    event UpdateMinBidIncrease(uint256 _old, uint256 _new);

    event UpdateMinVotePercentage(uint256 _old, uint256 _new);

    event UpdateMaxReserveFactor(uint256 _old, uint256 _new);

    event UpdateMinReserveFactor(uint256 _old, uint256 _new);

    event UpdateFeeReceiver(address _old, address _new);

    event UpdateFundingFee(uint256 _old, uint256 _new);

    event UpdateMaxNumberDaysFunding(uint256 _old, uint256 _new);
    
    event UpdateMinNumberDaysFunding(uint256 _old, uint256 _new);
    
    event UpdateMinTypeVotePercentage(uint256 _old, uint256 _new);
    
    event UpdateMinPlayerFeeVotePercentage(uint256 _old, uint256 _new);
    
    event UpdateMinLengthVotePercentage(uint256 _old, uint256 _new);
    
    event UpdateMinOpenVotePercentage(uint256 _old, uint256 _new);

    event UpdateNumberMaxDaysAavegotchiFunding(uint256 _old, uint256 _new);
    
    event UpdateNumberMinDaysAavegotchiFunding(uint256 _old, uint256 _new);
    
    event UpdateMinDestroyVotePercentage(uint256 _old, uint256 _new);
    
    event UpdateMinNameVotePercentage(uint256 _old, uint256 _new);
    
    event UpdateFraactionFactory(address _old, address _new);
    
    event UpdateMaxNftsLength(address _old, address _new);
    
    event UpdateMaxOwnersLength(address _old, address _new);

    event UpdateFraactionFactoryContract(address _old, address _new);
    
    event NewRegisteredFraactionHub(address _newFraactionHub);
    
    constructor() {
        fraactionFactoryContract = ;
        maxAuctionLength = 2 weeks;
        minAuctionLength = 3 days;
        auctionLength = 1 weeks;
        feeReceiver = msg.sender;
        minReserveFactor = 200;  // 20%
        maxReserveFactor = 5000; // 500%
        minBidIncrease = 50;     // 5%
        maxPlayerFee = 100;     // 10%
        minVotePercentage = 250; // 25%
        minPlayerVotePercentage = 510; // 51%
        fundingFee = 50; // 5%
        playerFee = 30; // 3%
        maxNumberDaysFunding = 7;
        minNumberDaysFunding = 1;
        maxNumberDaysAavegotchiFunding = 5;
        minNumberDaysAavegotchiFunding = 1;
        minTypeVotePercentage = 800; // 80%
        minPlayerFeeVotePercentage = 510; // 51%
        minLengthVotePercentage = 510; // 51%
        minAavegotchiVotePercentage = 510; // 51%
        minOpenVotePercentage = 510; // 51%
        minDestroyVotePercentage = 800; // 80%
        minNameVotePercentage = 300; // 30%
        maxNftsArrayLength = 100; 
        maxOwnersArrayLength = 200; 
        feesRewardTrigger = 2; 
        feesReward = 60;
        maDaiCollateral = 0xE0b22E0037B130A9F56bBb537684E6fA18192341;
        maWethCollateral = 0x20D3922b4a1A8560E1aC99FBA4faDe0c849e2142;
        maAaveCollateral = 0x823CD4264C1b951C9209aD0DeAea9988fE8429bF;
        maLinkCollateral = 0x98ea609569bD25119707451eF982b90E3eb719cD;
        maUsdtCollateral = 0xDAE5F1590db13E3B40423B5b5c5fbf175515910b;
        maUsdcCollateral = 0x9719d867A500Ef117cC201206B8ab51e794d3F82;
        maTusdCollateral = 0xF4b8888427b00d7caf21654408B7CBA2eCf4EbD9;
        maUniCollateral = 0x8c8bdBe9CeE455732525086264a4Bf9Cf821C498;
        maYfiCollateral = 0xe20f7d1f0eC39C4d5DB01f53554F2EF54c71f613;
        amDaiCollateral = 0x27F8D03b3a2196956ED754baDc28D73be8830A6e;
        amWethCollateral = 0x28424507fefb6f7f8E9D3860F56504E4e5f5f390;
        amAaveCollateral = 0x1d2a0E5EC8E5bBDCA5CB219e649B565d8e5c3360;
        amUsdtCollateral = 0x60D55F02A771d515e077c9C2403a1ef324885CeC;
        amUsdcCollateral = 0x1a13F4Ca1d028320A707D99520AbFefca3998b7F;
        amWbtcCollateral = 0x5c2ed810328349100A66B82b78a1791B101C9D61;
        amWmaticCollateral = 0x8dF3aad3a84da6b69A4DA8aeC3eA40d9091B2Ac4;
        // Below oracles are expressing tokens in USD with 8 decimals except for GHST only expressed in ETH (18 decimals) by the ChainLink oracle
        daiOracle = 0x4746DeC9e833A82EC7C2C1356372CcF2cfcD2F3D;
        wethOracle = 0xF9680D99D6C9589e2a93a78A04A279e509205945;
        aaveOracle = 0x72484B12719E23115761D5DA1646945632979bB6;
        linkOracle = 0xd9FFdb71EbE7496cC440152d43986Aae0AB76665;
        usdtOracle = 0x0A6513e40db6EB1b165753AD52E80663aeA50545;
        usdcOracle = 0xfE4A8cc5b5B2366C1B58Bea3858e81843581b2F7;
        tusdOracle = 0x7C5D415B64312D38c56B54358449d0a4058339d2;
        uniOracle = 0xdf0Fb4e4F928d2dCB76f438575fDD8682386e13C;
        yfiOracle = 0x9d3A43c111E7b2C6601705D9fcF7a70c95b1dc55;
        wbtcOracle = 0xDE31F8bFBD8c84b5360CFACCa3539B938dd78ae6;
        maticOracle = 0xAB594600376Ec9fD91F8e885dADF0CE036862dE0;
        ghstOracle = 0xDD229Ce42f11D8Ee7fFf29bDB71C7b81352e11be;
    }
    
    // ============ external functions : FrAactionHub registry ============
    
    function registerNewFrAactionHub(address _fraactionHubAddress) external {
        require(
            msg.sender == fraactionFactoryAddress ||
            msg.sender == _owner,
            "registerNewFrAactionHub: the caller is not the FrAactionFactory contract"
        );
        hubId++;
        fraactionHubRegistry[_fraactionHubAddress] = hubId;
        idToAddress[hubId] = _fraactionHubAddress;
        timeDeployed[_fraactionHubAddress] = block.timestamp;
        emit NewRegisteredFraactionHub(_fraactionHubAddress);
    }
    
    // ============ Admin external functions : updating settings ============
    
    function setFraactionFactory(address _fraactionFactoryAddress) external onlyOwner {
        emit UpdateFraactionFactory(fraactionFactoryAddress, _fraactionFactoryAddress);
        fraactionFactoryAddress = _fraactionFactoryAddress;
    }
    
    function setMaxAuctionLength(uint256 _length) external onlyOwner {
        require(_length <= maxMaxAuctionLength, "max auction length too high");
        require(_length > minAuctionLength, "max auction length too low");
        emit UpdateMaxAuctionLength(maxAuctionLength, _length);
        maxAuctionLength = _length;
    }

    function setMinAuctionLength(uint256 _length) external onlyOwner {
        require(_length >= minMinAuctionLength, "min auction length too low");
        require(_length < maxAuctionLength, "min auction length too high");
        emit UpdateMinAuctionLength(minAuctionLength, _length);
        minAuctionLength = _length;
    }

    function setGovernanceFee(uint256 _fee) external onlyOwner {
        require(_fee <= maxGovFee, "fee too high");
        emit UpdateGovernanceFee(governanceFee, _fee);
        governanceFee = _fee;
    }
    
    function setPlayerFee(uint256 _fee) external onlyOwner {
        emit UpdatePlayerFee(playerFee, _fee);
        playerFee = _fee;
    }

    function setMaxPlayerFee(uint256 _fee) external onlyOwner {
        emit UpdateMaxPlayerFee(maxPlayerFee, _fee);
        maxPlayerFee = _fee;
    }

    function setMinBidIncrease(uint256 _min) external onlyOwner {
        require(_min <= maxMinBidIncrease, "min bid increase too high");
        require(_min >= minMinBidIncrease, "min bid increase too low");
        emit UpdateMinBidIncrease(minBidIncrease, _min);
        minBidIncrease = _min;
    }

    function setMinVotePercentage(uint256 _min) external onlyOwner {
        require(_min <= 100, "min vote percentage too high");
        emit UpdateMinVotePercentage(minVotePercentage, _min);
        minVotePercentage = _min;
    }

    function setMinPlayerVotePercentage(uint256 _min) external onlyOwner {
        require(_min <= 100, "min vote percentage too high");
        emit UpdateMinVotePercentage(minVotePercentage, _min);
        minVotePercentage = _min;
    }

    function setMaxReserveFactor(uint256 _factor) external onlyOwner {
        require(_factor > minReserveFactor, "max reserve factor too low");
        emit UpdateMaxReserveFactor(maxReserveFactor, _factor);
        maxReserveFactor = _factor;
    }

    function setMinReserveFactor(uint256 _factor) external onlyOwner {
        require(_factor < maxReserveFactor, "min reserve factor too high");
        emit UpdateMinReserveFactor(minReserveFactor, _factor);
        minReserveFactor = _factor;
    }

    function setFeeReceiver(address _receiver) external onlyOwner {
        require(_receiver != address(0), "fees cannot go to 0 address");
        emit UpdateFeeReceiver(feeReceiver, _receiver);
        feeReceiver = _receiver;
    }

    function setFundingFee(uint256 _fundingFee) external onlyOwner {
        require(_fundingFee <= maxGovFee, "fee too high");
        emit UpdateFundingFee(fundingFee, _fundingFee);
        fundingFee = _fundingFee;
    }

    function setMaxNumberDaysFunding(uint256 _maxNumberDaysFunding) external onlyOwner {
        require(_maxNumberDaysFunding <= maxMaxNumberDaysFunding, "number of days too high");
        require(_maxNumberDaysFunding > minNumberDaysFunding, "number of days too low");
        emit UpdateMaxNumberDaysFunding(maxNumberDaysFunding, _maxNumberDaysFunding);
        maxNumberDaysFunding = _numberDaysFunding;
    }
    
    function setMinNumberDaysFunding(uint256 _minNumberDaysFunding) external onlyOwner {
        require(_minNmberDaysFunding >= minMinNumberDaysFunding, "number of days too low");
        require(_minNumberDaysFunding < maxNumberDaysfunding, "number of days too high");
        emit UpdateNumberMinDaysFunding(minNumberDaysFunding, _minNumberDaysFunding);
        minNumberDaysFunding = _minNumberDaysFunding;
    }
    
    function setMaxNumberDaysAavegotchiFunding(uint256 _maxNumberDaysAavegotchiFunding) external onlyOwner {
        require(_maxNumberDaysAavegotchiFunding <= maxMaxNumberDaysAavegotchiFunding, "number of days too high");
        require(_maxNumberDaysAavegotchiFunding > minNumberDaysAavegotchiFunding, "number of days too low");
        emit UpdateNumberMaxDaysAavegotchiFunding(maxNumberDaysAavegotchiFunding, _maxNumberDaysAavegotchiFunding);
        maxNumberDaysAavegotchiFunding = _maxNumberDaysAavegotchiFunding;
    }
    
    function setMinNumberDaysAavegotchiFunding(uint256 _minNumberDaysAavegotchiFunding) external onlyOwner {
        require(_minNmberDaysAavegotchiFunding >= minMinNumberDaysAavegotchiFunding, "number of days too low");
        require(_minNumberDaysAavegotchiFunding < maxNumberDaysAavegotchifunding, "number of days too high");
        emit UpdateNumberMinDaysAavegotchiFunding(minNumberDaysAavegotchiFunding, _minNumberDaysAavegotchiFunding);
        minNumberDaysAavegotchiFunding = _minNumberDaysAavegotchiFunding;
    }
    
    function setMinTypeVotePercentage(uint256 _minTypeVotePercentage) external onlyOwner {
        require(_minTypeVotePercentage <= 100, "min vote percentage too high");
        emit UpdateMinTypeVotePercentage(minTypeVotePercentage, _minTypeVotePercentage);
        minTypeVotePercentage = _minTypeVotePercentage;
    }
    
    function setMinPlayerFeeVotePercentage(uint256 _minPlayerFeeVotePercentage) external onlyOwner {
        require(_minPlayerFeeVotePercentage) <= 100, "min vote percentage too high");
        emit UpdateMinPlayerFeeVotePercentage(minPlayerFeeVotePercentage, _minPlayerFeeVotePercentage);
        minPlayerFeeVotePercentage = _minPlayerFeeVotePercentage;
    }
    
    function setMinLengthVotePercentage(uint256 _minLengthVotePercentage) external onlyOwner {
        require(_minLengthVotePercentage) <= 100, "min vote percentage too high");
        emit UpdateMinLengthVotePercentage(minLengthVotePercentage, _minLengthVotePercentage);
        minLengthVotePercentage = _minLengthVotePercentage;
    }
    
    function setMinAavegotchiVotePercentage(uint256 _minAavegotchiVotePercentage) external onlyOwner {
        require(_minAavegotchiVotePercentage) <= 100, "min vote percentage too high");
        emit UpdateMinAavegotchiVotePercentage(minAavegotchiVotePercentage, _minAavegotchiVotePercentage);
        minAavegotchiVotePercentage = _minAavegotchiVotePercentage;
    }
    
    function setMinOpenVotePercentage(uint256 _minOpenVotePercentage) external onlyOwner {
        require(_minOpenVotePercentage) <= 100, "min vote percentage too high");
        emit UpdateMinOpenVotePercentage(minOpenVotePercentage, _minOpenVotePercentage);
        minOpenVotePercentage = _minOpenVotePercentage;
    }
    
    function setMinDestroyVotePercentage(uint256 _minOpenVotePercentage) external onlyOwner {
        require(_minDestroyVotePercentage) <= 100, "min vote percentage too high");
        emit UpdateMinDestroyVotePercentage(minDestroyVotePercentage, _minDestroyVotePercentage);
        minDestroyVotePercentage = _minDestroyVotePercentage;
    }
    
    function setMinNameVotePercentage(uint256 _minNameVotePercentage) external onlyOwner {
        require(_minNameVotePercentage) <= 100, "min vote percentage too high");
        emit UpdateMinNameVotePercentage(minNameVotePercentage, _minNameVotePercentage);
        minNameVotePercentage = _minNameVotePercentage;
    }
    
    function setMaxNftsArrayLength(uint256 _maxNftsArrayLength) external onlyOwner {
        emit UpdateMaxNftsArrayLength(maxNftsArrayLength, _maxNftsArrayLength);
        maxNftsArrayLength = _maxNftsArrayLength;
    }
    
    function setMaxOwnersArrayLength(uint256 _maxOwnersArrayLength) external onlyOwner {
        emit UpdateMaxOwnersArrayLength(maxOwnersArrayLength, _maxOwnersArrayLength);
        maxOwnersArrayLength = _maxOwnersArrayLength;
    }

    function setFraactionFactoryContract(address _fraactionFactoryContract) external onlyOwner {
        emit UpdateFraactionFactoryContract(fraactionFactoryContract, _fraactionFactoryContract);
        fraactionFactoryContract = _fraactionFactoryContract;
    }
    
    function feesRewardTrigger(uint256 _feesRewardTrigger) external onlyOwner {
        emit UpdateFeesRewardTrigger(feesRewardTrigger, _feesRewardTrigger);
        feesRewardTrigger = _feesRewardTrigger;
    }
    
    function feesReward(uint256 _feesReward) external onlyOwner {
        emit UpdateFeesReward(feesReward, _feesReward);
        feesReward = _feesReward;
    }
    
    // ============ internal functions : ChainLink oracle function ===========
    
     /**
     * @notice query a ChainLink oracle to fetch the current market price of a collateral type (ERC20 token)
     * @return price the current market price of the collateral type
     */
    
    function getLatestPrice(address _oracleAddress) internal view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = AggregatorV3Interface(_oracleAddress).latestRoundData();
        return price;
    }
    
    // ============ external functions : converting maTokens into GHST with oracle price feeds ============
    
     /**
     * @notice convert a collateral type value into GHST in order the calculate the contributor's share in GHST during a funding round 
     * or a colletaral stake increase
     * @return ghstRate_ the exchange rate expressing the value of a given collateral type in GHST at the current market price 
     */
     
    function collateralTypeToGhst(address _collateralType) external returns (uint256 ghstRate_) {
        uint256 ghstPriceInUsd = getLatestPrice(ghstOracle);
        uint256 usdPriceInGhst = (1 / (ghstPriceInUsd / 10**8)) * 10**8;
        if (_collateralType = maDaiCollateral) {
            uint256 maDaiPriceInUsd = getLatestPrice(daiOracle);
            uint256 usdPriceInMaDai = (1 / (maDaiPriceInUsd / 10**8)) * 10**8;
            ghstRate_ = (usdPriceInGhst / (usdPriceInMaDai)) * 10**8;
        } else if (_collateralType = maWethCollateral) {
            uint256 maWethPriceInUsd = getLatestPrice(wethOracle);
            uint256 usdPriceInMaWeth = (1 / (maWethPriceInUsd / 10**8)) * 10**8;
            ghstRate_ = (usdPriceInGhst / (usdPriceInMaWeth)) * 10**8;
        } else if (_collateralType = maAaveCollateral) {
            uint256 maAavePriceInUsd = getLatestPrice(aaveOracle);
            uint256 usdPriceInMaAave = (1 / (maAavePriceInUsd / 10**8)) * 10**8;
            ghstRate_ = (usdPriceInGhst / (usdPriceInMaAave)) * 10**8;
        } else if (_collateralType = maLinkCollateral) {
            uint256 maLinkPriceInUsd = getLatestPrice(linkOracle);
            uint256 usdPriceInMaLink = (1 / (maLinkPriceInUsd / 10**8)) * 10**8;
            ghstRate_ = (usdPriceInGhst / (usdPriceInMaLink)) * 10**8;
        } else if (_collateralType = maUsdtCollateral) {
            uint256 maUsdtPriceInUsd = getLatestPrice(usdtOracle);
            uint256 usdPriceInMaUsdt = (1 / (maUsdtPriceInUsd / 10**8)) * 10**8;
            ghstRate_ = (usdPriceInGhst / (usdPriceInMaUsdt)) * 10**8;
        } else if (_collateralType = maUsdcCollateral) {
            uint256 maUsdcPriceInUsd = getLatestPrice(usdcOracle);
            uint256 usdPriceInMaUsdc = (1 / (maUsdcPriceInUsd / 10**8)) * 10**8;
            ghstRate_ = (usdPriceInGhst / (usdPriceInMaUsdc)) * 10**8;
        } else if (_collateralType = maTusdCollateral) {
            uint256 maTusdPriceInUsd = getLatestPrice(tusdOracle);
            uint256 usdPriceInMaTusd = (1 / (maTusdPriceInUsd / 10**8)) * 10**8;
            ghstRate_ = (usdPriceInGhst / (usdPriceInMaTusd)) * 10**8;
        } else if (_collateralType = maUniCollateral) {
            uint256 maUniPriceInUsd = getLatestPrice(uniOracle);
            uint256 usdPriceInMaUni = (1 / (maUniPriceInUsd / 10**8)) * 10**8;
            ghstRate_ = (usdPriceInGhst / (usdPriceInMaUni)) * 10**8;
        } else if (_collateralType = maYfiCollateral) {
            uint256 maYfiPriceInUsd = getLatestPrice(yfiOracle);
            uint256 usdPriceInMaYfi = (1 / (maYfiPriceInUsd / 10**8)) * 10**8;
            ghstRate_ = (usdPriceInGhst / (usdPriceInMaYfi)) * 10**8;
        } else if (_collateralType = amDaiCollateral) {
            uint256 amDaiPriceInUsd = getLatestPrice(daiOracle);
            uint256 usdPriceInAmDai = (1 / (amDaiPriceInUsd / 10**8)) * 10**8;
            ghstRate_ = (usdPriceInGhst / (usdPriceInAmDai)) * 10**8;
        } else if (_collateralType = amWethCollateral) {
            uint256 amWethPriceInUsd = getLatestPrice(wethOracle);
            uint256 usdPriceInAmWeth = (1 / (amWethPriceInUsd / 10**8)) * 10**8;
            ghstRate_ = (usdPriceInGhst / (usdPriceInAmWeth)) * 10**8;
        } else if (_collateralType = amAaveCollateral) {
            uint256 amAavePriceInUsd = getLatestPrice(aaveOracle);
            uint256 usdPriceInAmAave = (1 / (amAavePriceInUsd / 10**8)) * 10**8;
            ghstRate_ = (usdPriceInGhst / (usdPriceInAmAave)) * 10**8;
        } else if (_collateralType = amUsdtCollateral) {
            uint256 amUsdtPriceInUsd = getLatestPrice(usdtOracle);
            uint256 usdPriceInAmUsdt = (1 / (amUsdtPriceInUsd / 10**8)) * 10**8;
            ghstRate_ = (usdPriceInGhst / (usdPriceInAmUsdt)) * 10**8;
        } else if (_collateralType = amUsdcCollateral) {
            uint256 amUsdcPriceInUsd = getLatestPrice(usdcOracle);
            uint256 usdPriceInAmUsdc = (1 / (amUsdcPriceInUsd / 10**8)) * 10**8;
            ghstRate_ = (usdPriceInGhst / (usdPriceInAmUsdc)) * 10**8;
        } else if (_collateralType = amWbtcCollateral) {
            uint256 amWbtcPriceInUsd = getLatestPrice(wbtcOracle);
            uint256 usdPriceInAmWbtc = (1 / (amWbtcPriceInUsd / 10**8)) * 10**8;
            ghstRate_ = (usdPriceInGhst / (usdPriceInAmWbtc)) * 10**8;
        } else if (_collateralType = amWmaticCollateral) {
            uint256 amWmaticPriceInUsd = getLatestPrice(maticOracle);
            uint256 usdPriceInAmWmatic = (1 / (amWmaticPriceInUsd / 10**8)) * 10**8;
            ghstRate_ = (usdPriceInGhst / (usdPriceInAmWmatic)) * 10**8;
        }
    }
}