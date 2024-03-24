// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

/**
 * @title BambaStake
 * @dev @aave/core-v3 Hosts core protocol V3 contracts that contains the logic for:
 * supply, borrow, liquidation, flashloan, a/s/v tokens, portal, pool configuration, oracles and interest rate strategies.
 * @docs https://docs.aave.com/developers/core-contracts/pool
 **/
import {IPool} from "@aave/core-v3/contracts/interfaces/IPool.sol";
import {IPriceOracle} from "@aave/core-v3/contracts/interfaces/IPriceOracle.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BambaStake is Ownable {
    
    mapping(address => uint256) collateralValueInWETH;
    event CollateralDeposit(address indexed sender, uint amount);
    event Withdrawal(address indexed receiver, uint amount);

    // https://docs.aave.com/developers/deployed-contracts/v3-testnet-addresses
    // Scroll Sepolia
    // https://github.com/bgd-labs/aave-address-book/blob/main/src/AaveV3ScrollSepolia.sol
    address public aavePoolProxy = 0x48914C788295b5db23aF2b5F0B3BE775C4eA9440;
    address constant USDC = 0x2C9678042D52B97D27f2bD2947F7111d93F3dD0D;

    /**
     * @dev Deposits collateral into the contract.
     * @param _amount The amount of the asset being deposited.
     * Requirements:
     * - The amount must be greater than zero.
     * - The asset must be approved for transfer by the contract.
     * - The collateral is supplied to the Aave pool.
     * Emits a `CollateralDeposit` event.
     */
    function depositCollateral(uint256 _amount)
        external
    {

        if (_amount == 0) {
            revert();
        }
        IERC20(USDC).transferFrom(msg.sender, address(this), _amount);

        IERC20(USDC).approve(address(aavePoolProxy), _amount);

        IPool(aavePoolProxy).supply(USDC, _amount, address(this), 0);
        collateralValueInWETH[msg.sender] += _amount;
        emit CollateralDeposit(msg.sender, _amount);
    }

    function withdrawCollateral(address _sender, uint _amount) public onlyOwner {
        
        IPool(aavePoolProxy).withdraw(USDC, _amount, _sender);
        emit Withdrawal(_sender, _amount);
    }

}
