// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";  // Step 1
import "@openzeppelin/contracts/utils/Counters.sol"; // Step 2

contract MyNFT is ERC721URIStorage { // Step 1
    using Counters for Counters.Counter; // Step 2
    Counters.Counter private _tokenIds; // Step 2

    address public owner; // Step 5
    mapping(address => bool) private _onWhitelist; // Step 4, default to False
    uint256 public mintPrice = 1 ether / 1000; // Step 6

    constructor(address[] memory whitelist) ERC721("MyNFT", "MNFT") { //ERC721(token name, token symbol)
        owner = msg.sender; // Step 5
        _onWhitelist[owner] = true; // Step 5 (optional)
        for (uint256 i=0; i < whitelist.length; i++) { // Step 4
            _onWhitelist[whitelist[i]] = true;
        }
    }

    modifier onWhitelist { // Step 4
        require(_onWhitelist[msg.sender], "not on whitelist");
        _; // the rest of the original function will run here
    }

    modifier isOwner { // Step 5
        require(msg.sender==owner, "not contract owner");
        _;
    }

    function mint(address to, string memory tokenURI) // Step 3
        public onWhitelist // Step 4
        payable // Step 6
        returns (uint256)
    {
        require(msg.value==mintPrice, "wrong mint price"); // Step 6
        _tokenIds.increment(); // Step 3

        uint256 newTokenId = _tokenIds.current(); // Step 3
        _mint(to, newTokenId); // Step 3
        _setTokenURI(newTokenId, tokenURI); // Step 3

        return newTokenId; // Step 3
    }

    function addWhitelist(address[] memory addresses) // Step 4 (optional, if skipped, swap step 5 and 6)
        public isOwner // Step 5
    {
        for (uint256 i=0; i < addresses.length; i++) {
            _onWhitelist[addresses[i]] = true;
        }
    }

    function removeWhitelist(address[] memory addresses) // Step 4 (optional, if skipped, swap step 5 and 6)
        public isOwner // Step 5
    {
        for (uint256 i=0; i < addresses.length; i++) {
            _onWhitelist[addresses[i]] = false;
        }
    }

    function changeOwner(address newOwner) // Step 5 (optional)
        public isOwner
    {
        owner = newOwner;
    }

    function withdraw() // Step 6
        public isOwner
    {
        payable(owner).transfer(address(this).balance);
    }
}