// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "../src/AucEngine.sol";

contract AucEngineTest is Test, AucEngine {
    AucEngine public aucEngine;

    function setUp() public {
        aucEngine = new AucEngine();
    }

    function TestCreateAuction() public {
        uint256 startingPrice = 1 ether;
        uint256 discountRate = 5;
        uint256 duration = 2 days;
        string memory item = "Test Item";

        aucEngine.createAuction(startingPrice, discountRate, duration, item);

        AucEngine.Auction memory newAuction = AucEngine.auctions[1];
        assertEq(newAuction.seller, msg.sender);
        assertEq(newAuction.startingPrice, startingPrice);
        assertEq(newAuction.startingPrice, startingPrice);
        assertEq(newAuction.finalPrice, startingPrice);
        assertEq(newAuction.discountRate, discountRate);
        assertEq(newAuction.startAt, block.timestamp);
        assertEq(newAuction.endsAt, block.timestamp + duration);
        assertEq(newAuction.startAt, block.timestamp);
        assertEq(newAuction.item, item);
        assertFalse(newAuction.stopped);
    }

    function TestGetPriceFor() public {
        uint256 startingPrice = 1 ether;
        uint256 discountRate = 5;
        uint256 duration = 2 days;
        string memory item = "Test Item";

        aucEngine.createAuction(startingPrice, discountRate, duration, item);

        uint price = aucEngine.getPriceFor(0);
        assertTrue(price < startingPrice);
    }

    function TestBuy() public {
        uint256 startingPrice = 1 ether;
        uint256 discountRate = 5;
        uint256 duration = 2 days;
        string memory item = "Test Item";

        aucEngine.createAuction(startingPrice, discountRate, duration, item);

        uint256 price = aucEngine.getPriceFor(0);
        aucEngine.buy{value: price}(0);

        AucEngine.Auction memory auction = AucEngine.auctions[1];
        assertTrue(auction.stopped);
        assertEq(auction.finalPrice, price);
    }
}
