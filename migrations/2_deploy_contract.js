const Trust = artifacts.require("Trust.sol");

module.exports = async function(deployer, network, address){
    const [admin, _] = address;

    if(network === 'alfajores' || network === 'development'){
        // await deployer.deploy(Trust, admin);
        await deployer.deploy(Trust);
        const trust = await Trust.deployed();
    }else{
        await deployer.deploy(Trust);
    }
}
