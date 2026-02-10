# Pametni ugovor za certifikaciju programskih rješenja

NFT-based sustav za izdavanje i verifikaciju certifikata programskih proizvoda na Ethereum blockchainu.

## Opis projekta

Sustav omogućuje nadležnim državnim tijelima izdavanje digitalnih certifikata za verificirane programske proizvode. Certifikati su implementirani kao NFT tokeni (ERC-721) što osigurava nepromjenjivost, transparentnost i jednostavnu verifikaciju.

### Korisnici sustava

1. **Nadležno državno tijelo / uprava** — izdaje certifikate za programske proizvode koje prethodno certificira
2. **Programske kuće / proizvođači rješenja** — zaprimaju certifikate kao dokaz kvalitete svojih proizvoda
3. **Korisnik / kupac** — ima uvid u ugovor/ugovore, može provjeriti certificiranost proizvoda

### Funkcionalnosti

- Izdavanje NFT certifikata za verificirane programske proizvode
- Provjera valjanosti certifikata
- Opoziv certifikata
- Nepromjenjiva povijest svih izdanih certifikata

## Tehnologije

- **Solidity** — programski jezik za pametne ugovore
- **Ethereum** — blockchain platforma (testnet: Sepolia)
- **ERC-721** — NFT standard
- **OpenZeppelin** — sigurnosne biblioteke
- **Hardhat** — razvojno okruženje
- **Remix IDE** — web-based IDE za deployment
- **MetaMask** — crypto wallet
- **IPFS / Pinata** — decentralizirana pohrana metapodataka

## Struktura projekta
```
├── contracts/
│   └── CertifikatProgramskogRjesenja.sol   # Glavni ugovor
├── test/
│   └── CertifikatProgramskogRjesenja.test.ts
├── metadata/
│   └── primjer-certifikat.json             # Primjer IPFS metadataa
├── hardhat.config.ts
└── README.md
```

## Instalacija i lokalni razvoj
```bash
# Kloniraj repozitorij
git clone https://github.com/Dhlupic-Stingray6/BA-projekt.git
cd BA-projekt

# Instaliraj ovisnosti
npm install

# Kompajliraj ugovore
npx hardhat compile

# Pokreni testove
npx hardhat test
```

## Deployment na Sepolia testnet (Remix IDE)

### Preduvjeti

1. **MetaMask** browser ekstenzija
2. **Testni ETH** na Sepolia mreži (faucet: https://sepoliafaucet.com/)

### Koraci

1. Otvori [Remix IDE](https://remix.ethereum.org/)

2. U Remix-u kreiraj novu datoteku `CertifikatProgramskogRjesenja.sol` i kopiraj sadržaj ugovora ILI kloniraj git repozitorij

3. Otvori **Solidity Compiler** tab (lijeva strana):
   - Odaberi verziju `0.8.20`
   - Klikni **Compile**

4. Otvori **Deploy & Run Transactions** tab:
   - Environment: **Injected Provider - MetaMask**
   - MetaMask će tražiti spajanje — odobri
   - Provjeri da si na **Sepolia** mreži

5. Klikni **Deploy**
   - MetaMask će tražiti potvrdu transakcije
   - Plati gas fee (testni ETH)

6. Nakon deploymenta, ugovor se pojavljuje u **Deployed Contracts** sekciji

7. Kopiraj **adresu ugovora** — to je tvoj deployed contract!

### Verifikacija na Etherscan

1. Odi na [Sepolia Etherscan](https://sepolia.etherscan.io/)
2. Upiši adresu ugovora
3. Možeš vidjeti sve transakcije i stanje ugovora

## Funkcije ugovora

### Izdavanje certifikata
```solidity
function izdajCertifkat(
    address primatelj,
    string memory nazivProizvoda,
    string memory proizvodac,
    string memory verzija,
    string memory kategorija,
    uint256 datumIsteka,
    string memory metadataURI
) public onlyRole(ISSUER_ROLE) returns (uint256)
```

### Provjera valjanosti
```solidity
function provjeriValjanost(uint256 tokenId) public view returns (bool)
```

### Opoziv certifikata
```solidity
function opozivCertifikat(uint256 tokenId) public onlyRole(ISSUER_ROLE)
```

### Reaktivacija certifikata
```solidity
function reaktivirajCertifikat(uint256 tokenId) public onlyRole(ADMIN_ROLE)
```

### Pause / Unpause
```solidity
function pauziraj() public onlyRole(ADMIN_ROLE)
function odpauziraj() public onlyRole(ADMIN_ROLE)
```

## IPFS Metadata

Primjer strukture metapodataka za certifikat:
```json
{
    "name": "Certifikat - Naziv Proizvoda",
    "description": "Certifikat za verificirani programski proizvod",
    "image": "ipfs://...",
    "attributes": [
        { "trait_type": "Proizvođač", "value": "Naziv tvrtke" },
        { "trait_type": "Verzija", "value": "1.0" },
        { "trait_type": "Kategorija", "value": "Sigurnost" }
    ]
}
```

Za upload na IPFS koristi [Pinata](https://www.pinata.cloud/).

