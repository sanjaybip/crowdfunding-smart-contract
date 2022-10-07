const { time, loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");

describe("Lock", function () {
    async function deployCrowdFundingContractFixture() {
        const WEEK_IN_SECS = 7 * 24 * 60 * 60;
        const AMOUNT = hre.ethers.utils.parseEther("0.01");
        const fundingCID = ""; //Need to upload data

        // Contracts are deployed using the first signer/account by default
        const [owner, signer2, sgner3] = await ethers.getSigners();

        const CrowdFundingContract = await hre.ethers.getContractFactory("CrowdFundingContract");
        const crowdFundingContract = await CrowdFundingContract.deploy();
        await crowdFundingContract.deployed();

        const CrowdSourcingFactory = await hre.ethers.getContractFactory("CrowdSourcingFactory");
        const crowdSourcingFactory = await CrowdSourcingFactory.deploy(
            crowdFundingContract.address
        );
        await crowdSourcingFactory.deployed();

        return { crowdFundingContract, crowdSourcingFactory, owner, signer2, sgner3 };
    }
    describe("Deployment", function () {
        //TODO: Finish testing
    });
});
