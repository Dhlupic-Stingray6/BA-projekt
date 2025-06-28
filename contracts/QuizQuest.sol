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
    


    struct PlayerStats {
        uint256 totalXp;
        uint256 currentStreak;
        uint256 longestStreak;
        uint256 perfectQuizzes;
        uint256 totalCorrectAnswers;
        uint256 lastActivityBlock;

        bool hasRareNFT;
        bool hasEpicNFT;
        bool hasLegendaryNFT;
    }
    struct NFTData {
        string rarity; // Rare, Epic, Legendary
        uint256 level; // 2,5 ili 10
        uint256 minedAt; 
        uint256 xpAtMint;
    }
    

    mapping(address => PlayerStats) public playerStats;
    mapping(uint256 => NFTData) public nftData;


    event XPAwarded(
        address indexed player,
        uint256 amount,
        string reason

    );

    event NFTMinted(
        address indexed player,
        uint256 tokenId, 
        string rarity, 
        uint256 level
    );

    event StreakUpdated(
        address indexed player,
        uint256 newStreak
    );

    event PerfectQuiz(
        address indexed player,
        uint256 bonusXP
    );


    constructor() ERC721("QuizQuest NFT", "QQNFT") Ownable(msg.sender){
        relayer = msg.sender;

        _nextTokenId = 1;
    }

}