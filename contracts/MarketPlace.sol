// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ticket.sol";

contract Market is TicketResale {
    struct Listing {
        address seller;
        uint256 price;
        bool active;
    }

    mapping(uint256 => Listing) public listings;
    uint256 public listingCount;

    event TicketListed(
        uint256 indexed listingId,
        address indexed seller,
        uint256 price
    );
    event TicketPurchased(
        uint256 indexed listingId,
        address indexed buyer,
        uint256 price
    );

    constructor(uint256 _ticketPrice) TicketResale(_ticketPrice) {}

    function listTicket(uint256 price) public unpaused {
        require(ownerTicketPrice[msg.sender] > 0, "You don't own a ticket");
        require(price > 0, "Price must be greater than zero");

        listingCount++;
        listings[listingCount] = Listing(msg.sender, price, true);

        emit TicketListed(listingCount, msg.sender, price);
    }

    function buyTicket(uint256 listingId) public payable unpaused {
        Listing storage listing = listings[listingId];

        require(listing.active, "Listing is not active");
        require(msg.value >= listing.price, "Insufficient funds");

        payable(listing.seller).transfer(msg.value);
        ownerTicketPrice[msg.sender] = ownerTicketPrice[listing.seller];
        ownerTicketPrice[listing.seller] = 0;
        listing.active = false;

        emit TicketPurchased(listingId, msg.sender, listing.price);
    }
}
