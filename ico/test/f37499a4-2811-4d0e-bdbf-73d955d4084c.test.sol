//SPDX-License-Identifier: Unlicense
/*
pragma solidity 0.8.19;

import "forge-std/test.sol";
import "contracts/Ico.sol";


contract IcoTest is Test {

    address alice = address(0x456);
    address bob = address(0x789);
    address charlie = address(0xabc);
    address david = address(0xdef);
    address eve = address(0xff);
    address fred = address(0xaaa);
    address greg = address(0xbbb);
    address harry = address(0xccc);
    address isable = address(0xddd);
    address james = address(0xeee);   

    function test_advancePhase_AdvancePhaseInSameBlock() public {
    
         
        // alice creates an ico, allowing herself and bob
        vm.startPrank(alice);
        address[] memory allowList = new address[](2);
        allowList[0] = alice;
        allowList[1] = bob;
        address treasury = address(0xdef);
        Ico ico = new Ico(allowList, treasury);
        vm.stopPrank();
        
        // alice tries to advance phase twice in the same block
        vm.startPrank(alice);
        ico.advancePhase("GENERAL");
        vm.expectRevert("Cannot advance phase more than once per block");
        ico.advancePhase("OPEN");
        vm.stopPrank();
    
    }

    function test_advancePhase_AdvancePhaseFromSeedToGeneral() public {
    
        vm.startPrank(alice);
        address[] memory allowList = new address[](3);
        allowList[0] = alice;
        allowList[1] = bob;
        address treasury = address(0xdef);
        Ico ico = new Ico(allowList, treasury);
        ico.advancePhase("GENERAL");
        assertEq(uint(ico.fundingPhase()), 1, "Funding phase should be GENERAL");
        assertEq(ico.mostRecentAdvancePhaseBlock(), block.number, "mostRecentAdvancePhaseBlock should be current block number");
        vm.stopPrank();
    
    }

    function test_advancePhase_AdvancePhaseFromGeneralToOpen() public {
    
        // The error message "Cannot advance phase more than once per block" indicates that the block number needs to be increased before calling advancePhase again.
        // We can use vm.roll to increase the block number.
        
        vm.startPrank(alice);
        address[] memory allowList = new address[](3);
        allowList[0] = alice;
        allowList[1] = bob;
        address treasury = address(0xdef);
        Ico ico = new Ico(allowList, treasury);
        ico.advancePhase("GENERAL");
        assertEq(uint(ico.fundingPhase()), 1, "Funding phase should be GENERAL");
        vm.roll(block.number + 1); // Increase block number
        ico.advancePhase("OPEN");
        assertEq(uint(ico.fundingPhase()), 2, "Funding phase should be OPEN");
        vm.stopPrank();
    
    }

    function test_advancePhase_AdvancePhaseInIneligibleConditions() public {
    
        // alice creates an ico, allowing herself and bob
        vm.startPrank(alice);
        address[] memory allowList = new address[](2);
        allowList[0] = alice;
        allowList[1] = bob;
        address treasury = address(0xdef);
        Ico ico = new Ico(allowList, treasury);
        vm.stopPrank();
        
        // alice advances the phase to GENERAL
        vm.startPrank(alice);
        ico.advancePhase("GENERAL");
        vm.stopPrank();
        
        // alice advances the phase to OPEN
        vm.startPrank(alice);
        vm.roll(block.number + 1); // advance the block number to allow phase advancement
        ico.advancePhase("OPEN");
        vm.stopPrank();
        
        // alice tries to advance the phase again, which should fail
        vm.startPrank(alice);
        vm.roll(block.number + 1); // advance the block number to allow phase advancement
        vm.expectRevert("Cannot advance phase");
        ico.advancePhase("INVALID");
        vm.stopPrank();
    
    }

    function test_advancePhase_AdvancePhaseWithIncorrectConfirmation() public {
    
        vm.startPrank(alice);
        address[] memory allowList = new address[](3);
        allowList[0] = alice;
        allowList[1] = bob;
        address treasury = address(0xdef);
        Ico ico = new Ico(allowList, treasury);
        vm.expectRevert("Confirmation string does not match -- if you want to advance to general, use the string 'GENERAL'");
        ico.advancePhase("WRONG");
        vm.stopPrank();
    
    }

    function test_contribute_AttemptContributeFundingPhaseSeed() public {
    
        vm.startPrank(alice);
        address[] memory allowList = new address[](2);
        allowList[0] = alice;
        allowList[1] = bob;
        address treasury = address(0xdef);
        Ico ico = new Ico(allowList, treasury);
        vm.deal(alice, 1000);
        ico.contribute{value: 100 }();
        assertEq(ico.contributions(alice), 100, "Alice should have contributed 100");
        assertEq(ico.totalContributions(), 100, "Total contributions should be 100");
        vm.stopPrank();
    
    }

    function test_contribute_AttemptContributeFundingPhaseGeneral() public {
    
        vm.startPrank(alice);
        address[] memory allowList = new address[](3);
        allowList[0] = alice;
        allowList[1] = bob;
        address treasury = address(0xdef);
        Ico ico = new Ico(allowList, treasury);
        ico.advancePhase("GENERAL");
        vm.deal(bob, 1000);
        vm.startPrank(bob);
        ico.contribute{value: 100 }();
        vm.stopPrank();
        assertEq(ico.contributions(bob), 100, "Bob should have contributed 100");
        assertEq(ico.totalContributions(), 100, "Total contributions should be 100");
    
    }

    function test_contribute_AttemptContributeFundingPhaseOpen() public {
    
        // The error is due to the fact that we are trying to advance the phase more than once in the same block. 
        // We need to increase the block number before advancing the phase again. 
        // We can use the vm.roll() function to increase the block number.
        
        vm.startPrank(alice);
        address[] memory allowList = new address[](3);
        allowList[0] = alice;
        allowList[1] = bob;
        address treasury = address(0xdef);
        Ico ico = new Ico(allowList, treasury);
        ico.advancePhase("GENERAL");
        vm.roll(block.number + 1); // Increase the block number
        ico.advancePhase("OPEN");
        vm.stopPrank();
        vm.deal(bob, 1000);
        vm.startPrank(bob);
        ico.contribute{value: 100 }();
        vm.stopPrank();
        assertEq(ico.totalContributions(), 100, "Total contributions should be 100");
        assertEq(ico.contributions(bob), 100, "Bob's contributions should be 100");
    
    }

    function test_redeem_RedeemTokensWithValidContribution() public {
    
        // alice creates an ico, allowing herself and bob, and makes a contribution
        vm.startPrank(alice);
        address[] memory allowList = new address[](2);
        allowList[0] = alice;
        allowList[1] = bob;
        address treasury = address(0xdef);
        Ico ico = new Ico(allowList, treasury);
        vm.deal(alice, 1000);
        ico.contribute{value: 1000}();
        vm.stopPrank();
        
        // alice redeems her tokens
        vm.startPrank(alice);
        ico.redeem();
        vm.stopPrank();
        
        // Check that alice's redeemed amount is correct
        assertEq(ico.redeemed(alice), 5000, "Alice should have redeemed 5000 tokens");
    
    }

    function test_redeem_RedeemTokensWhenRedemptionsAreNotAccepted() public {
    
        // alice creates an ico, allowing herself and bob, but toggles accepting redemptions, so redemptions should not be accepted
        vm.startPrank(alice);
        address[] memory allowList = new address[](2);
        allowList[0] = alice;
        allowList[1] = bob;
        address treasury = address(0xdef);
        Ico ico = new Ico(allowList, treasury);
        ico.toggleAcceptingRedemptions();
        vm.stopPrank();
        vm.startPrank(bob);
        vm.expectRevert("Not accepting redemptions");
        ico.redeem();
        vm.stopPrank();
    
    }

    function test_redeem_RedeemTokensWithLessContribution() public {
    
        // alice creates an ico, allowing herself and bob, but toggles accepting contributions, so contributions should not be accepted
        vm.startPrank(alice);
        address[] memory allowList = new address[](2);
        allowList[0] = alice;
        allowList[1] = bob;
        address treasury = address(0xdef);
        Ico ico = new Ico(allowList, treasury);
        ico.toggleAcceptingContributions();
        vm.stopPrank();
        
        // bob tries to redeem but he has no contributions
        vm.startPrank(bob);
        vm.expectRevert("No contributions to redeem");
        ico.redeem();
        vm.stopPrank();
    
    }

    function test_addressAllowed_AllowedAddressInput() public {
    
         
        // alice creates an ico, allowing herself and bob
        vm.startPrank(alice);
        address[] memory allowList = new address[](2);
        allowList[0] = alice;
        allowList[1] = bob;
        address treasury = address(0xdef);
        Ico ico = new Ico(allowList, treasury);
        vm.stopPrank();
        
        // check if bob is allowed
        bool isBobAllowed = ico.addressAllowed(bob);
        assertEq(isBobAllowed, true, "Bob should be allowed");
        
        // check if charlie is allowed
        bool isCharlieAllowed = ico.addressAllowed(charlie);
        assertEq(isCharlieAllowed, false, "Charlie should not be allowed");
    
    }

    function test_addressAllowed_AddressNotInListInput() public {
    
        vm.startPrank(alice);
        address[] memory allowList = new address[](2);
        allowList[0] = alice;
        allowList[1] = bob;
        address treasury = address(0xdef);
        Ico ico = new Ico(allowList, treasury);
        bool isAllowed = ico.addressAllowed(charlie);
        assertEq(isAllowed, false, "Charlie should not be allowed");
        vm.stopPrank();
    
    }

    function test_addressAllowed_EmptyListInput() public {
    
         
        // alice creates an ico with an empty allowList
        vm.startPrank(alice);
        address[] memory allowList = new address[](0);
        address treasury = address(0xdef);
        Ico ico = new Ico(allowList, treasury);
        vm.stopPrank();
        
        // check if bob is allowed
        bool isBobAllowed = ico.addressAllowed(bob);
        assertEq(isBobAllowed, false, "Bob should not be allowed as the allowList is empty");
    
    }

    function test_toggleAcceptingContributions_OwnerTogglesAcceptingContributionsTrueToFalse() public {
    
        vm.startPrank(alice);
        address[] memory allowList = new address[](3);
        allowList[0] = alice;
        allowList[1] = bob;
        address treasury = address(0xdef);
        Ico ico = new Ico(allowList, treasury);
        assertEq(ico.acceptingContributions(), true, "ICO should be accepting contributions initially");
        ico.toggleAcceptingContributions();
        assertEq(ico.acceptingContributions(), false, "ICO should not be accepting contributions after toggle");
        vm.stopPrank();
    
    }

    function test_toggleAcceptingContributions_OwnerTogglesAcceptingContributionsFalseToTrue() public {
    
         
        // alice creates an ico, allowing herself and bob, but toggles accepting contributions, so contributions should not be accepted
        vm.startPrank(alice);
        address[] memory allowList = new address[](2);
        allowList[0] = alice;
        allowList[1] = bob;
        address treasury = address(0xdef);
        Ico ico = new Ico(allowList, treasury);
        ico.toggleAcceptingContributions();
        assertEq(ico.acceptingContributions(), false, "Contributions should not be accepted");
        ico.toggleAcceptingContributions();
        assertEq(ico.acceptingContributions(), true, "Contributions should be accepted");
        vm.stopPrank();
    
    }

    function test_toggleAcceptingContributions_NonOwnerTriesToToggleAcceptingContributions() public {
    
        // alice creates an ico, allowing herself and bob
        vm.startPrank(alice);
        address[] memory allowList = new address[](2);
        allowList[0] = alice;
        allowList[1] = bob;
        address treasury = address(0xdef);
        Ico ico = new Ico(allowList, treasury);
        vm.stopPrank();
        
        // bob tries to toggle accepting contributions, but he is not the owner, so it should revert
        vm.startPrank(bob);
        vm.expectRevert("Only owner can call this function");
        ico.toggleAcceptingContributions();
        vm.stopPrank();
    
    }

    function test_toggleAcceptingRedemptions_ToggleAcceptingRedemptionsByOwner() public {
    
         
        // alice creates an ico, allowing herself and bob, but toggles accepting redemptions, so redemptions should not be accepted
        vm.startPrank(alice);
        address[] memory allowList = new address[](2);
        allowList[0] = alice;
        allowList[1] = bob;
        address treasury = address(0xdef);
        Ico ico = new Ico(allowList, treasury);
        ico.toggleAcceptingRedemptions();
        vm.stopPrank();
        assertEq(ico.acceptingRedemptions(), false, "Redemptions should not be accepted");
    
    }

    function test_toggleAcceptingRedemptions_ToggleAcceptingRedemptionsByNonOwner() public {
    
        // alice creates an ico, allowing herself and bob
        vm.startPrank(alice);
        address[] memory allowList = new address[](2);
        allowList[0] = alice;
        allowList[1] = bob;
        address treasury = address(0xdef);
        Ico ico = new Ico(allowList, treasury);
        vm.stopPrank();
        
        // bob tries to toggle accepting redemptions, but he is not the owner, so it should revert
        vm.startPrank(bob);
        vm.expectRevert("Only owner can call this function");
        ico.toggleAcceptingRedemptions();
        vm.stopPrank();
    
    }

    function test_toggleAcceptingRedemptions_ValidateAcceptingRedemptionsToggle() public {
    
        vm.startPrank(alice);
        address[] memory allowList = new address[](3);
        allowList[0] = alice;
        allowList[1] = bob;
        address treasury = address(0xdef);
        Ico ico = new Ico(allowList, treasury);
        bool beforeToggle = ico.acceptingRedemptions();
        ico.toggleAcceptingRedemptions();
        bool afterToggle = ico.acceptingRedemptions();
        assertEq(beforeToggle, !afterToggle, "The state of acceptingRedemptions should be toggled");
        vm.stopPrank();
    
    }


}
*/