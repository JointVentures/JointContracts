pragma solidity ^0.4.18;

import './SafeMath.sol';

contract PricingStrategy {

    using SafeMath for uint256;

    uint256 public constant FIRST_ROUND = 1523664001; //2018.04.14 00:00:01 GMT
    uint256 public constant FIRST_ROUND_RATE = 20; // FIRST ROUND BONUS RATE 20%

    uint256 public constant SECOND_ROUND = 1524268801; //2018.04.21 00:00:01 GMT
    uint256 public constant SECOND_ROUND_RATE = 10; // SECOND ROUND BONUS RATE 10%

    uint256 public constant FINAL_ROUND_RATE = 0; //FINAL ROUND BONUS RATE 0%


    function PricingStrategy() public {
        
    }

    function getRate() public constant returns(uint256 rate) {
        if (now<FIRST_ROUND) {
            return (FIRST_ROUND_RATE);
        } else if (now<SECOND_ROUND) {
            return (SECOND_ROUND_RATE);
        } else {
            return (FINAL_ROUND_RATE);
        }
    }

}