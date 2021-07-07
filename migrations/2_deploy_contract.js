const Trust = artifacts.require("Trust.sol");

module.exports = async function(deployer, network, address){
    const [admin, _] = address;

    if(network === 'develop' || network === 'development'){
        await deployer.deploy(Trust, admin);
    }else{
        ADMIN = '';
        await deployer.deploy(Trust, ADMIN);
    }
}
