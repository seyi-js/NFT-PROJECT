// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract SeyijsCollection is ERC721URIStorage{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    mapping(string => uint) hashes;
    constructor()  ERC721("SeyijsCollection", "UNA") {}

    function awardItem(address recipient, string memory hash, string memory metadata) public returns(uint){
        require(hashes[hash] != 1);

        hashes[hash] = 1;

        _tokenIds.increment();

        uint newItemId = _tokenIds.current();

        _mint(recipient, newItemId);

        _setTokenURI(newItemId,metadata);

        return newItemId;
    }
}