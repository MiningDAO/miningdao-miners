module.exports = async ({ ethers, deployments }) => {
    const { deployer, admin, custodian } = await ethers.getNamedSigners();
    const { deploy } = deployments;

    await deploy('ERC1155Facet', {
        from: deployer.address,
        log: true
    });

    await deploy('MiningPoolFacet', {
        from: deployer.address,
        log: true
    });

    await deploy('DeMineNFT', {
        from: deployer.address,
        log: true
    });

    await deploy('DeMineNFTV2', {
        from: deployer.address,
        log: true
    });
};

module.exports.tags = ['DeMineNFT', 'DeMine'];