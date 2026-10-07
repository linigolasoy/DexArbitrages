// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;


import "./IPooler.sol";
// Pooler manager
interface IPoolerManager
{
  function getPoolerAddress( uint256 nItem ) external view returns (address);
  function getPooler( uint256 nItem ) external view returns (IPooler);

  function getCount() external view returns(uint256);


  function setPooler( address oPooler, uint256 nItem) external returns (bool);

  function newPooler( address oPooler) external returns (uint256);
}
