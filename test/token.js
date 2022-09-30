const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("Token.sol", () => {
    let contract; 
    let contractFactory;
    let number = 34;
    let number2 = 34;

    beforeEach(async () => {
        contractFactory = await ethers.getContractFactory("Token");
        contract = await contractFactory.deploy();
    });

    describe("Correct functionality", () => {
        it("test store and retrieve", async () => {
            await contract.store(34);
            console.log(`set up 34 and return  ${await contract.retrieve()}`);
            expect(await contract.retrieve()).to.equal(34);
        });
    });
});