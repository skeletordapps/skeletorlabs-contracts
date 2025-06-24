// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.30;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ITestimonial} from "./interfaces/ITestimonial.sol";

/**
 * @title Testimonial Registry
 * @author You
 * @notice Stores testimonials as IPFS content hashes
 * @dev All testimonial records are stored on-chain and point to off-chain content via CID
 * aderyn-ignore-next-line(centralization-risk)
 */
contract TestimonialRegistry is Ownable {
    uint256 public nextId;

    mapping(bytes32 hash => bool used) private storedHashes;
    mapping(uint256 id => ITestimonial.Testimonial) private testimonials;
    mapping(uint256 id => mapping(address account => bool liked)) public likedBy;

    modifier onlyActive(uint256 id) {
        require(
            testimonials[id].active && testimonials[id].timestamp > 0, ITestimonial.ITestimonial__Error("Invalid id")
        );
        _;
    }

    constructor() Ownable(msg.sender) {}

    /**
     * @notice Stores a new testimonial on-chain
     * @param hash The IPFS hash of the testimonial content
     */
    function store(bytes32 hash) external {
        require(hash != bytes32(0), ITestimonial.ITestimonial__Error("Invalid hash"));
        require(!storedHashes[hash], ITestimonial.ITestimonial__Error("Already stored"));

        address sender = msg.sender;
        uint256 _nextId = nextId;
        storedHashes[hash] = true;
        testimonials[_nextId] = ITestimonial.Testimonial({
            id: _nextId,
            author: sender,
            hash: hash,
            timestamp: block.timestamp,
            likes: 0,
            active: true
        });

        nextId++;
        emit ITestimonial.Stored(sender, _nextId, block.timestamp);
    }

    /**
     * @notice Registers a like for an existing testimonial
     * @dev Authors and the contract owner cannot like their own testimonials
     * @param id The ID of the testimonial to like
     */
    function like(uint256 id) external onlyActive(id) {
        require(!likedBy[id][msg.sender], ITestimonial.ITestimonial__Error("Already liked"));
        ITestimonial.Testimonial storage testimonial = testimonials[id];
        require(
            msg.sender != testimonial.author && msg.sender != owner(), ITestimonial.ITestimonial__Error("Not allowed")
        );

        testimonial.likes++;
        likedBy[id][msg.sender] = true;

        emit ITestimonial.Liked(msg.sender, id, block.timestamp);
    }

    /**
     * @notice Removes a testimonial from the registry
     * @dev Only the author or the contract owner can delete
     * @param id The ID of the testimonial to delete
     */
    function deactivate(uint256 id) external onlyActive(id) {
        ITestimonial.Testimonial storage testimonial = testimonials[id];
        address sender = msg.sender;

        require(sender == testimonial.author || sender == owner(), ITestimonial.ITestimonial__Error("Not allowed"));

        testimonial.active = false;
        emit ITestimonial.Deactivated(id, block.timestamp);
    }

    /**
     * @notice Retrieves a testimonial by ID
     * @param id The testimonial ID
     * @return The testimonial struct
     */
    function testimonialById(uint256 id) external view returns (ITestimonial.Testimonial memory) {
        return testimonials[id];
    }
}
