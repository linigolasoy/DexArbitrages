// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;


import './IERC20.sol';
import "./IPooler.sol";
import "./IPoolerManager.sol";
import "./IArbitrager.sol";
import './TransferHelper.sol';

// Deployments :
//      Polygon :   0x6A9c19Ff046B578356b2C696Cd8565fe9dD1205f    

// Pooler manager

contract ArbitragerFlash is IArbitrager
{

    IPoolerManager private m_oPoolerManager;
    address private _owner;


    /////////////////////////////////////////////////////////////////////// 
    // Constructor
    // @param oPoolerManager
    constructor( address oPoolerManager )
    {
        m_oPoolerManager = IPoolerManager(oPoolerManager);
        _owner = msg.sender;
    }

    /////////////////////////////////////////////////////////////////////// 
    /// Getter of pool manager
    function getPoolerManager() external view returns (address)
    {
        return address(m_oPoolerManager);
    }

    /////////////////////////////////////////////////////////////////////// 
    // Setter of pool manager
    // @param oManager 
    function setPoolerManager( address oManager ) external returns (bool)
    {
        require(msg.sender == _owner);
        m_oPoolerManager = IPoolerManager(oManager);
        return true;
    }


    /////////////////////////////////////////////////////////////////////// 
    /// Swaps internal, without any transfer or check
    /// @param nAmountIn    - Amount of token In
    /// @param oTokenIn     - Address of token in
    /// @param aRoute       - Swap route
    /// @return             - Token  Out
    /// @return             - Amount out
    // Swaps internal, without any transfer or check
    function doSwapsInternal( 
        uint256 nAmountIn, 
        address oTokenIn,
        ArbitrageSwapParams[] calldata aRoute
    ) public returns (address, uint256)
    {
        address oTokenAct = oTokenIn;
        uint256 nAmountActual = nAmountIn;
        for( uint i = 0; i < aRoute.length; i++ )
        {
            IPooler oPooler = m_oPoolerManager.getPooler(aRoute[i].pooler);
            IERC20 oErcTokenAct = IERC20(oTokenAct);

            oErcTokenAct.approve(address(oPooler), nAmountActual);
            // TransferHelper.safeApprove(oActiveIn, address(oPoolerIn), nAmountActual);
            uint256 nAmountOut = oPooler.doSwap( 
                oTokenAct, 
                aRoute[i].tokenOut, 
                aRoute[i].fee, 
                aRoute[i].tickSpace, 
                nAmountActual
            );
            // oActiveIn = oRouteIn.tokenOut;
            nAmountActual = nAmountOut;


            oTokenAct = aRoute[i].tokenOut;
        }
        return (oTokenAct, 0);
    }


    
    /////////////////////////////////////////////////////////////////////// 
    /// Swaps without any flash loan, any route ok
    /// @param nAmountIn    - Amount of token In
    /// @param oTokenIn     - Address of token in
    /// @param aRoute       - Swap route
    /// @return             - Amount out
    function doSwaps( 
        uint256 nAmountIn, 
        address oTokenIn,
        ArbitrageSwapParams[] calldata aRoute
    ) external returns (uint256)
    {
        // Transfer to this contract amount in
        IERC20 oTokenErcIn = IERC20(oTokenIn);
        TransferHelper.safeTransferFrom(oTokenIn, msg.sender, address(this), nAmountIn);

        // Perform swap route
        (address oTokenOut, uint256 nAmountOut) = doSwapsInternal(
            nAmountIn,
            oTokenIn,
            aRoute
        );

        // IF balance of token out, transfer
        IERC20 oTokenErcOut = IERC20(oTokenOut);
        uint256 nBalanceOut = oTokenErcOut.balanceOf(address(this));
        if( nBalanceOut > 0 )
        {
            oTokenErcOut.transfer(msg.sender, nBalanceOut);
            // TransferHelper.safeTransferFrom(oTokenOut, address(this),  msg.sender, nBalanceOut);
        }

        // IF balance of token in, transfer
        uint256 nBalanceIn = oTokenErcIn.balanceOf(address(this));
        if( nBalanceIn > 0 )
        {
            oTokenErcIn.transfer(msg.sender, nBalanceIn);
            // TransferHelper.safeTransferFrom(oTokenIn, address(this),  msg.sender, nBalanceIn);
        }

        return nAmountOut;
    }

    /////////////////////////////////////////////////////////////////////// 
    /// Arbitrage swapping, requires result to be positive
    /// @param nAmountIn    - Amount of token In
    /// @param oTokenIn     - Address of token in
    /// @param aRoute       - Swap route
    /// @return             - Amount out
    function doArbitrage( 
        uint256 nAmountIn, 
        address oTokenIn,
        ArbitrageSwapParams[] calldata aRoute
    ) external returns (uint256)
    {
        // Transfer to this contract amount in
        IERC20 oTokenErcIn = IERC20(oTokenIn);
        TransferHelper.safeTransferFrom(oTokenIn, msg.sender, address(this), nAmountIn);

        // Check output address
        address oTokenOutAddress = aRoute[aRoute.length-1].tokenOut;
        require(oTokenOutAddress == oTokenIn, "token output different from input");

        // Perform swap route
        (address oTokenOut, uint256 nAmountOut) = doSwapsInternal(
            nAmountIn,
            oTokenIn,
            aRoute
        );

        // Check amount out greater than amount in
        require(nAmountOut >= nAmountIn, "Amount out less than in, not arbitrage");
        // IF balance of token out, transfer
        IERC20 oTokenErcOut = IERC20(oTokenOut);
        uint256 nBalanceOut = oTokenErcOut.balanceOf(address(this));
        if( nBalanceOut > 0 )
        {
            oTokenErcOut.transfer(msg.sender, nBalanceOut);
            // TransferHelper.safeTransferFrom(oTokenOut, address(this),  msg.sender, nBalanceOut);
        }

        // IF balance of token in, transfer
        uint256 nBalanceIn = oTokenErcIn.balanceOf(address(this));
        if( nBalanceIn > 0 )
        {
            oTokenErcIn.transfer(msg.sender, nBalanceIn);
            // TransferHelper.safeTransferFrom(oTokenIn, address(this),  msg.sender, nBalanceIn);
        }

        return nAmountOut;
    }

    function doArbitrageFlashLoan( 
        uint256 nAmountIn, 
        address oTokenIn,
        ArbitrageSwapParams[] calldata aRoute
    ) external returns (uint256)
    {
        return 0;
    }



    function doArbitrageSimple( 
        uint256 nAmountIn, 
        address oTokenIn,
        ArbitrageSwapParams calldata oRouteIn,
        ArbitrageSwapParams calldata oRouteOut
    ) external returns (uint256)
    {
        TransferHelper.safeTransferFrom(oTokenIn, msg.sender, address(this), nAmountIn);

        // Pooler in swap
        IERC20 oTokenErcIn = IERC20(oTokenIn);
        IERC20 oTokenErcOut = IERC20(oRouteIn.tokenOut);

        address oActiveIn = oTokenIn;
        uint256 nAmountActual = nAmountIn;

        IPooler oPoolerIn = m_oPoolerManager.getPooler(oRouteIn.pooler);
        if( nAmountActual > 0 )
        {
            TransferHelper.safeApprove(oActiveIn, address(oPoolerIn), nAmountActual);
            uint256 nAmountOut = oPoolerIn.doSwap( oActiveIn, oRouteIn.tokenOut, oRouteIn.fee, oRouteIn.tickSpace, nAmountActual);
            oActiveIn = oRouteIn.tokenOut;
            nAmountActual = oTokenErcOut.balanceOf(address(this));
        }


        IPooler oPoolerOut = m_oPoolerManager.getPooler(oRouteOut.pooler);
        if( nAmountActual > 0 )
        {
            TransferHelper.safeApprove(oActiveIn, address(oPoolerOut), nAmountActual);
            uint256 nAmountOut = oPoolerOut.doSwap( oActiveIn, oRouteOut.tokenOut, oRouteOut.fee, oRouteOut.tickSpace, nAmountActual);
            oActiveIn = oRouteOut.tokenOut;
            nAmountActual = nAmountOut;
        }


        /*
        address oTokenOut = aRoute[i].tokenOut;
            uint256 nPooler = aRoute[i].pooler;
            address oPoolerAddress = m_oPoolerManager.getPoolerAddress(nPooler);
            IPooler oPooler = IPooler(oPoolerAddress);
            uint24 nFee = aRoute[i].fee;
            uint24 nTick = aRoute[i].tickSpace;

            if( nAmountActual > 0 )
            {
                TransferHelper.safeApprove(oActiveIn, address(oPooler), nAmountActual);
                uint256 nAmountOut = oPooler.doSwap( oActiveIn, oTokenOut, nFee, nTick, nAmountActual);
                oActiveIn = oTokenOut;
                nAmountActual = nAmountOut;
            }
        }
        */

        uint256 nBalance = oTokenErcIn.balanceOf(address(this));

        

        if( nBalance > 0 )
        {
            oTokenErcIn.transfer(msg.sender, nBalance);
            // TransferHelper.safeTransferFrom(oTokenIn, address(this), msg.sender, nBalance);
        }
        
        return nAmountActual;
    }
}
