// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
}

contract Disperse is Ownable {
    using SafeMath for uint256;

    event ALL_TRANSFERRED(uint256 block, uint256 value);

    function disperseEther(
        address[] calldata recipients,
        uint256[] calldata values
    ) external payable {
        for (uint256 i = 0; i < recipients.length; i++)
            payable(recipients[i]).transfer(values[i]);
        uint256 balance = address(this).balance;
        if (balance > 0) payable(msg.sender).transfer(balance);
    }

    function disperseToken(
        IERC20 token,
        address[] calldata recipients,
        uint256[] calldata values
    ) external {
        uint256 total = 0;
        for (uint256 i = 0; i < recipients.length; i++) {
            total = total.add(values[i]);
            require(
                token.transferFrom(msg.sender, recipients[i], values[i]),
                "Token trasnfer failed"
            );
        }

        emit ALL_TRANSFERRED(block.number, total);
        total = 0;
    }

    function withdrawToken(IERC20 token) external onlyOwner {
        require(
            token.transfer(owner(), token.balanceOf(address(this))),
            "withdraw failed"
        );
    }

    function getTotal(address[] calldata recipients, uint256[] calldata values)
        external
        pure
        returns (uint256 disperseValue)
    {
        uint256 total = 0;
        for (uint256 i = 0; i < recipients.length; i++) {
            total = total.add(values[i]);
        }
        return total;
    }
}
