// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

contract Marketplace{

    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    event ItemPurchased(address indexed purchaser, uint256 id);

    address private owner;

    struct Item {
        uint256 id;
        string name;
        string imageLink;
        uint256 price;
    }

    uint256 public itemCount;

	mapping(uint256 => Item) public catalog_mapping;

	mapping(address => uint256[]) public purchases;

    // modifier to check if caller is owner
    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    constructor() {
        catalog_mapping[1] = Item(1,"camiseta de juego", "https://f.fcdn.app/imgs/eab4f6/www.tiendapenarol.com.uy/capuy/9a53/webp/catalogo/706042_01_2/460x460/penarol-home-jersey-23-70604201-amarillo.jpg", 2000000000000);
        catalog_mapping[2] = Item(2,"camiseta de entrenamiento", "https://f.fcdn.app/imgs/95a5a1/www.tiendapenarol.com.uy/capuy/c66f/webp/catalogo/704925_07_1/2000-2000/penarol-jersey-jr-70492507-amarillo.jpg", 1500000000000);
        catalog_mapping[3] = Item(3,"camiseta de juego nino", "https://f.fcdn.app/imgs/850ea7/www.tiendapenarol.com.uy/capuy/2eac/webp/catalogo/775321_01_1/460x460/penarol-home-mini-jersey-23-77532101-amarillo.jpg", 1000000000000);
        itemCount = 3;
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }



    function buy(uint256 id) public payable returns (bool){

        require (catalog_mapping[id].price != 0, "Selected item does not exist");
        require (catalog_mapping[id].price == msg.value, "The sent amount must be the same as the item");
        uint256[] storage list  = purchases[msg.sender];
        list.push(id);
        purchases[msg.sender] = list;
        emit ItemPurchased(address(msg.sender), id);
        return true;
    }

    function getItemDetail(uint256 id) external view returns (Item memory) {
        return catalog_mapping[id];
    }

    function getAddressPurchases() external view returns (uint256[] memory) {
        uint256[] memory list = purchases[address(msg.sender)];
        return list;
    }

}
