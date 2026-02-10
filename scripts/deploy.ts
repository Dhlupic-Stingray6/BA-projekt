import hre from "hardhat";

async function main() {
    console.log("Započinjem deployment...");

    const artifact = await hre.artifacts.readArtifact("CertifikatProgramskogRjesenja");
    
    console.log("Ugovor: CertifikatProgramskogRjesenja");
    console.log("Naziv: Certifikat Programskog Rjesenja");
    console.log("Simbol: CPR");
    console.log("");
    console.log("Za deployment na testnet (Sepolia):");
    console.log("1. Postavi SEPOLIA_RPC_URL i SEPOLIA_PRIVATE_KEY u .env");
    console.log("2. Pokreni: npx hardhat run scripts/deploy.ts --network sepolia");
    console.log("");
    console.log("ABI i bytecode dostupni u:");
    console.log("artifacts/contracts/CertifikatProgramskogRjesenja.sol/CertifikatProgramskogRjesenja.json");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });