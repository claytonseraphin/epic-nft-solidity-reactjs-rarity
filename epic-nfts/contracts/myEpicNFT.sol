// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

// We need to import the helper functions from the contract that we copy/pasted.
import { Base64 } from "./libraries/Base64.sol";

// We inherit the contract we imported. This means we'll have access
// to the inherited contract's methods.
contract MyEpicNFT  is ERC721URIStorage{
    // Magic given to us by OpenZeppelin to help us keep track of tokenIds.
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // This is our SVG code. All we need to change is the word that's displayed. Everything else stays the same
    //So, we make a baseSvg variable here that all our NFTs can use.
    string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    // Thisis our SVG code. All we need to change is the word that's displayed. Eerything else stays the same.
    // So, we make a baseSvg variable here that all our NFTs can use.
    string[] firstWords = ["Sunday", "Coffee", "Pimp", "Rain", "Football", "Brunch", "Wergsy", "Wiz", "Church", "Chill"];
    string[] secondWords = ["Music", "Album", "Friday", "HipHop", "Playlist", "Replay", "Club", "Tidal", "Fire", "Aux"];
    string[] thirdWords = ["Thursday", "Work", "Meeting", "RoofTop", "HappyHour", "Eve", "Coding", "Dress", "Lunch", "Colleagues"];

    // Add event to retrieve the token id on the front-end.
    event NewEpicNFTMinted(address sender, uint256 tokenId);

    // We need to pass the name of our NFTs token and it's symbol.
    constructor() ERC721("SquareNFT", "SQUARE"){
        console.log("This is my first NFT contract");
    }

    // I create a function to randomly pick a word from each array.
    function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
        // I seed the random generator. More on this in the lesson.
        uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
        // Squash the # between 0 and the length of the array to avoid going out of bounds.
        rand = rand % firstWords.length;
        return firstWords[rand];
    }

    function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
        // I seed the random generator. More on this in the lesson.
        uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
        console.log("rand value is %s", rand);
        // Squash the # between 0 and the length of the array to avoid going out of bounds.
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
        // I seed the random generator. More on this in the lesson.
        uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
        // Squash the # between 0 and the length of the array to avoid going out of bounds.
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    // A function our user will hit to get their NFT.
    function makeAnEpicNFT() public {
        // Get the current tokenId, this starts at 0.
        uint256 newItemId = _tokenIds.current();

        // We go and randomly grab one word from each of the three arrays.
        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);
        string memory combineWord = string(abi.encodePacked(first, second, third));

        

        //I concatenate it all together, and then cl0se the <text> and <svg> tags.
        string memory finalSvg = string(abi.encodePacked(baseSvg, first, second, third, "</text></svg>"));

        // Get all the JSON metadata in place and base64 it.
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        combineWord,
                        '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        // Just like before, we prependdata:application/json;based64, to our data.
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );


        console.log("\n-----------------");
        console.log(finalSvg);
        console.log("\n-----------------");


        // Actually mint the NFT to the sender using msg.sender.
        _safeMint(msg.sender, newItemId);

        // Update your URI!!!
        _setTokenURI(newItemId, finalTokenUri);

        // Set the NFTs data.
        //_setTokenURI(newItemId, "data:application/json;base64,ewogICJuYW1lIjogIkxvcmQgb2YgdGhlIHJpbmdzIiwKICAiZGVzY3JpcHRpb24iOiAiQmxhY2sgU3F1YXJlIEJveCBTY3JlYW1pbmcgTE9UUiIsCiAgImltYWdlIjogImRhdGE6aW1hZ2Uvc3ZnK3htbDtiYXNlNjQsUEhOMlp5QjRiV3h1Y3owaWFIUjBjRG92TDNkM2R5NTNNeTV2Y21jdk1qQXdNQzl6ZG1jaUlIQnlaWE5sY25abFFYTndaV04wVW1GMGFXODlJbmhOYVc1WlRXbHVJRzFsWlhRaUlIWnBaWGRDYjNnOUlqQWdNQ0F6TlRBZ016VXdJajRLSUNBZ0lEeHpkSGxzWlQ0dVltRnpaU0I3SUdacGJHdzZJSGRvYVhSbE95Qm1iMjUwTFdaaGJXbHNlVG9nYzJWeWFXWTdJR1p2Ym5RdGMybDZaVG9nTVRSd2VEc2dmVHd2YzNSNWJHVStDaUFnSUNBOGNtVmpkQ0IzYVdSMGFEMGlNVEF3SlNJZ2FHVnBaMmgwUFNJeE1EQWxJaUJtYVd4c1BTSmliR0ZqYXlJZ0x6NEtJQ0FnSUR4MFpYaDBJSGc5SWpVd0pTSWdlVDBpTlRBbElpQmpiR0Z6Y3owaVltRnpaU0lnWkc5dGFXNWhiblF0WW1GelpXeHBibVU5SW0xcFpHUnNaU0lnZEdWNGRDMWhibU5vYjNJOUltMXBaR1JzWlNJK1RHOXlaRTltVkdobFVtbHVaM004TDNSbGVIUStDand2YzNablBnPT0iCn0=");
        //console.log("A new NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

        // Increment the counter for when the next NFT is minted.
        _tokenIds.increment();
        console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
        emit NewEpicNFTMinted(msg.sender, newItemId);
    }
}