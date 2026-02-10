import { describe, it } from "node:test";
import assert from "node:assert";
import hre from "hardhat";

describe("CertifikatProgramskogRjesenja", async function () {
    it("Kompilacija uspješna", async function () {
        const artifact = await hre.artifacts.readArtifact("CertifikatProgramskogRjesenja");
        assert.ok(artifact.bytecode.length > 0, "Bytecode postoji");
        assert.ok(artifact.abi.length > 0, "ABI postoji");
    });

    it("ABI sadrži očekivane funkcije", async function () {
        const artifact = await hre.artifacts.readArtifact("CertifikatProgramskogRjesenja");
        const functionNames = artifact.abi
            .filter((item: any) => item.type === "function")
            .map((item: any) => item.name);

        // Prilagođeno tvojim stvarnim nazivima funkcija
        assert.ok(functionNames.includes("izdajCertifkat"), "izdajCertifkat postoji");
        assert.ok(functionNames.includes("opozivCertifikat"), "opozivCertifikat postoji");
        assert.ok(functionNames.includes("reaktivirajCertifikat"), "reaktivirajCertifikat postoji");
        assert.ok(functionNames.includes("provjeriValjanost"), "provjeriValjanost postoji");
        assert.ok(functionNames.includes("isAdmin"), "isAdmin postoji");
        assert.ok(functionNames.includes("isIssuer"), "isIssuer postoji");
        assert.ok(functionNames.includes("pauziraj"), "pauziraj postoji");
        assert.ok(functionNames.includes("odpauziraj"), "odpauziraj postoji");
    });

    it("ABI sadrži očekivane evente", async function () {
        const artifact = await hre.artifacts.readArtifact("CertifikatProgramskogRjesenja");
        const eventNames = artifact.abi
            .filter((item: any) => item.type === "event")
            .map((item: any) => item.name);

        console.log("Eventi u ugovoru:", eventNames);
        
        // Provjera eventa iz ERC721 i AccessControl
        assert.ok(eventNames.includes("Transfer"), "Transfer event postoji");
        assert.ok(eventNames.includes("Approval"), "Approval event postoji");
    });
});