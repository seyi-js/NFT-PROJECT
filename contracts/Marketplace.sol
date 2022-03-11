// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract MarketPlace is ReentrancyGuard{
    //ReentrancyGuard for security when one contract is called by another.

    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    address payable owner;
    uint256 listingPrice = 0.1 ether;

    constructor(){
        owner = payable(msg.sender);
    }

    struct MarketItem{
        uint itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
    }

    mapping(uint256 => MarketItem) private idToMarketItem;//Each Marketitem created is assigned to an ID.

    event MarketItemCreated(
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price
    );

    function getMarketItem(uint256 marketItemId) public view returns (MarketItem memory) {
        return idToMarketItem[marketItemId];
    }


    function createMarketItem(address nftContract, uint256 tokenId, uint256 price) public payable nonReentrant {
        require(price > 0, "Price must be at least 1 wei");
        require(msg.value == listingPrice, "value must be equal to listing price.");//The price the market place charged for listing nfts.

        _itemIds.increment();
        uint256 itemId = _itemIds.current();


        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price
        );

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);//Tranfer the item to this contract address.

        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price
        );


    }


    function createMarketSale(
        address nftContract,
        uint itemId
    ) public payable nonReentrant{
        uint price = idToMarketItem[itemId].price;
        uint tokenId = idToMarketItem[itemId].tokenId;

        require(msg.value == price, "value must be equal or greater than the item price.");

        idToMarketItem[itemId].seller.transfer(msg.value);//Transfer the value to the seller

        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);//Transfer the item to the new owner

        idToMarketItem[itemId].owner = payable(msg.sender);
        _itemsSold.increment();
        payable(owner).transfer(listingPrice);//Transfer the listing price to the owner of the contract.
    }

    function fetchMarketItem() public view returns(MarketItem[] memory) {
        uint itemCount = _itemIds.current();//Total items
        uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);//Initializing an array with a specific length;

        for(uint i = 1; i < itemCount; i++){
            if(idToMarketItem[i].owner == address(0)){

                MarketItem storage currentItem  = idToMarketItem[i];
                items[currentIndex] = currentItem;

                currentIndex += 1;
            }
        }

        return items;
    }

    function fetchMyNFTs() public view returns (MarketItem[] memory){
        uint totalItemCount = _itemIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for(uint i = 1; i < totalItemCount; i++){
            if(idToMarketItem[i].owner == msg.sender){
                itemCount += 1;
            }
        }

MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint i = 1; i < totalItemCount; i++) {
      if (idToMarketItem[i].owner == msg.sender) {
        uint currentId = i;
        MarketItem storage currentItem = idToMarketItem[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }

    return items;
    }

}