// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


// Import OpenZeppelin contracts
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract QuizQuest is ERC721, Ownable{
   

    uint256 private _nextTokenId;

    address public relayer;


    uint256 public constant RARE_NFT_THRESHOLD = 50;
    uint256 public constant EPIC_NFT_THRESHOLD = 50;
    uint256 public constant LEGENDARY_NFT_THRESHOLD = 50;

    uint256 public constant XP_PER_CORRECT_ANSWER = 2;
    uint256 public constant STREAK_BONUS_XP = 1;        
    uint256 public constant PERFECT_QUIZ_BONUS_XP = 5;
    

    


    constructor() ERC721("QuizQuest NFT", "QQNFT") Ownable(msg.sender){
        relayer = msg.sender;

        _nextTokenId = 1;
    }

}