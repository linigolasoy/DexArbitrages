// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface IPooler 
{
  /**
   * @dev Prints Hello World string
   */
  function getName() external view returns (string memory);

  function getAmountOut( address oTokenIn, address oTokenOut, uint24 nFee, uint24 nTickSpace, uint256 nAmountInt) 
    external returns (uint256);


  function doSwap( address oTokenIn, address oTokenOut, uint24 nFee, uint24 nTickSpace, uint256 nAmountInt) 
    external returns (uint256);
  // function getAmountOut( address oPool, bool bReverse, uint256 nAmountInt) external view returns (uint256);
}
