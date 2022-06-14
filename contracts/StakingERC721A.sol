// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import './ERC721A.sol';
import './ERC721AQueryable.sol';

contract StakingERC721A is ERC721A, ERC721AQueryable {
    
    constructor() ERC721A("Carlito", "CD33") {}

    function mint(uint256 _quantity) external payable {
        _safeMint(msg.sender, _quantity);
    }
}
