// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;


// import './IERC20.sol';
import "./IPooler.sol";
import "./IPoolerManager.sol";
import "./IArbitrager.sol";
import './TransferHelper.sol';

import "@aave/core-v3/contracts/dependencies/openzeppelin/contracts/Strings.sol";
import "@aave/core-v3/contracts/flashloan/base/FlashLoanSimpleReceiverBase.sol";
import "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import "./IERC20.sol";


// Deployments :
//      Polygon :   0x6A9c19Ff046B578356b2C696Cd8565fe9dD1205f    

// Pooler manager

contract ArbitragerFlash is FlashLoanSimpleReceiverBase, IArbitrager
{

    IPoolerManager private m_oPoolerManager;
    address private _owner;


    /////////////////////////////////////////////////////////////////////// 
    // Constructor
    // @param oPoolerManager
    constructor( 
        address oPoolerManager,
        address oAddressProvider
     )
     FlashLoanSimpleReceiverBase(IPoolAddressesProvider(oAddressProvider))
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
        ArbitrageSwapParams[] memory aRoute
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
        return (oTokenAct, nAmountActual);
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

    /////////////////////////////////////////////////////////////////////// 
    /// Arbitrage swapping with flash loan, requires result to be positive
    /// @param nAmountIn    - Amount of token In
    /// @param oTokenIn     - Address of token in
    /// @param aRoute       - Swap route
    /// @return             - Amount out
    function doArbitrageFlashLoan( 
        uint256 nAmountIn, 
        address oTokenIn,
        ArbitrageSwapParams[] calldata aRoute
    ) external returns (uint256)
    {
        address oSender = msg.sender;
        // Check output address
        address oTokenOutAddress = aRoute[aRoute.length-1].tokenOut;
        require(oTokenOutAddress == oTokenIn, "token output different from input");


        bytes memory aData = abi.encode(aRoute);
        // TransferHelper.safeTransferFrom(oTokenIn, oSender, address(this), 1000);

        POOL.flashLoanSimple(
            address(this),
            oTokenIn,
            nAmountIn,
            aData,
            0 // referral code
        );
        
        IERC20 oErcTokenIn = IERC20(oTokenIn);
        uint256 nBalance = oErcTokenIn.balanceOf(address(this));
        if( nBalance > 0 )
        {
            oErcTokenIn.transfer( oSender, nBalance );
        }
        return nBalance;
    }

    function  executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    )  external override returns (bool) {
        

        ArbitrageSwapParams[] memory aParams = abi.decode(params, (ArbitrageSwapParams[]));


        (, uint256 nAmount) = doSwapsInternal( 
            amount, 
            asset,
            aParams );

        //Logic goes here
        /*
        require(false, string.concat("Inside execute amount(", 
                    Strings.toString(amount),
                    ") prem(",
                    Strings.toString(premium),
                    ")"));

        */                    
        uint256 totalAmount = amount + premium;
        require(nAmount > totalAmount, string.concat( 
            "Unprofitable arbitrage, swap result = ",
            Strings.toString(nAmount),
            " and required = ",
            Strings.toString(totalAmount)));
        
        IERC20(asset).approve(address(POOL), totalAmount);

        return true;
    }

    receive() external payable {}
}
