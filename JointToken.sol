pragma solidity ^0.4.18;

import './ERC20Token.sol';


contract JointToken is ERC20Token {

    uint256 public constant RewardPoolAmount = 500000000;
    uint256 public constant ICOInvestorsAmount = 100000000;
    uint256 public constant EarlyAdoptersAmount = 5000000;
    uint256 public constant LaunchPartnersAmount = 5000000;
    uint256 public constant TeamMembersAmount = 5000000;
    uint256 public constant MarketingDevelopmentAmount = 1000000;

    uint256 public constant EstimatedICOBonusAmount = 14000000;

    address public constant RewardPoolAddress = 0xEb1FAef9068b6B8f46b50245eE877dA5b03D98C9;
    address public constant ICOAddress = 0x29eC21157f19F7822432e87ef504D366c24E1D8B;
    address public constant EarlyAdoptersAddress = 0x5DD184EC1fB992c158EA15936e57A20C70761f84;
    address public constant LaunchPartnersAddress = 0x4A1943b2aB647a5150ECEc16D6Bf695f10D94E0E;
    address public constant TeamMembersAddress = 0x5a5b2715121e762B43D9A657E10AE93A5629Fe28;
    address public constant MarketingDevelopmentAddress = 0x5E1D0513Bc39fBD6ECd94447e627919Bbf575eC0;
    
    uint256 public  decimalPlace;


    function JointToken() public {
        name = "JOINT";
        symbol = "JOINT";
        decimals = 18;

        decimalPlace = 10**uint256(decimals);
        totalSupply = 616000000*decimalPlace;
        distributeTokens();
    }

    function distributeTokens () private {
        balances[RewardPoolAddress] = (RewardPoolAmount.sub(EstimatedICOBonusAmount)).mul(decimalPlace);
        balances[ICOAddress] = (ICOInvestorsAmount.add(EstimatedICOBonusAmount)).mul(decimalPlace);
        balances[EarlyAdoptersAddress] = EarlyAdoptersAmount.mul(decimalPlace);
        balances[LaunchPartnersAddress] = LaunchPartnersAmount.mul(decimalPlace);
        balances[TeamMembersAddress] = TeamMembersAmount.mul(decimalPlace);
        balances[MarketingDevelopmentAddress] = MarketingDevelopmentAmount.mul(decimalPlace);
    }

}