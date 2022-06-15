const hre = require('hardhat')

async function main() {
  const StakingERC20 = await hre.ethers.getContractFactory('StakingERC20')
  const stakingERC20 = await StakingERC20.deploy()
  await stakingERC20.deployed()

  const StakingERC721A = await hre.ethers.getContractFactory('StakingERC721A')
  const stakingERC721A = await StakingERC721A.deploy()
  await stakingERC721A.deployed()

  const NFTStaking = await hre.ethers.getContractFactory('NFTStaking')
  const nftStaking = await NFTStaking.deploy(
    stakingERC20.address,
    stakingERC721A.address,
    10000,
  )
  await nftStaking.deployed()
  console.log('StakingERC20 deployed to:', stakingERC20.address)
  console.log('StakingERC721A deployed to:', stakingERC721A.address)
  console.log('NFTStaking deployed to:', nftStaking.address)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
