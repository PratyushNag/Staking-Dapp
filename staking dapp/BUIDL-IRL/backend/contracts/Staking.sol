// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

import "./BuidlToken.sol";

contract Staking is ERC721Holder {
    /// @notice NFT contract
    IERC721 public MintProductNFT;

    /// @notice Token contract
    BuidlToken public buidlToken;

    /// @dev owner of the contract
    address owner;

    /// @notice Emission rate per second
    uint256 public EMISSION_RATE = ((10 ** 18) / (uint256(1 days)));

    /// @notice Staking start time
    mapping(address => uint256) public tokenStakedAt;

    /// @notice Token ID of the staked NFT
    mapping(address => uint256) public stakeTokenId;

    /// @notice Constructor
    /// @param nft  NFT contract address
    /// @param token Token contract address
    constructor(address nft, address token) {
        MintProductNFT = IERC721(nft);
        buidlToken = BuidlToken(token);
    }

    /// Function to stake the NFT
    /// This will transfer the NFT to the contract, and start the staking timer for the user.
    /// @param tokenId Token ID of the NFT to stake
    function stakeNFT(uint256 tokenId) external {
        require(MintProductNFT.ownerOf(tokenId) == msg.sender, "ERR:NO");
        MintProductNFT.safeTransferFrom(msg.sender, address(this), tokenId);
        tokenStakedAt[msg.sender] = block.timestamp;
        stakeTokenId[msg.sender] = tokenId;
    }

    /// Function to calculate the reward for the staker
    /// @param staker Address of the staker
    function calculateReward(address staker) public view returns (uint256) {
        require(tokenStakedAt[staker] != 0, "ERR:NS");
        uint256 time = block.timestamp - tokenStakedAt[staker];
        return (time * EMISSION_RATE);
    }

    /// Function to unstake the NFT
    /// This will transfer the NFT back to the user, and mint the reward for the user.
    /// @param tokenId Token ID of the NFT to unstake
    function unStakeNFT(uint256 tokenId) external {
        require(stakeTokenId[msg.sender] == tokenId, "ERR:NY");
        uint256 rewardAmount = calculateReward(msg.sender);

        MintProductNFT.safeTransferFrom(address(this), msg.sender, tokenId);

        buidlToken.mintToken(msg.sender, rewardAmount);

        delete stakeTokenId[msg.sender];
        delete tokenStakedAt[msg.sender];
    }
}
