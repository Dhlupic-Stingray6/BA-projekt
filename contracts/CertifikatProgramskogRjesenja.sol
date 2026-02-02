// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";


contract CertifikatProgramskogRjesenja is ERC721, AccessControl, Pausable {

    bytes32 public constant ADMIN_ROLE = DEFAULT_ADMIN_ROLE;
    bytes32 public constant ISSUER_ROLE = keccak256("ISSUER_ROLE");

    uint256 private _tokenIdCounter;

    //struktura

    struct Certfikat {
        string nazivProizvoda;
        string proizvodac;
        string verzija;
        string kategorija;
        uint256 datumIzdavanja;
        uint256 datumIsteka;
        bool aktivan;
    }

    mapping(uint256 => Certfikat) private _certifikati;

    constructor() ERC721("Certifikat Programskog Rjesenja", "CPR" ) {
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(ISSUER_ROLE, msg.sender);
    }

    // role managment 

    function addIssuer(address account) public onlyRole(ADMIN_ROLE) {
        _grantRole(ISSUER_ROLE, account);
    }

    function removeIssuer(address account) public onlyRole(ADMIN_ROLE) {
        _revokeRole(ISSUER_ROLE, account);
    }

    function isIssuer(address account) public view returns (bool) {
        return hasRole(ISSUER_ROLE, account);
    }

    function isAdmin(address account) public view returns (bool) {
        return hasRole(ADMIN_ROLE, account);
    }

    
    // pause (emergency stop)
     function pauziraj() public onlyRole(ADMIN_ROLE) {
        _pause();
    }

    function odpauziraj() public onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    // izdavanje cert
    function izdajCertifkat(
        address primatelj, 
        string memory nazivProizvoda, 
        string memory proizvodac, 
        string memory verzija, 
        string memory kategorija, 
        uint256 datumIsteka
    ) public onlyRole(ISSUER_ROLE) whenNotPaused returns (uint256) {

        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        _safeMint(primatelj, tokenId);

        _certifikati[tokenId] = Certfikat({
            nazivProizvoda: nazivProizvoda, 
            proizvodac: proizvodac,
            verzija: verzija, 
            kategorija: kategorija,
            datumIzdavanja: block.timestamp,
            datumIsteka: datumIsteka, 
            aktivan: true
        });

        return tokenId;
    }

    function dohvatiCertifikat(uint256 tokenId) public view returns (Certfikat memory) {
        require(_ownerOf(tokenId) != address(0), "Certifikat ne postoji");
        return _certifikati[tokenId];
    }

    function provjeriValjanost(uint256 tokenId) public view returns (bool) {
        require(_ownerOf(tokenId) != address(0), "Certifikat ne postoji");
        
        Certfikat memory cert = _certifikati[tokenId];
        
        // is active
        if (!cert.aktivan) {
            return false;
        }
        
        
        if (cert.datumIsteka != 0 && block.timestamp > cert.datumIsteka) {
            return false;
        }
        
        return true;
    }

    function dohvatiBrojCertifikata() public view returns (uint256) {
        return _tokenIdCounter;
    }


    function opozivCertifikat(uint256 tokenId) public onlyRole(ISSUER_ROLE) {
        require(_ownerOf(tokenId) != address(0), "Certifikat ne postoji");
        require(_certifikati[tokenId].aktivan, "Certifiat je vec opozvan");

        _certifikati[tokenId].aktivan = false;
    } 

    function reaktivirajCertifikat(uint256 tokenId) public onlyRole(ISSUER_ROLE) {
        require(_ownerOf(tokenId) != address(0), "Certifikat ne postoji");
        require(_certifikati[tokenId].aktivan, "Certifiat je vec aktivan");

        _certifikati[tokenId].aktivan = true;
    } 

    function supportsInterface(bytes4 interfaceId)
        public 
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}