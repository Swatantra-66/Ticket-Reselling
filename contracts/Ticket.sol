// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TicketResale {
    address public owner;
    bool public paused;
    uint256 public ticketPrice;

    mapping(address => uint256) public ownerTicketPrice;

    constructor(uint256 _ticketPrice) {
        owner = msg.sender;
        paused = false;
        ticketPrice = _ticketPrice;
        ownerTicketPrice[owner] = _ticketPrice;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    modifier unpaused() {
        require(paused == false, "Ticket Resale is paused now!");
        _;
    }

    event TicketSell(
        address indexed seller,
        address indexed buyer,
        uint256 ticketPrice
    );
    event OwnershipTransferred(address indexed seller, address indexed to);
    event TicketPriceChanged(uint256 oldPrice, uint256 newPrice);
    event TicketBought(address indexed buyer, uint256 ticketCount);

    function pause() public onlyOwner {
        paused = true;
    }

    function unpause() public onlyOwner {
        paused = false;
    }

    function setTicketPrice(uint256 newPrice) public onlyOwner {
        require(newPrice > 0, "Ticket price must be greater than zero");
        emit TicketPriceChanged(ticketPrice, newPrice);
        ticketPrice = newPrice;
    }

    function buyTicket() public payable unpaused {
        require(msg.value >= ticketPrice, "Insufficient funds");
        ownerTicketPrice[msg.sender] += 1;
        emit TicketBought(msg.sender, 1);
    }

    function ticketSell(address to) public payable unpaused {
        require(
            ownerTicketPrice[msg.sender] > 0,
            "You don't own a ticket to sell"
        );
        require(to != msg.sender, "You cannot sell a ticket to yourself");
        require(msg.value >= ticketPrice, "Insufficient payment!");
        payable(msg.sender).transfer(msg.value); //
        ownerTicketPrice[to] = ownerTicketPrice[msg.sender];
        ownerTicketPrice[msg.sender] = 0;

        emit TicketSell(msg.sender, to, msg.value);
    }

    function changeOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        emit OwnershipTransferred(owner, newOwner);

        owner = newOwner;
    }
}
