pragma solidity ^0.8.13;

import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "openzeppelin-contracts/access/AccessControl.sol";
import "openzeppelin-contracts/token/ERC20/extensions/ERC20FlashMint.sol";
import 'openzeppelin-contracts/token/ERC20/IERC20.sol';
import 'openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol';

contract WrappedUSD is ERC20, AccessControl, ERC20FlashMint {
    using SafeERC20 for IERC20;

    event Mint(address indexed to, address indexed coin, uint256 value);
    event Burn(address indexed from, address indexed coin, uint256 value);

    constructor() ERC20("Wrapped USD", "WUSD") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mint(address _coin, uint256 _amountIn) public {
        IERC20(_coin).safeTransferFrom(msg.sender, address(this), _amountIn);
        _mint(msg.sender, _amountIn);
        emit Mint(msg.sender, _coin, _amountIn);
    }

    function burn(address _coin, uint256 _amountIn) public {
        _burn(msg.sender, _amountIn);
        IERC20(_coin).safeTransfer(msg.sender, _amountIn);
        emit Burn(msg.sender, _coin, _amountIn);
    }
}
