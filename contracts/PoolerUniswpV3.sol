// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

// Deployments : 
//  Polygon : 
//      UniswapV3 : 0x0cface4e70a27ad9d6dc9178009b30b556cac8d1

import "./IPooler.sol";
import './TransferHelper.sol';


interface IQuoterV2 
{
    struct QuoteExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint24 fee;
        uint160 sqrtPriceLimitX96;
    }

    function quoteExactInputSingle(IQuoterV2.QuoteExactInputSingleParams memory params)
        external
        returns (
            uint256 amountOut,
            uint160 sqrtPriceX96After,
            uint32 initializedTicksCrossed,
            uint256 gasEstimate
        );
}


interface IRouterV3
{
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);


}

/* 
==============================================================================================
Uniswap V3 Pool pricer and swapper
==============================================================================================
*/




contract PoolerUniswpV3 is IPooler {
  
    function getName() external view returns (string memory)
    {
        return m_strName;
    }

    IQuoterV2 private m_oQuoter;
    IRouterV3 private m_oRouter;
    string      private m_strName;
    constructor( address oQuoter, address oRouter, string memory strName )
    {
        m_oQuoter = IQuoterV2(oQuoter);
        m_oRouter = IRouterV3(oRouter);
        m_strName = strName;
    }


    function getAmountOut( address oTokenIn, address oTokenOut, uint24 nFee, uint24 nTickSpace, uint256 nAmountInt)
        external returns (uint256)
    {
        IQuoterV2.QuoteExactInputSingleParams memory oParams;
        uint256 nAmountOut;        
        nTickSpace = 0;

        oParams.tokenIn = oTokenIn;
        oParams.tokenOut = oTokenOut;
        oParams.fee = nFee;
        oParams.sqrtPriceLimitX96 = 0;
        oParams.amountIn = nAmountInt;


        (nAmountOut,,,) = m_oQuoter.quoteExactInputSingle(oParams);        

        return nAmountOut;
    }

    function doSwap( address oTokenIn, address oTokenOut, uint24 nFee, uint24 nTickSpace, uint256 nAmountInt) 
        external returns (uint256)
    {
        IRouterV3.ExactInputSingleParams memory oParams;
        uint256 nAmountOut;        

        // Transfer the specified amount of tokenIn to this contract.
        TransferHelper.safeTransferFrom(oTokenIn, msg.sender, address(this), nAmountInt);

        // Approve the router to spend tokenIn.
        TransferHelper.safeApprove(oTokenIn, address(m_oRouter), nAmountInt);

        nTickSpace = 0;
        oParams.tokenIn = oTokenIn;
        oParams.tokenOut = oTokenOut;
        oParams.fee = nFee;
        oParams.recipient = address(msg.sender);
        oParams.amountIn = nAmountInt;
        oParams.amountOutMinimum = 0;
        oParams.sqrtPriceLimitX96 = 0;

        nAmountOut = m_oRouter.exactInputSingle(oParams);
        return nAmountOut;
    }

}
