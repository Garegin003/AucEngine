// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "../src/AucEngine.sol";

contract AucEngineTest is Test, AucEngine {
    AucEngine public aucEngine;

    function setUp() public {
        aucEngine = new AucEngine();
    }

    function testCreateAuction() public {
        uint256 startingPrice = 1 ether;
        uint256 discountRate = 5;
        uint256 duration = 2 days;
        string memory item = "Test Item";

        aucEngine.createAuction(startingPrice, discountRate, duration, item);

        (
            address seller,
            uint256 _startingPrice,
            uint256 finalPrice,
            uint256 startAt,
            uint256 endsAt,
            uint256 _discountRate,
            string memory _item,
            bool stopped
        ) = aucEngine.auctions(0);

        assert(seller == address(this));
        assert(_startingPrice == startingPrice);
        assert(finalPrice == startingPrice);
        assert(_discountRate == discountRate);
        assert(startAt == block.timestamp);
        assert(endsAt == block.timestamp + duration);
        assert(
            keccak256(abi.encodePacked((_item))) ==
                keccak256(abi.encodePacked((item)))
        );
        assert(!stopped);
    }

    function testGetPriceFor() public {
        uint256 startingPrice = 1 ether;
        uint256 discountRate = 5; // 5%
        uint256 duration = 2 days;
        string memory item = "Test Item";

        aucEngine.createAuction(startingPrice, discountRate, duration, item);

        uint256 price = aucEngine.getPriceFor(0);
        console.log("%s", price);
        console.log("%s", startingPrice);

        assertTrue(
            price <= startingPrice,
            "Price is not less than starting price"
        );
    }

    function testBuy() public {
        uint256 startingPrice = 1 ether;
        uint256 discountRate = 5;
        uint256 duration = 2 days;
        string memory item = "Test Item";

        aucEngine.createAuction(startingPrice, discountRate, duration, item);

        uint256 price = aucEngine.getPriceFor(0);

        aucEngine.buy{value: price}(0);

        (, , uint256 finalPrice, , , , , bool stopped) = aucEngine.auctions(0);

        assertTrue(stopped, "Auction is not stopped after purchase");

        assertTrue(
            finalPrice != startingPrice,
            "Final price matches the starting price"
        );
    }
}
