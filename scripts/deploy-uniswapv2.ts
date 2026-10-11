import { network } from "hardhat";

const { viem, networkName } = await network.create();
const client = await viem.getPublicClient();

console.log(`Deploying UniswapV2 to ${networkName}...`);

const oUniswapV2 = await viem.deployContract(
    "PoolerUniswpV2", 
    ["0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24",  "UniswapV2"]
);
console.log("UniswapV2 Pooler address:", oUniswapV2.address);

/*
const oQuickSwapV2 = await viem.deployContract(
    "PoolerUniswpV2", 
    ["0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff",  "QuicksswapVs2"]
);
console.log("QuickswapV2 Pooler address:", oQuickSwapV2.address);
*/

// console.log("Calling counter.incBy(5)");
// const tx = await counter.write.incBy([5n]);

// console.log("Waiting for the counter.incBy(5) tx to confirm");
// await client.waitForTransactionReceipt({ hash: tx, confirmations: 1 });

console.log("Deployment successful!");