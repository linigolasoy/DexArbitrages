// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

// Deployments : 
//  Polygon : 0x8b11e809094ec6c5bf2a834842c1fdffb7a1f39f
//      Item 0: UniswapV3   (0x0cface4e70a27ad9d6dc9178009b30b556cac8d1)
//      Item 1: UniswapV2   (0x625cc34189ad8007aaa3b184edd3bc3b46fd74d0)
//      Item 2: QuickwapV2  (0x45c3885d3639b5b04c7302d1f9ae34d5e918d229)
import "./IPooler.sol";
import "./IPoolerManager.sol";


/* 
==============================================================================================
Pooler manager
==============================================================================================
*/




contract PoolerManager is IPoolerManager {
  
    constructor()
    {
    }

    address[] private m_aPoolers;

    function getPoolerAddress( uint256 nItem ) public view returns (address)
    {
        if( nItem < 0 || nItem >= m_aPoolers.length ) return address(0);
        return m_aPoolers[nItem];
    }
  
    function getPooler( uint256 nItem ) public view returns (IPooler)
    {
        address oAddresss = getPoolerAddress(nItem);
        return IPooler(oAddresss);
    }

    function getCount() public view returns(uint256)
    {
        return m_aPoolers.length;
    }


    function setPooler( address oPooler, uint256 nItem) external returns (bool)
    {
        if( nItem < 0 || nItem >= m_aPoolers.length ) return false;
        m_aPoolers[nItem] = oPooler;
        return true;
    }

    function newPooler( address oPooler) external returns (uint256)
    {
        m_aPoolers.push(oPooler);
        uint256 nLen = m_aPoolers.length;
        return nLen - 1;
    }

}
