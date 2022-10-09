pragma solidity ^0.8.13;

import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "openzeppelin-contracts/access/AccessControl.sol";
import "openzeppelin-contracts/token/ERC20/extensions/ERC20FlashMint.sol";
import 'openzeppelin-contracts/token/ERC20/IERC20.sol';
import 'openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol';

contract WrappedUSD is ERC20, AccessControl, ERC20FlashMint {
    using SafeERC20 for IERC20;

    error NoLimit(uint limit);

    bytes32 public constant GOVERNANCE_ROLE = keccak256("GOVERNANCE_ROLE");

    event Mint(address indexed to, address indexed coin, uint256 value);
    event Burn(address indexed from, address indexed coin, uint256 value);

    mapping(address => uint256) public coinLimits;

    constructor() ERC20("Wrapped USD", "WUSD") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(GOVERNANCE_ROLE, msg.sender);
    }

    function mint(address _coin, uint256 _amount) public {
        if(_amount > coinLimits[_coin]) {
            revert NoLimit(coinLimits[_coin]);
        }

        IERC20(_coin).safeTransferFrom(msg.sender, address(this), _amount);
        _mint(msg.sender, _amount);
        coinLimits[_coin] -= _amount;

        emit Mint(msg.sender, _coin, _amount);
    }

    function burn(address _coin, uint256 _amount) public {
        _burn(msg.sender, _amount);
        IERC20(_coin).safeTransfer(msg.sender, _amount);
        coinLimits[_coin] += _amount;

        emit Burn(msg.sender, _coin, _amount);
    }

    function addLimit(address _coin, uint256 _amount) public onlyRole(GOVERNANCE_ROLE) {
        coinLimits[_coin] += _amount;
    }

    function removeLimit(address _coin, uint256 _amount) public onlyRole(GOVERNANCE_ROLE) {
        coinLimits[_coin] -= _amount;
    }
}
