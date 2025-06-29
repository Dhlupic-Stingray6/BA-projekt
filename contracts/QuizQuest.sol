// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


// Import OpenZeppelin contracts
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract QuizQuest is ERC721, Ownable{
   
    


    uint256 private _nextTokenId; // brojač

    address public relayer;  // adresa koja može slati transakcije u ime usera


    // konstante
    // =======================================================================
    uint256 public constant RARE_NFT_THRESHOLD = 50;
    uint256 public constant EPIC_NFT_THRESHOLD = 50;
    uint256 public constant LEGENDARY_NFT_THRESHOLD = 50;

    uint256 public constant XP_PER_CORRECT_ANSWER = 2;
    uint256 public constant STREAK_BONUS_XP = 1;        
    uint256 public constant PERFECT_QUIZ_BONUS_XP = 5;
    

    // konstruktor
    constructor() ERC721("QuizQuest NFT", "QQNFT") Ownable(msg.sender){
        relayer = msg.sender;

        _nextTokenId = 1;
    }

    // strukture podataka
    struct PlayerStats {
        uint256 totalXP;
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
        uint256 mintedAt; 
        uint256 xpAtMint;
    }
    
    // mappings (ključ-vrijednost)
    mapping(address => PlayerStats) public playerStats;
    mapping(uint256 => NFTData) public nftData;
    mapping(uint256 => string) private _tokenURIs;
   
    //events 
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

    event RelayerUpdated(
        address oldRelayer,
        address newRelayer
    );

    // modifikatori
    modifier onlyRelayer() {
        require(
            msg.sender == relayer,
            "Only relayer can call this function"
        );
        _;
    }
    modifier onlyOwnerOrRelayer() {
        require(
            msg.sender == owner() || msg.sender == relayer,
            "Not authorized"
        );
        _;
    }


    //funkcije


    function setRelayer(address _relayer) external onlyOwner {
        require(_relayer != address(0), "Invalid relayer address");
        address oldRelayer = relayer;
        relayer = _relayer;
        emit RelayerUpdated(oldRelayer, _relayer);
    }
    

     function awardXP(
        address player,
        uint256 correctAnswers,
        uint256 totalQuestions,
        bool streakContinues
    ) external onlyRelayer {
        require(player != address(0), "Invalid player address");
        require(correctAnswers <= totalQuestions, "Invalid answers count");
        require(totalQuestions > 0, "Quiz must have questions");
        
        PlayerStats storage stats = playerStats[player];
        
        // Osnovni XP
        uint256 baseXP = correctAnswers * XP_PER_CORRECT_ANSWER;
        uint256 totalXPAwarded = baseXP;
        
        if (baseXP > 0) {
            emit XPAwarded(player, baseXP, "correct_answers");
        }
        
        // Streak logika
        if (streakContinues) {
            stats.currentStreak++;
            if (stats.currentStreak > stats.longestStreak) {
                stats.longestStreak = stats.currentStreak;
            }
            
            if (stats.currentStreak >= 5) {
                totalXPAwarded += STREAK_BONUS_XP;
                emit XPAwarded(player, STREAK_BONUS_XP, "streak_bonus");
            }
            
            emit StreakUpdated(player, stats.currentStreak);
        } else {
            stats.currentStreak = 0;
            emit StreakUpdated(player, 0);
        }
        
        // Perfect quiz bonus
        bool isPerfectQuiz = correctAnswers == totalQuestions && totalQuestions > 0;
        if (isPerfectQuiz) {
            totalXPAwarded += PERFECT_QUIZ_BONUS_XP;
            stats.perfectQuizzes++;
            emit PerfectQuiz(player, PERFECT_QUIZ_BONUS_XP);
            emit XPAwarded(player, PERFECT_QUIZ_BONUS_XP, "perfect_quiz");
        }
        
        // Ažuriraj statistike
        stats.totalXP += totalXPAwarded;
        stats.totalCorrectAnswers += correctAnswers;
        stats.lastActivityBlock = block.number;
        
        // Provjeri NFT mintanje
        _checkAndMintNFT(player);
    }
    
    // NFT FUNKCIONALNOSTI
    function _checkAndMintNFT(address player) internal {
        PlayerStats storage stats = playerStats[player];
        
        if (stats.totalXP >= LEGENDARY_NFT_THRESHOLD && !stats.hasLegendaryNFT) {
            _mintNFT(player, "legendary", 10);
            stats.hasLegendaryNFT = true;
        }
        else if (stats.totalXP >= EPIC_NFT_THRESHOLD && !stats.hasEpicNFT) {
            _mintNFT(player, "rare", 5);
            stats.hasEpicNFT = true;
        }
        else if (stats.totalXP >= RARE_NFT_THRESHOLD && !stats.hasRareNFT) {
            _mintNFT(player, "basic", 2);
            stats.hasRareNFT = true;
        }
    }
    
    function _mintNFT(address to, string memory rarity, uint256 level) internal {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        
        nftData[tokenId] = NFTData({
            rarity: rarity,
            level: level,
            mintedAt: block.timestamp,
            xpAtMint: playerStats[to].totalXP
        });
        
        _tokenURIs[tokenId] = _generateTokenURI(tokenId, rarity, level);
        
        emit NFTMinted(to, tokenId, rarity, level);
    }
    
    
    // TOKEN URI MANAGEMENT
 
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireOwned(tokenId);
        return _tokenURIs[tokenId];
    }
    
    function setTokenURI(uint256 tokenId, string memory _tokenURI) external onlyOwner {
        _requireOwned(tokenId);
        _tokenURIs[tokenId] = _tokenURI;
    }
    
    function _generateTokenURI(
        uint256 tokenId,
        string memory rarity,
        uint256 level
    ) internal pure returns (string memory) {
        return string(abi.encodePacked(
            "data:application/json,{",
            '"name":"QuizQuest NFT #', _toString(tokenId), '",',
            '"description":"QuizQuest achievement NFT",',
            '"attributes":[',
                '{"trait_type":"Rarity","value":"', rarity, '"},',
                '{"trait_type":"Level","value":', _toString(level), '}',
            ']}'
        ));
    }
    
    // VIEW FUNKCIJE
  
    function getPlayerStats(address player) external view returns (
        uint256 totalXP,
        uint256 currentStreak,
        uint256 longestStreak,
        uint256 perfectQuizzes,
        uint256 totalCorrectAnswers,
        bool hasRareNFT,
        bool hasEpicNFT,
        bool hasLegendaryNFT
    ) {
        PlayerStats memory stats = playerStats[player];
        return (
            stats.totalXP,
            stats.currentStreak,
            stats.longestStreak,
            stats.perfectQuizzes,
            stats.totalCorrectAnswers,
            stats.hasRareNFT,
            stats.hasEpicNFT,
            stats.hasLegendaryNFT
        );
    }
    
    function canMintRarity(address player, string memory rarity) public view returns (bool) {
        PlayerStats memory stats = playerStats[player];
        
        if (keccak256(bytes(rarity)) == keccak256(bytes("legendary"))) {
            return stats.totalXP >= LEGENDARY_NFT_THRESHOLD && !stats.hasLegendaryNFT;
        } else if (keccak256(bytes(rarity)) == keccak256(bytes("rare"))) {
            return stats.totalXP >= EPIC_NFT_THRESHOLD &&  !stats.hasEpicNFT;
        } else if (keccak256(bytes(rarity)) == keccak256(bytes("basic"))) {
            return stats.totalXP >= RARE_NFT_THRESHOLD&& !stats.hasRareNFT;
        }
        
        return false;
    }
    
    function getNextTokenId() public view returns (uint256) {
        return _nextTokenId;
    }
    
    function totalSupply() public view returns (uint256) {
        return _nextTokenId - 1;
    }
    
    // HELPER FUNKCIJE
    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
    
    // EMERGENCY FUNKCIJE
    function manualMint(
        address to,
        string memory rarity,
        uint256 level
    ) external onlyOwner {
        require(to != address(0), "Invalid address");
        _mintNFT(to, rarity, level);
    }
    
    function resetPlayerStreak(address player) external onlyOwner {
        playerStats[player].currentStreak = 0;
        emit StreakUpdated(player, 0);
    }
    

}