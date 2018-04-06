pragma solidity ^0.4.18;

import './MultiOwnable.sol';
import './SafeMath.sol';
import './IERC20Token.sol';
import './PricingStrategy.sol';

contract CrowdSale is MultiOwnable {

    using SafeMath for uint256;

    enum ICOState {
        NotStarted,
        Started,
        Stopped,
        Finished
    } // ICO SALE STATES

    struct Stats { 
        uint256 TotalContrAmount;
        ICOState State;
        uint256 TotalContrCount;
    }

    event Contribution(address contraddress, uint256 ethamount, uint256 tokenamount);
    event PresaleTransferred(address contraddress, uint256 tokenamount);
    event TokenOPSPlatformTransferred(address contraddress, uint256 tokenamount);
    event OVISBookedTokensTransferred(address contraddress, uint256 tokenamount);
    event OVISSaleBooked(uint256 jointToken);
    event OVISReservedTokenChanged(uint256 jointToken);
    event RewardPoolTransferred(address rewardpooladdress, uint256 tokenamount);
    event OPSPoolTransferred(address OPSpooladdress, uint256 tokenamount);
    event SaleStarted();
    event SaleStopped();
    event SaleContinued();
    event SoldOutandSaleStopped();
    event SaleFinished();
    event TokenAddressChanged(address jointaddress, address OPSAddress);
    event StrategyAddressChanged(address strategyaddress);   
    event Funded(address fundaddress, uint256 amount);

    uint256 public constant MIN_ETHER_CONTR = 0.1 ether; // MINIMUM ETHER CONTRIBUTION 
    uint256 public constant MAX_ETHER_CONTR = 100 ether; // MAXIMUM ETHER CONTRIBUTION

    uint256 public constant DECIMALCOUNT = 10**18;
    uint256 public constant JOINT_PER_ETH = 8000; // 1 ETH = 8000 JOINT

    uint256 public constant PRESALE_JOINTTOKENS = 5000000; // PRESALE 500 ETH * 10000 JOINT AMOUNT
    uint256 public constant TOKENOPSPLATFORM_JOINTTOKENS = 25000000; // TOKENOPS PLAFTORM RESERVED AMOUNT
    uint256 public constant MAX_AVAILABLE_JOINTTOKENS = 100000000; // PRESALE JOINT TOKEN SALE AMOUNT
    uint256 public AVAILABLE_JOINTTOKENS = uint256(100000000).mul(DECIMALCOUNT);
     
    uint256 public OVISRESERVED_TOKENS = 25000000; // RESERVED TOKEN AMOUNT FOR OVIS PARTNER SALE
    uint256 public OVISBOOKED_TOKENS = 0;
    uint256 public OVISBOOKED_BONUSTOKENS = 0;

    uint256 public constant SALE_START_TIME = 1523059201; //UTC 2018-04-07 00:00:01

    
    uint256 public ICOSALE_JOINTTOKENS = 0; // ICO CONTRACT TOTAL JOINT SALE AMOUNT
    uint256 public ICOSALE_BONUSJOINTTOKENS = 0; // ICO CONTRACT TOTAL JOINT BONUS AMOUNT
    uint256 public TOTAL_CONTRIBUTOR_COUNT = 0; // ICO SALE TOTAL CONTRIBUTOR COUNT

    ICOState public CurrentState; // ICO SALE STATE

    IERC20Token public JointToken;
    IERC20Token public OPSToken;
    PricingStrategy public PriceStrategy;

    address public FundAddress = 0x25Bc52CBFeB86f6f12EaddF77560b02c4617DC21;
    address public RewardPoolAddress = 0xEb1FAef9068b6B8f46b50245eE877dA5b03D98C9;
    address public OvisAddress = 0x096A5166F75B5B923234841F69374de2F47F9478;
    address public PresaleAddress = 0x3e5EF0eC822B519eb0a41f94b34e90D16ce967E8;
    address public TokenOPSSaleAddress = 0x8686e49E07Bde4F389B0a5728fCe8713DB83602b;
    address public StrategyAddress = 0xe2355faB9239d5ddaA071BDE726ceb2Db876B8E2;
    address public OPSPoolAddress = 0xEA5C0F39e5E3c742fF6e387394e0337e7366a121;

    modifier checkCap() {
        require(msg.value>=MIN_ETHER_CONTR);
        require(msg.value<=MAX_ETHER_CONTR);
        _;
    }

    modifier checkBalance() {
        require(JointToken.balanceOf(address(this))>0);
        require(OPSToken.balanceOf(address(this))>0);
        _;       
    }

    modifier checkTime() {
        require(now>=SALE_START_TIME);
        _;
    }

    modifier checkState() {
        require(CurrentState == ICOState.Started);
        _;
    }

    function CrowdSale() {
        PriceStrategy = PricingStrategy(StrategyAddress);

        CurrentState = ICOState.NotStarted;
        uint256 _soldtokens = PRESALE_JOINTTOKENS.add(TOKENOPSPLATFORM_JOINTTOKENS).add(OVISRESERVED_TOKENS);
        _soldtokens = _soldtokens.mul(DECIMALCOUNT);
        AVAILABLE_JOINTTOKENS = AVAILABLE_JOINTTOKENS.sub(_soldtokens);
    }

    function() payable public checkState checkTime checkBalance checkCap {
        contribute();
    }

    /**
     * @dev calculates token amounts and sends to contributor
     */
    function contribute() private {
        uint256 _jointAmount = 0;
        uint256 _jointBonusAmount = 0;
        uint256 _jointTransferAmount = 0;
        uint256 _bonusRate = 0;
        uint256 _ethAmount = msg.value;

        if (msg.value.mul(JOINT_PER_ETH)>AVAILABLE_JOINTTOKENS) {
            _ethAmount = AVAILABLE_JOINTTOKENS.div(JOINT_PER_ETH);
        } else {
            _ethAmount = msg.value;
        }       

        _bonusRate = PriceStrategy.getRate();
        _jointAmount = (_ethAmount.mul(JOINT_PER_ETH));
        _jointBonusAmount = _ethAmount.mul(JOINT_PER_ETH).mul(_bonusRate).div(100);  
        _jointTransferAmount = _jointAmount.add(_jointBonusAmount);
        
        require(_jointAmount<=AVAILABLE_JOINTTOKENS);

        require(JointToken.transfer(msg.sender, _jointTransferAmount));
        require(OPSToken.transfer(msg.sender, _jointTransferAmount));     

        if (msg.value>_ethAmount) {
            msg.sender.transfer(msg.value.sub(_ethAmount));
            CurrentState = ICOState.Stopped;
            SoldOutandSaleStopped();
        }

        AVAILABLE_JOINTTOKENS = AVAILABLE_JOINTTOKENS.sub(_jointAmount);
        ICOSALE_JOINTTOKENS = ICOSALE_JOINTTOKENS.add(_jointAmount);
        ICOSALE_BONUSJOINTTOKENS = ICOSALE_BONUSJOINTTOKENS.add(_jointBonusAmount);         
        TOTAL_CONTRIBUTOR_COUNT = TOTAL_CONTRIBUTOR_COUNT.add(1);

        Contribution(msg.sender, _ethAmount, _jointTransferAmount);
    }

     /**
     * @dev book OVIS partner sale tokens
     */
    function bookOVISSale(uint256 _rate, uint256 _jointToken) onlyOwner public {              
        OVISBOOKED_TOKENS = OVISBOOKED_TOKENS.add(_jointToken);
        require(OVISBOOKED_TOKENS<=OVISRESERVED_TOKENS.mul(DECIMALCOUNT));
        uint256 _bonus = _jointToken.mul(_rate).div(100);
        OVISBOOKED_BONUSTOKENS = OVISBOOKED_BONUSTOKENS.add(_bonus);
        OVISSaleBooked(_jointToken);
    }

     /**
     * @dev changes OVIS partner sale reserved tokens
     */
    function changeOVISReservedToken(uint256 _jointToken) onlyOwner public {
        if (_jointToken > OVISRESERVED_TOKENS) {
            AVAILABLE_JOINTTOKENS = AVAILABLE_JOINTTOKENS.sub((_jointToken.sub(OVISRESERVED_TOKENS)).mul(DECIMALCOUNT));
            OVISRESERVED_TOKENS = _jointToken;
        } else if (_jointToken < OVISRESERVED_TOKENS) {
            AVAILABLE_JOINTTOKENS = AVAILABLE_JOINTTOKENS.add((OVISRESERVED_TOKENS.sub(_jointToken)).mul(DECIMALCOUNT));
            OVISRESERVED_TOKENS = _jointToken;
        }
        
        OVISReservedTokenChanged(_jointToken);
    }

      /**
     * @dev changes Joint Token and OPS Token contract address
     */
    function changeTokenAddress(address _jointAddress, address _OPSAddress) onlyOwner public {
        JointToken = IERC20Token(_jointAddress);
        OPSToken = IERC20Token(_OPSAddress);
        TokenAddressChanged(_jointAddress, _OPSAddress);
    }

    /**
     * @dev changes Pricing Strategy contract address, which calculates token amounts to give
     */
    function changeStrategyAddress(address _strategyAddress) onlyOwner public {
        PriceStrategy = PricingStrategy(_strategyAddress);
        StrategyAddressChanged(_strategyAddress);
    }

    /**
     * @dev transfers presale token amounts to contributors
     */
    function transferPresaleTokens() private {
        require(JointToken.transfer(PresaleAddress, PRESALE_JOINTTOKENS.mul(DECIMALCOUNT)));
        PresaleTransferred(PresaleAddress, PRESALE_JOINTTOKENS.mul(DECIMALCOUNT));
    }

    /**
     * @dev transfers presale token amounts to contributors
     */
    function transferTokenOPSPlatformTokens() private {
        require(JointToken.transfer(TokenOPSSaleAddress, TOKENOPSPLATFORM_JOINTTOKENS.mul(DECIMALCOUNT)));
        TokenOPSPlatformTransferred(TokenOPSSaleAddress, TOKENOPSPLATFORM_JOINTTOKENS.mul(DECIMALCOUNT));
    }

    /**
     * @dev transfers token amounts to other ICO platforms
     */
    function transferOVISBookedTokens() private {
        uint256 _totalTokens = OVISBOOKED_TOKENS.add(OVISBOOKED_BONUSTOKENS);
        if(_totalTokens>0) {       
            require(JointToken.transfer(OvisAddress, _totalTokens));
            require(OPSToken.transfer(OvisAddress, _totalTokens));
        }
        OVISBookedTokensTransferred(OvisAddress, _totalTokens);
    }

    /**
     * @dev transfers remaining unsold token amount to reward pool
     */
    function transferRewardPool() private {
        uint256 balance = JointToken.balanceOf(address(this));
        if(balance>0) {
            require(JointToken.transfer(RewardPoolAddress, balance));
        }
        RewardPoolTransferred(RewardPoolAddress, balance);
    }

    /**
     * @dev transfers remaining OPS token amount to pool
     */
    function transferOPSPool() private {
        uint256 balance = OPSToken.balanceOf(address(this));
        if(balance>0) {
        require(OPSToken.transfer(OPSPoolAddress, balance));
        }
        OPSPoolTransferred(OPSPoolAddress, balance);
    }


    /**
     * @dev start function to start crowdsale for contribution
     */
    function startSale() onlyOwner public {
        require(CurrentState == ICOState.NotStarted);
        require(JointToken.balanceOf(address(this))>0);
        require(OPSToken.balanceOf(address(this))>0);       
        CurrentState = ICOState.Started;
        transferPresaleTokens();
        transferTokenOPSPlatformTokens();
        SaleStarted();
    }

    /**
     * @dev stop function to stop crowdsale for contribution
     */
    function stopSale() onlyOwner public {
        require(CurrentState == ICOState.Started);
        CurrentState = ICOState.Stopped;
        SaleStopped();
    }

    /**
     * @dev continue function to continue crowdsale for contribution
     */
    function continueSale() onlyOwner public {
        require(CurrentState == ICOState.Stopped);
        CurrentState = ICOState.Started;
        SaleContinued();
    }

    /**
     * @dev finish function to finish crowdsale for contribution
     */
    function finishSale() onlyOwner public {
        if (this.balance>0) {
            FundAddress.transfer(this.balance);
        }
        transferOVISBookedTokens();
        transferRewardPool();    
        transferOPSPool();  
        CurrentState = ICOState.Finished; 
        SaleFinished();
    }

    /**
     * @dev funds contract's balance to fund address
     */
    function getFund(uint256 _amount) onlyOwner public {
        require(_amount<=this.balance);
        FundAddress.transfer(_amount);
        Funded(FundAddress, _amount);
    }

    function getStats() public constant returns(uint256 TotalContrAmount, ICOState State, uint256 TotalContrCount) {
        uint256 totaltoken = 0;
        totaltoken = ICOSALE_JOINTTOKENS.add(PRESALE_JOINTTOKENS.mul(DECIMALCOUNT));
        totaltoken = totaltoken.add(TOKENOPSPLATFORM_JOINTTOKENS.mul(DECIMALCOUNT));
        totaltoken = totaltoken.add(OVISBOOKED_TOKENS);
        return (totaltoken, CurrentState, TOTAL_CONTRIBUTOR_COUNT);
    }

    function destruct() onlyOwner public {
        require(CurrentState == ICOState.Finished);
        selfdestruct(FundAddress);
    }
}