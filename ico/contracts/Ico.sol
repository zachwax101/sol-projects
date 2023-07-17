//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "forge-std/console.sol";
import "./SpaceCoin.sol";

contract Ico {

    enum FundingPhase { SEED, GENERAL, OPEN }

    FundingPhase public fundingPhase;
    address public owner;
    uint public totalContributions;
    mapping(address => uint) public contributions;
    uint constant public SEED_MAX_TOTAL_CONTRIBUTION = 15000 ether;
    uint constant public SEED_MAX_INDIVIDUAL_CONTRIBUTION = 1500 ether;

    uint constant public GENERAL_MAX_TOTAL_CONTRIBUTION = 30000 ether;
    uint constant public GENERAL_MAX_INDIVIDUAL_CONTRIBUTION = 1000 ether;

    uint constant public OPEN_MAX_TOTAL_CONTRIBUTION = 30000 ether;
    SpaceCoin public token;

    // maybe should use something that can be made constant, like bytes, instead of array which maybe can be manipulated by storage slot techniques
    address[] public allowList;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(address[] memory _allowList, address _treasury) {
        allowList = _allowList;
        fundingPhase = FundingPhase.SEED;
        owner = msg.sender;

        token = new SpaceCoin(_treasury, owner);
    }

    function advancePhase(string memory _confirmation) onlyOwner public {
        if (fundingPhase == FundingPhase.SEED) {
            require(keccak256(abi.encodePacked(_confirmation)) == keccak256(abi.encodePacked("GENERAL")), "Confirmation string does not match -- if you want to advance to general, use the string 'GENERAL'");
            fundingPhase = FundingPhase.GENERAL;
        } else if (fundingPhase == FundingPhase.GENERAL) {
            require(keccak256(abi.encodePacked(_confirmation)) == keccak256(abi.encodePacked("OPEN")), "Confirmation string does not match -- if you want to advance to open, use the string 'OPEN'");
            fundingPhase = FundingPhase.OPEN;
        }else{
            revert("Cannot advance phase");
        }
    }

    function contribute() public payable {
        if(fundingPhase == FundingPhase.SEED) {
            contributeSeed();
        } 
        else if (fundingPhase == FundingPhase.GENERAL) {
            contributeGeneral();
        
        } else if (fundingPhase == FundingPhase.OPEN) {
            contributeOpen();
        }
    } 

    function contributeSeed() private {
        require(addressAllowed(msg.sender), "Address not allowed to contribute");
        require(totalContributions + msg.value < SEED_MAX_TOTAL_CONTRIBUTION, "Seed phase max contribution reached -- total");
        require(contributions[msg.sender] + msg.value < SEED_MAX_INDIVIDUAL_CONTRIBUTION, "Seed phase max contribution reached -- individual");
    
        contributions[msg.sender] += msg.value;
        totalContributions += msg.value;

        uint redeemed_amount = msg.value * 5;
        token.transfer(msg.sender, redeemed_amount);

    }

    function contributeGeneral() private {
        require(totalContributions + msg.value < GENERAL_MAX_TOTAL_CONTRIBUTION , "Seed phase max contribution reached");
        require(contributions[msg.sender] + msg.value < GENERAL_MAX_INDIVIDUAL_CONTRIBUTION, "Seed phase max contribution reached");
          
        contributions[msg.sender] += msg.value;
        totalContributions += msg.value;
        uint redeemed_amount = msg.value * 5;
        token.transfer(msg.sender, redeemed_amount);
    }
    
    function contributeOpen() private {

        require(totalContributions + msg.value < OPEN_MAX_TOTAL_CONTRIBUTION , "Seed phase max contribution reached");

        contributions[msg.sender] += msg.value;
        totalContributions += msg.value;
        uint redeemed_amount = msg.value * 5;
        token.transfer(msg.sender, redeemed_amount);
    }
    

    function addressAllowed(address _address) public view returns (bool) {
        for (uint i = 0; i < allowList.length; i++) {
            if (allowList[i] == _address) {
                return true;
            }
        }
        return false;
    }
}


