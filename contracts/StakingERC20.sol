// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingERC20 is ERC20, Ownable {
    mapping(address => bool) admins;

    constructor() ERC20("Carlito20", "CD33") {}

    function mint(address _to, uint256 _quantity) external {
        require(admins[msg.sender], "Only admins");
        _mint(_to, _quantity);
    }

    function addAdmin(address _admin) external onlyOwner {
        admins[_admin] = true;
    }

    function removeAdmin(address _admin) external onlyOwner {
        admins[_admin] = false;
    }
}
