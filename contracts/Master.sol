pragma solidity >0.6.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PaymentToken is ERC20 {
    constructor() ERC20("PaymentToken", "PTM") {
        _mint(msg.sender, 1000000 * 10**18);
    }
}
