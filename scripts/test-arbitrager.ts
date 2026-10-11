import { network } from "hardhat";
import { configVariable } from "hardhat/config";
import * as dotenv from 'dotenv';

const { viem, networkName } = await network.create();
const client = await viem.getPublicClient();

console.log(`Deploying ArbitragerFlash to ${networkName}...`);

dotenv.config();
const strAddress = process.env.ARBITRUM_CONTRACT;
const strZeroAddress = strAddress as `0x${string}`;

console.log("ArbitragerFlash theorical address:", strZeroAddress);
const oArbitrager = await viem.getContractAt("ArbitragerFlash", strZeroAddress); // "0x45c3885d3639b5b04c7302d1f9ae34d5e918d229");


console.log("ArbitragerFlash address:", oArbitrager.address);

console.log("Calling swap");

const strTokenIn = "0xaf88d065e77c8cC2239327C5EDb3A432268e5831";
const strTokenMid = "0x82aF49447D8a07e3bd95BD0d56f35241523fBab1";
// const oErc20 = new  viem.getPublicClient()
/*
const tx = await oArbitrager.write.doSwaps(
    [
        BigInt(10000),    
        strTokenIn,
        [
            {
                tokenOut: strTokenMid,
                pooler: BigInt(0),
                fee: 100,
                tickSpace: 0
            },
            {
                tokenOut: strTokenIn,
                pooler: BigInt(1),
                fee: 0,
                tickSpace: 0
            }
        ]
    ]);


console.log("   Waiting for the swap(5) tx to confirm", tx);
await client.waitForTransactionReceipt({ hash: tx, confirmations: 1 });

console.log("   Sent swap tx successful!");
*/

console.log("Calling arbitrage");


const tx2 = await oArbitrager.write.doArbitrageFlashLoan(
    [
        BigInt(100000000),    
        strTokenIn,
        [
            {
                tokenOut: strTokenMid,
                pooler: BigInt(2),
                fee: 500,
                tickSpace: 0
            },
            {
                tokenOut: strTokenIn,
                pooler: BigInt(2),
                fee: 500,
                tickSpace: 0
            }
        ]
    ]);


console.log("   Waiting for the arbitrage(5) tx to confirm", tx2);
await client.waitForTransactionReceipt({ hash: tx2, confirmations: 1 });

console.log("   Sent arbitrage tx successful!");
