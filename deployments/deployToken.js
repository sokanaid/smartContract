//require('hardhat')

const main = async () => {
    const [deployer] = await ethers.getSigners();
    console.log(`Address deploying the contract --> ${deployer.address}`);
    const tokenFactory = await ethers.getContractFactory("Token");
    const contract = await tokenFactory.deploy();

    console.log(`Token Contract address --> ${contract.address}`);
}

main().then(()=> process.exit(0)).catch((error)=>{ console.error(error); process.exit(1);} );