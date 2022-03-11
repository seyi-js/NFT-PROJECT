// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract NFT is ERC721URIStorage{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address marketPlaceAddress;
    address owner;//Contract owner address

    constructor() ERC721("SEYIJS DIGITAL MARKETPLACE", "SYJ") {
        owner = msg.sender;
    }

    function setMarketPlaceAddress(address _address) public {
        require(msg.sender == owner, "Only the owner of the contract is allowed to change this.");

        marketPlaceAddress = _address;
    }

    function createToken(string memory tokenURI) public returns(uint) {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();//The token id that was just created.

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId,tokenURI);
        setApprovalForAll(marketPlaceAddress, true);

        return newItemId;
    }

}

