// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;

contract AucEngine {
    address owner;
    uint256 constant DURATION = 2 days;
    uint256 FEE = 10; // %
    struct Auction {
        address payable seller;
        uint256 startingPrice;
        uint256 finalPrice;
        uint256 startAt;
        uint256 endsAt;
        uint256 discountRate;
        string item;
        bool stopped;
    }

    Auction[] public auctions;

    event AuctionCreated(
        uint256 index,
        string iteamName,
        uint256 startingPrice,
        uint256 duration
    );

    event AunctionEnded(uint256 index, uint256 finalPrice, address winner);

    constructor() {
        owner = msg.sender;
    }

    function createAuction(
        uint256 _startingPrice,
        uint256 _discountRate,
        uint256 _duration,
        string calldata _item
    ) external {
        uint256 duration = _duration == 0 ? DURATION : _duration;

        require(
            _startingPrice >= _discountRate * duration,
            "incorect starting price"
        );

        Auction memory newAuction = Auction({
            seller: payable(msg.sender),
            startingPrice: _startingPrice,
            finalPrice: _startingPrice,
            discountRate: _discountRate,
            startAt: block.timestamp, // now
            endsAt: block.timestamp + _duration,
            item: _item,
            stopped: false
        });

        auctions.push(newAuction);

        emit AuctionCreated(
            auctions.length - 1,
            _item,
            _startingPrice,
            duration
        );
    }

    function getPriceFor(uint256 _index) public view returns (uint256) {
        Auction memory cAuction = auctions[_index];
        require(!cAuction.stopped, "Stopped");
        uint elapsed = block.timestamp - cAuction.startAt;
        uint discount = cAuction.discountRate * elapsed;
        return cAuction.startingPrice - discount;
    }

    function buy(uint256 _index) external payable {
        Auction memory cAuction = auctions[_index];
        require(!cAuction.stopped, "Stopped");
        require(block.timestamp < cAuction.endsAt, "Ended");
        uint256 cPrice = getPriceFor(_index);
        require(msg.value >= cPrice, "nor enough funds");
        cAuction.stopped = true;
        cAuction.finalPrice = cPrice;
        uint256 refund = msg.value - cPrice;
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }
        cAuction.seller.transfer(cPrice - (cPrice * FEE) / 100);

        emit AunctionEnded(_index, cPrice, msg.sender);
    }
}
