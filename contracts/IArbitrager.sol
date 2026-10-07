// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;


import "./IPooler.sol";
import "./IPoolerManager.sol";
// Pooler manager
interface IArbitrager
{
    function getPoolerManager() external view returns (address);

    function setPoolerManager( address oManager ) external returns (bool);

    struct ArbitrageSwapParams {
        address tokenOut;
        uint256 pooler;
        uint24 fee;
        uint24 tickSpace;
    }

    function doSwaps( 
        uint256 nAmountIn, 
        address oTokenIn,
        ArbitrageSwapParams[] calldata aRoute
    ) external returns (uint256);

    function doArbitrage( 
        uint256 nAmountIn, 
        address oTokenIn,
        ArbitrageSwapParams[] calldata aRoute
    ) external returns (uint256);

    function doArbitrageFlashLoan( 
        uint256 nAmountIn, 
        address oTokenIn,
        ArbitrageSwapParams[] calldata aRoute
    ) external returns (uint256);
}
