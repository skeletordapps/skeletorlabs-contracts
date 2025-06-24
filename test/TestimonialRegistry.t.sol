// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.30;

import {Test, console} from "forge-std/Test.sol";
import {TestimonialRegistry} from "../src/TestimonialRegistry.sol";
import {DeployTestimonials} from "../script/DeployTestimonials.s.sol";
import {ITestimonial} from "../src/interfaces/ITestimonial.sol";

contract TestimonialRegistryTest is Test {
    uint256 fork;
    string public rpc;

    DeployTestimonials deployer;
    TestimonialRegistry t;

    address owner;
    address bob;
    address mary;

    function setUp() public {
        rpc = vm.envString("BASE_RPC_URL");
        fork = vm.createFork(rpc);
        vm.selectFork(fork);

        deployer = new DeployTestimonials();
        t = deployer.run();

        owner = t.owner();
        bob = vm.addr(1);
        vm.label(bob, "bob");
        mary = vm.addr(2);
        vm.label(bob, "mary");
    }

    function testConstructor() external view {
        assertEq(t.nextId(), 0);
    }

    function testRevertStoreWithInvalidHash() external {
        vm.startPrank(bob);
        vm.expectRevert(abi.encodeWithSelector(ITestimonial.ITestimonial__Error.selector, "Invalid hash"));
        t.store(0);
        vm.stopPrank();
    }

    function testCanStore() external {
        bytes32 expectedHash = keccak256("fake-hash");

        vm.startPrank(bob);
        vm.expectEmit(true, true, true, true);
        emit ITestimonial.Stored(bob, 0, block.timestamp);
        t.store(expectedHash);
        vm.stopPrank();

        ITestimonial.Testimonial memory storedTestimonial = t.testimonialById(0);

        assertEq(storedTestimonial.author, bob);
        assertEq(storedTestimonial.hash, expectedHash);
        assertEq(storedTestimonial.timestamp, block.timestamp);
        assertEq(storedTestimonial.likes, 0);
    }

    modifier stored(address account) {
        bytes32 hash = keccak256("fake-hash");
        vm.startPrank(account);
        t.store(hash);
        vm.stopPrank();
        _;
    }

    function testRevertStoreWhenAlreadyStored() external stored(bob) {
        bytes32 hash = keccak256("fake-hash");
        vm.startPrank(bob);
        vm.expectRevert(abi.encodeWithSelector(ITestimonial.ITestimonial__Error.selector, "Already stored"));
        t.store(hash);
        vm.stopPrank();
    }

    function testRevertLikeWithInvalidId() external stored(bob) {
        vm.startPrank(bob);
        vm.expectRevert(abi.encodeWithSelector(ITestimonial.ITestimonial__Error.selector, "Invalid id"));
        t.like(2);
        vm.stopPrank();
    }

    function testCanLikeAStoredTestimonial() external stored(bob) {
        uint256 id = 0;
        vm.startPrank(mary);
        vm.expectEmit(true, true, true, true);
        emit ITestimonial.Liked(mary, id, block.timestamp);
        t.like(id);
        vm.stopPrank();

        ITestimonial.Testimonial memory storedTestimonial = t.testimonialById(id);
        assertEq(storedTestimonial.likes, 1);
        assertTrue(t.likedBy(id, mary));
    }

    function testRevertLikeWhenNotAllowed() external stored(bob) {
        uint256 id = 0;

        vm.startPrank(bob);
        vm.expectRevert(abi.encodeWithSelector(ITestimonial.ITestimonial__Error.selector, "Not allowed"));
        t.like(id);
        vm.stopPrank();

        vm.startPrank(owner);
        vm.expectRevert(abi.encodeWithSelector(ITestimonial.ITestimonial__Error.selector, "Not allowed"));
        t.like(id);
        vm.stopPrank();
    }

    function testRevertRemoveWhenNotAllowed() external stored(bob) {
        vm.startPrank(mary);
        vm.expectRevert(abi.encodeWithSelector(ITestimonial.ITestimonial__Error.selector, "Not allowed"));
        t.deactivate(0);
        vm.stopPrank();
    }

    function testOwnerCanRemoveStoredTestimonial() external stored(bob) {
        uint256 id = 0;

        vm.startPrank(owner);
        vm.expectEmit(true, true, true, true);
        emit ITestimonial.Deactivated(id, block.timestamp);
        t.deactivate(id);
        vm.stopPrank();
    }

    function testAuthorCanRemoveStoredTestimonial() external stored(bob) {
        uint256 id = 0;

        vm.startPrank(bob);
        vm.expectEmit(true, true, true, true);
        emit ITestimonial.Deactivated(id, block.timestamp);
        t.deactivate(id);
        vm.stopPrank();
    }
}
