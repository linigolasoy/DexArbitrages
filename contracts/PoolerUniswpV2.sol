// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

// Deployments : 
//  Polygon : 
//      UniswapV2   : 0x4e31724eca6152df6922638b1f471590206363f9
//      QuickSwapV2 : 0x8653a2ce280ccf858d8f99bc8271535329cbad12

import "./IPooler.sol";
import './TransferHelper.sol';



interface IRouterV2
{

    function getAmountsOut(uint256 nAmountIn, address[] memory aPath) 
        external view returns (uint[] memory amounts);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint256[] memory amounts);

}

/* 
==============================================================================================
Uniswap V2 Pool pricer and swapper
==============================================================================================
*/




contract PoolerUniswpV2 is IPooler {
  /**
   * @dev Prints Hello World string
   */
    function findPool() external view returns (address)
    {
        return address(this);
    }

    IRouterV2 private m_oRouter;
    constructor( address oRouter )
    {
        m_oRouter = IRouterV2(oRouter);
    }


    function getAmountOut( address oTokenIn, address oTokenOut, uint24 nFee, uint24 nTickSpace, uint256 nAmountInt)
        external view returns (uint256)
    {
        address[] memory aPath;
        uint256[] memory aOut;

        nFee = 0;
        nTickSpace = 0;
        aPath[0] = oTokenIn;
        aPath[1] = oTokenOut;
        aOut = m_oRouter.getAmountsOut(nAmountInt, aPath);

        return aOut[1];
    }

    function doSwap( address oTokenIn, address oTokenOut, uint24 nFee, uint24 nTickSpace, uint256 nAmountInt) 
        external returns (uint256)
    {
        address[] memory aPath;
        uint256[] memory aOut;

        aPath[0] = oTokenIn;
        aPath[1] = oTokenOut;
        nFee = 0;
        nTickSpace = 0;

        // Transfer the specified amount of tokenIn to this contract.
        TransferHelper.safeTransferFrom(oTokenIn, msg.sender, address(this), nAmountInt);

        // Approve the router to spend tokenIn.
        TransferHelper.safeApprove(oTokenIn, address(m_oRouter), nAmountInt);

        aOut = m_oRouter.swapExactTokensForTokens(
            nAmountInt,
            0,
            aPath,
            address(msg.sender),
            0
        );


        return aOut[1];
    }

}
