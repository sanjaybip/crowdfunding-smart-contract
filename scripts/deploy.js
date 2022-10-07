const hre = require("hardhat");

async function main() {
    const CrowdFundingContract = await hre.ethers.getContractFactory("CrowdFundingContract");
    const crowdFundingContract = await CrowdFundingContract.deploy();
    await crowdFundingContract.deployed();
    console.log(
        `Deployed the implementation contract with address : ${crowdFundingContract.address}`
    );
    console.log(`------------Deploying Factory Contract Now----------------`);

    const CrowdSourcingFactory = await hre.ethers.getContractFactory("CrowdSourcingFactory");
    const crowdSourcingFactory = await CrowdSourcingFactory.deploy(crowdFundingContract.address);
    await crowdSourcingFactory.deployed();
    console.log(`Deployed the Factory contract with address : ${crowdSourcingFactory.address}`);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
