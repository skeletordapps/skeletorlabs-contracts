// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.30;

interface ITestimonial {
    event Stored(address indexed author, uint256 indexed id, uint256 timestamp);
    event Liked(address indexed liker, uint256 indexed id, uint256 timestamp);
    event Removed(uint256 indexed id, uint256 timestamp);

    struct Testimonial {
        address author;
        bytes32 hash;
        uint256 timestamp;
        uint256 likes;
    }

    // aderyn-fp-next-line(unused-error)
    error ITestimonial__Error(string message);
}
