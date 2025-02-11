// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract IDTTokenTest is ERC20, Ownable {
    constructor() ERC20("IDT Token Test", "IDT") {
        _mint(msg.sender, 1000000000 * 10**18); // 1 Miliar IDT untuk pengujian
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}