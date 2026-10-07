// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

// Deployments : 
//  Polygon : 
//      UniswapV2   : 0x625cc34189ad8007aaa3b184edd3bc3b46fd74d0
//      QuickSwapV2 : 0x45c3885d3639b5b04c7302d1f9ae34d5e918d229

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

    function getName() external view returns (string memory)
    {
        return m_strName;
    }

    IRouterV2 private m_oRouter;
    string      private m_strName;
    constructor( address oRouter, string memory strName )
    {
        m_oRouter = IRouterV2(oRouter);
        m_strName = strName;
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
        address[] memory aPath = new address[](2); //  = [oTokenIn, oTokenOut];
        uint256[] memory aOut;
        uint256 deadline = block.timestamp + 1800;

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
            deadline
        );


        return (aOut.length > 1 ? aOut[1] : 0);
    }

}
