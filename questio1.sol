// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MarketplaceEscrow {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    enum State { Created, Locked, Release, Inactive }

    struct Item {
        string name;
        uint price;
        address payable seller;
        address buyer;
        State state;
    }

    mapping(string => Item) public items;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this.");
        _;
    }

    modifier onlyBuyer(string memory _itemName) {
        require(items[_itemName].buyer == msg.sender, "Only buyer can call this.");
        _;
    }

    modifier onlySeller(string memory _itemName) {
        require(items[_itemName].seller == msg.sender, "Only seller can call this.");
        _;
    }

    modifier inState(string memory _itemName, State _state) {
        require(items[_itemName].state == _state, "Invalid state.");
        _;
    }

    function listItem(string memory _name, uint _price) public {
        require(items[_name].seller == address(0), "Item already listed.");
        items[_name] = Item({
            name: _name,
            price: _price,
            seller: payable(msg.sender),
            buyer: address(0),
            state: State.Created
        });
    }

    function buyItem(string memory _name) public payable inState(_name, State.Created) {
        require(msg.value == items[_name].price, "Incorrect value sent.");
        items[_name].buyer = msg.sender;
        items[_name].state = State.Locked;
    }

    function confirmReceipt(string memory _name) public onlyBuyer(_name) inState(_name, State.Locked) {
        items[_name].state = State.Release;
        items[_name].seller.transfer(items[_name].price);
    }

    function resolveDispute(string memory _name, bool favorBuyer) public onlyOwner inState(_name, State.Locked) {
        if (favorBuyer) {
            payable(items[_name].buyer).transfer(items[_name].price);
        } else {
            items[_name].seller.transfer(items[_name].price);
        }
        items[_name].state = State.Inactive;
    }

    function getItemDetails(string memory _name) public view returns (string memory, uint, address, address, State) {
        Item memory item = items[_name];
        return (item.name, item.price, item.seller, item.buyer, item.state);
    }
}
