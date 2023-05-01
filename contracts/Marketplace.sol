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
        address merchantAddress;
        string merchantName;
    }

    uint256 public itemCount;

	mapping(uint256 => Item) public catalog_mapping;

	mapping(address => uint256[]) public purchases;

    mapping(address => uint256) public collect_merchant;

	mapping(address => uint256[]) public collect_hostory;

    // modifier to check if caller is owner
    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    constructor() {
        catalog_mapping[1] = Item(1,"camiseta de juego", "https://f.fcdn.app/imgs/eab4f6/www.tiendapenarol.com.uy/capuy/9a53/webp/catalogo/706042_01_2/460x460/penarol-home-jersey-23-70604201-amarillo.jpg", 2000000000000000000, msg.sender, "Carbonero store");
        catalog_mapping[2] = Item(2,"camiseta de entrenamiento", "https://f.fcdn.app/imgs/95a5a1/www.tiendapenarol.com.uy/capuy/c66f/webp/catalogo/704925_07_1/2000-2000/penarol-jersey-jr-70492507-amarillo.jpg", 1500000000000000000, msg.sender, "Carbonero store");
        catalog_mapping[3] = Item(3,"camiseta de juego nino", "https://f.fcdn.app/imgs/850ea7/www.tiendapenarol.com.uy/capuy/2eac/webp/catalogo/775321_01_1/460x460/penarol-home-mini-jersey-23-77532101-amarillo.jpg", 1000000000000000000, msg.sender, "Carbonero store");
        itemCount = 3;
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }


    function buy(uint256[] memory ids) public payable returns (bool){
        uint256 total = 0;
        uint256[] storage list  = purchases[msg.sender];
        for (uint i = 0; i < ids.length; i++) {
            uint id = ids[i];
            Item memory _item = catalog_mapping[id];
            total = total + _item.price;
            list.push(id);
            uint256 merchantBalance = collect_merchant[_item.merchantAddress];
            collect_merchant[_item.merchantAddress] = merchantBalance + _item.price;
            emit ItemPurchased(address(msg.sender), id);
        }
        require (total == msg.value, "The sent amount must be the same as the item");

        purchases[msg.sender] = list;

        return true;
    }

    function getItemDetail(uint256 id) external view returns (Item memory) {
        return catalog_mapping[id];
    }

    function getAddressPurchases() external view returns (uint256[] memory) {
        uint256[] memory list = purchases[address(msg.sender)];
        return list;
    }

    function withdrawMoneyTo(address payable _to, uint256 amount) public {
        _to.transfer(amount);
        uint256[] storage list  = collect_hostory[_to];
        list.push(amount);
        collect_hostory[_to] = list;
        collect_merchant[_to] = 0;
    }

    function getMerchantBalance(address merchant) public view  returns (uint256){
        return collect_merchant[merchant];
    }



}
