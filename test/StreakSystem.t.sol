// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {StreakSystem} from "../src/StreakSystem.sol";

contract StreakSystemTest is Test {
    StreakSystem public streakSystem;
    address user = makeAddr("user");

    function setUp() public {
        streakSystem = new StreakSystem();
    }

    function testInitialStreak() public view {
        assertEq(streakSystem.streak(address(this)), 0);
        assertEq(streakSystem.points(address(this)), 0);
    }

    function testClaim() public {
        streakSystem.claim();
        assertEq(streakSystem.streak(address(this)), 1);
        assertEq(streakSystem.points(address(this)), 0);
    }

    function testClaimMultipleTimes() public {
        streakSystem.claim();
        vm.warp(block.timestamp + 1440 minutes); // Move forward in time
        streakSystem.claim();
        assertEq(streakSystem.streak(address(this)), 2);
    }

    function testClaimAfterResetTime() public {
        streakSystem.claim();
        vm.warp(block.timestamp + 1440 minutes + 2880 minutes); // Move forward in time
        streakSystem.claim();
        assertEq(streakSystem.streak(address(this)), 1);
    }

    function testClaimBeforeIncrementTime() public {
        streakSystem.claim();
        vm.expectRevert("You can't claim yet");
        streakSystem.claim();
    }

    function testClaimFor() public {
        streakSystem.claim();
        vm.warp(block.timestamp + 1440 minutes); // Move forward in time
        streakSystem.claimFor(address(this));
        assertEq(streakSystem.streak(address(this)), 2);
    }

    function testClaimForWithAdminRole() public {
        streakSystem.claim();
        vm.warp(block.timestamp + 1440 minutes); // Move forward in time
        streakSystem.claimFor(address(this));
        assertEq(streakSystem.streak(address(this)), 2);
    }

    function testClaimForWithoutAdminRole() public {
        bytes4 selector = bytes4(keccak256("AccessControlUnauthorizedAccount(address,bytes32)"));
        bytes memory expectedError = abi.encodeWithSelector(selector, user, keccak256("CLAIM_ADMIN_ROLE"));
        vm.expectRevert(expectedError);
        vm.prank(user);
        streakSystem.claimFor(address(this));
    }

    function testClaimWithPointMilestone() public {
        // Set a milestone for the first claim
        streakSystem.setPointMilestone(1, 10);
        streakSystem.claim();
        assertEq(streakSystem.streak(address(this)), 1);
        assertEq(streakSystem.points(address(this)), 10);
        vm.warp(block.timestamp + 1440 minutes); // Move forward in time
        streakSystem.claim();
        assertEq(streakSystem.streak(address(this)), 2);
        assertEq(streakSystem.points(address(this)), 20);
    }

    function testClaimWithPointMilestones() public {
        // Set a milestone for the first claim
        streakSystem.setPointMilestone(1, 10);
        streakSystem.setPointMilestone(3, 50);
        streakSystem.setPointMilestone(5, 100);
        streakSystem.claim();
        vm.warp(block.timestamp + 1440 minutes); // Move forward in time
        streakSystem.claim();
        assertEq(streakSystem.streak(address(this)), 2);
        assertEq(streakSystem.points(address(this)), 20);
        vm.warp(block.timestamp + 2880 minutes); // Move forward in time
        streakSystem.claim();
        assertEq(streakSystem.streak(address(this)), 3);
        assertEq(streakSystem.points(address(this)), 70);
        vm.warp(block.timestamp + 2880 minutes); // Move forward in time
        streakSystem.claim();
        assertEq(streakSystem.streak(address(this)), 4);
        assertEq(streakSystem.points(address(this)), 120);
        vm.warp(block.timestamp + 2880 minutes); // Move forward in time
        streakSystem.claim();
        assertEq(streakSystem.streak(address(this)), 5);
        assertEq(streakSystem.points(address(this)), 220);
    }
}
