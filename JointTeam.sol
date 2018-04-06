pragma solidity ^0.4.18;

import './IERC20Token.sol';
import './SafeMath.sol';
import './MultiOwnable.sol';

contract JointTeam is MultiOwnable {

    struct LockedToken {
        uint256 lockedamount;
        uint256 unlockdate;
        bool released;
    }

    LockedToken[20] public LockedTokens;
    uint256 public constant decimalPlaces = 10**18;
    uint256 public constant quarter = 90 days;
    address public constant teamWallet = 0x25DE376B1469d523E66D8012EEc00CBaa566F4F9;
    uint256 public constant releaseStartTime = 1538352000; //2018.10.01
    IERC20Token public jointToken;
    uint256 public constant amount = 250000*decimalPlaces;

    function JointTeam() public {
        fillArray();
    }

    function changeJointAddress(address _jointToken) onlyOwner public {
        jointToken = IERC20Token(_jointToken);
    }

    function fillArray() private {
        
        LockedTokens[0] = (LockedToken(amount, releaseStartTime, false));
        LockedTokens[1] = (LockedToken(amount, releaseStartTime + quarter, false));
        LockedTokens[2] = (LockedToken(amount, releaseStartTime + 2*quarter, false));
        LockedTokens[3] = (LockedToken(amount, releaseStartTime + 3*quarter, false));
        LockedTokens[4] = (LockedToken(amount, releaseStartTime + 4*quarter, false));
        LockedTokens[5] = (LockedToken(amount, releaseStartTime + 5*quarter, false));
        LockedTokens[6] = (LockedToken(amount, releaseStartTime + 6*quarter, false));
        LockedTokens[7] = (LockedToken(amount, releaseStartTime + 7*quarter, false));
        LockedTokens[8] = (LockedToken(amount, releaseStartTime + 8*quarter, false));
        LockedTokens[9] = (LockedToken(amount, releaseStartTime + 9*quarter, false));
        LockedTokens[10] = (LockedToken(amount, releaseStartTime + 10*quarter, false));
        LockedTokens[11] = (LockedToken(amount, releaseStartTime + 11*quarter, false));
        LockedTokens[12] = (LockedToken(amount, releaseStartTime + 12*quarter, false));
        LockedTokens[13] = (LockedToken(amount, releaseStartTime + 13*quarter, false));
        LockedTokens[14] = (LockedToken(amount, releaseStartTime + 14*quarter, false));
        LockedTokens[15] = (LockedToken(amount, releaseStartTime + 15*quarter, false));
        LockedTokens[16] = (LockedToken(amount, releaseStartTime + 16*quarter, false));
        LockedTokens[17] = (LockedToken(amount, releaseStartTime + 17*quarter, false));
        LockedTokens[18] = (LockedToken(amount, releaseStartTime + 18*quarter, false));
        LockedTokens[19] = (LockedToken(amount, releaseStartTime + 19*quarter, false));
    }

    function releaseTokens() public {
        uint256 length = LockedTokens.length;

        for (uint8 i = 0; i < length; ++i) {
            if (LockedTokens[i].unlockdate<=now && LockedTokens[i].released==false) {
                require(jointToken.transfer(teamWallet, LockedTokens[i].lockedamount));
                LockedTokens[i].released = true;
            }
        }
    }

}