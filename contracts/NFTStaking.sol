// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./StakingERC20.sol";
import "./StakingERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTStaking is Ownable {
    StakingERC20 token;
    StakingERC721A nft;

    uint256 public totalStaked;
    uint256 public rewardsPerHour;

    struct Staking {
        address owner;
        uint24 tokenId;
        uint48 stakingStartTime;
    }

    mapping(uint256 => Staking) NFTsStaked;

    event Staked(address indexed owner, uint256 tokenId, uint256 timeStamp);
    event Unstaked(address indexed owner, uint256 tokenId, uint256 timeStamp);
    event Claimed(address indexed owner, uint256 amount);

    constructor(StakingERC20 _token, StakingERC721A _nft, uint256 _rewardsPerHour) {
        token = _token;
        nft = _nft;
        rewardsPerHour = _rewardsPerHour;
    }

    function setRewardsPerHour(uint256 _amount) external onlyOwner {
        rewardsPerHour = _amount;
    }

    function stake(uint256[] calldata tokenIds) external {
        uint256 tokenId;
        totalStaked += tokenIds.length;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            require(nft.ownerOf(tokenId) == msg.sender, "Not owner");
            require(
                NFTsStaked[tokenId].stakingStartTime == 0,
                "Already Staked"
            );
            nft.transferFrom(msg.sender, address(this), tokenId);
            emit Staked(msg.sender, tokenId, block.timestamp);
            NFTsStaked[tokenId] = Staking({
                owner: msg.sender,
                tokenId: uint24(tokenId),
                stakingStartTime: uint48(block.timestamp)
            });
        }
    }

    function unstake(uint256[] calldata tokenIds) external {
        _claim(msg.sender, tokenIds, true);
    }

    function claim(uint256[] calldata tokenIds) external {
        _claim(msg.sender, tokenIds, false);
    }

    function _unstake(address owner, uint256[] calldata tokenIds) internal {
        uint256 tokenId;
        totalStaked -= tokenIds.length;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            require(NFTsStaked[tokenId].owner == msg.sender, "Not Staked");
            delete NFTsStaked[tokenId];
            nft.transferFrom(address(this), owner, tokenId);
            emit Unstaked(msg.sender, tokenId, block.timestamp);
        }
    }

    function _claim(
        address owner,
        uint256[] calldata tokenIds,
        bool _unstakeBool
    ) internal {
        uint256 tokenId;
        uint256 earned;
        uint256 totalEarned;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            Staking memory thisStake = NFTsStaked[tokenId];
            require(thisStake.owner == owner, "Not owner");
            earned =
                ((block.timestamp - thisStake.stakingStartTime) *
                    rewardsPerHour) /
                3600;
            totalEarned += earned;

            NFTsStaked[tokenId].stakingStartTime = uint48(block.timestamp);
        }
        if (totalEarned > 0) {
            token.mint(owner, totalEarned);
        }
        if (_unstakeBool) {
            _unstake(owner, tokenIds);
        }
        emit Claimed(owner, totalEarned);
    }

    function getRewardAmount(address owner, uint256[] calldata tokenIds)
        external
        view
        returns (uint256)
    {
        uint256 tokenId;
        uint256 earned;
        uint256 totalEarned;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            Staking memory thisStake = NFTsStaked[tokenId];
            require(thisStake.owner == owner, "Not owner");
            earned =
                ((block.timestamp - thisStake.stakingStartTime) *
                    rewardsPerHour) /
                3600;
            totalEarned += earned;
        }
        return totalEarned;
    }

    function tokenStakedByOwner(address owner)
        external
        view
        returns (uint256[] memory)
    {
        uint256 totalSupply = nft.totalSupply();
        uint256[] memory tmpArr = new uint256[](totalSupply);
        uint256 index = 0;
        for (uint256 i = 0; i < totalSupply; i++) {
            if (NFTsStaked[i].owner == owner) {
                tmpArr[index] = i;
                index++;
            }
        }
        uint256[] memory tokens = new uint256[](index);
        for (uint256 i = 0; i < index; i++) {
            tokens[i] = tmpArr[i];
        }
        return tokens;
    }
}
