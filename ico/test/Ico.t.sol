// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "forge-std/test.sol";
import "contracts/Ico.sol";
import "contracts/SpaceCoin.sol";

contract IcoTest is Test {

    address icoCreator = address(0x123);
    address public treasury = address(0xdef);

    address alice = address(0x456);
    address bob = address(0x789);
    address charlie = address(0xabc);
    address delta = address(0xdef);

    Ico ico;
    SpaceCoin coin;


    function setUp() public {
        vm.startPrank(icoCreator);
        address[] memory allowList = new address[](3);
        allowList[0] = alice; 
        allowList[1] = bob;
        allowList[2] = charlie;        
        ico = new Ico(allowList, treasury);
        coin = ico.token();
        vm.stopPrank();


        vm.deal(alice, 100000 );
    }

    function testAdvancePhases() public {
        
        assertEq(uint(ico.fundingPhase()), uint(Ico.FundingPhase.SEED));
        vm.startPrank(icoCreator);
        ico.advancePhase("GENERAL");
        assertEq(uint(ico.fundingPhase()), uint(Ico.FundingPhase.GENERAL));
        ico.advancePhase("OPEN");
        assertEq(uint(ico.fundingPhase()), uint(Ico.FundingPhase.OPEN));
        vm.stopPrank();
    }

    function testAdvancePhasesFailGeneral() public {
        assertEq(uint(ico.fundingPhase()), uint(Ico.FundingPhase.SEED));
        vm.startPrank(icoCreator);
        vm.expectRevert();
        ico.advancePhase("");
        vm.stopPrank();
    }

    function testAdvancePhasesFailOpen() public {

        vm.startPrank(icoCreator);

        assertEq(uint(ico.fundingPhase()), uint(Ico.FundingPhase.SEED));
        
        vm.expectRevert("Confirmation string does not match -- if you want to advance to general, use the string 'GENERAL'");
        ico.advancePhase("BLOOP");
        assertEq(uint(ico.fundingPhase()), uint(Ico.FundingPhase.SEED));
        

        ico.advancePhase("GENERAL");
        assertEq(uint(ico.fundingPhase()), uint(Ico.FundingPhase.GENERAL));
        
        vm.expectRevert("Confirmation string does not match -- if you want to advance to open, use the string 'OPEN'");
        ico.advancePhase("BLOOP");
        assertEq(uint(ico.fundingPhase()), uint(Ico.FundingPhase.GENERAL));

        ico.advancePhase("OPEN");
        assertEq(uint(ico.fundingPhase()), uint(Ico.FundingPhase.OPEN)); 
        
        vm.expectRevert("Cannot advance phase"); 
        ico.advancePhase("");
        vm.stopPrank();
    }

    function testAdvancePhaseFailNotOwner() public {
        assertEq(uint(ico.fundingPhase()), uint(Ico.FundingPhase.SEED));
        vm.startPrank(alice);
        vm.expectRevert();
        ico.advancePhase("GENERAL");
        vm.stopPrank();
    }

    function test_contributeSeed() public {

        vm.startPrank(alice);
        ico.contribute{value: 100 }();

        assertEq(ico.totalContributions(), 100 );
        assertEq(ico.contributions(alice), 100 );


        vm.expectRevert("Seed phase max contribution reached -- total");
        ico.contribute{value: 1400 }();
        vm.stopPrank();

        vm.deal(bob, 15001 );
        vm.startPrank(bob);
        
        vm.expectRevert();
        ico.contribute{value: 15001 }();
        vm.stopPrank();

        vm.deal(delta, 1500 );
        vm.startPrank(delta);
        vm.expectRevert('Address not allowed to contribute');
        ico.contribute{value: 100 }();

    }

    function testAddressAllowed() public {
        assertEq(ico.addressAllowed(alice), true);
        assertEq(ico.addressAllowed(bob), true);
        assertEq(ico.addressAllowed(charlie), true);
        assertEq(ico.addressAllowed(delta), false);
    }

    function testTransferToggleTax() public {
        
        assertEq(coin.taxEnabled(), true);

        vm.deal(charlie, 100000);

        vm.startPrank(charlie);

        // get 200 tokens
        ico.contribute{value: 60 }();


        coin.transfer(bob, 100);
        assertEq(coin.balanceOf(bob), 98, "2% tax should be taken out");
        
        vm.startPrank(icoCreator);
        coin.toggleTax();
        vm.stopPrank();

        vm.startPrank(charlie);
        coin.transfer(alice, 100);
        vm.stopPrank();
        assertEq(coin.balanceOf(alice), 100, "No tax should be taken out");

    }

    function testContributeGeneral() public {

        vm.startPrank(icoCreator);
        ico.advancePhase("GENERAL");
        vm.stopPrank();


        vm.deal(alice, 100000 );    

        vm.startPrank(alice);

        vm.expectRevert();
        ico.contribute{value: 300000 }();

        ico.contribute{value: 3 }();

        assertEq(ico.totalContributions(), 3 , "Total contributions should be 3 ");
        assertEq(ico.contributions(alice), 3 , "Alice should have contributed 3 ");
    }

    function testContributeOpen() public {

        vm.startPrank(icoCreator);
        ico.advancePhase("GENERAL");
        ico.advancePhase("OPEN");
        vm.stopPrank();

        vm.startPrank(alice);
        ico.contribute{value: 3 }();

        assertEq(ico.totalContributions(), 3 );
        assertEq(ico.contributions(alice), 3 );
    }

    
}