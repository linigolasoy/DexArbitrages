import { network } from "hardhat";

const { viem, networkName } = await network.create();
const client = await viem.getPublicClient();
import * as dotenv from 'dotenv';

console.log(`Deploying Counter to ${networkName}...`);

const counter = await viem.deployContract("PoolerPancakeSwapV3", 
    [
        "0xB048Bbc1Ee6b733FFfCFb9e9CeF7375518e25997", // Quoter
        "0x1b81D678ffb9C0263b24A97847620C99d213eB14", // Router
        "PancakeSwapV3"]);

console.log("PoolerPancakeSwapV3 address:", counter.address);

dotenv.config();
const strAddress = process.env.ARBITRUM_CONTRACT;
const strZeroAddress = strAddress as `0x${string}`;

// Get arbitrager
const oArbitrager = await viem.getContractAt("ArbitragerFlash", strZeroAddress);

console.log("ArbitragerFlash address:", oArbitrager.address);

const strPoolerManager = await oArbitrager.read.getPoolerManager();
const oPoolerManager = await viem.getContractAt("PoolerManager", strPoolerManager);
console.log("PoolerManager address:", oPoolerManager.address);

const oTx = await oPoolerManager.write.setPooler([counter.address, BigInt(2)]);
// const oTx = await oPoolerManager.write.newPooler(["0x251827fa2d135cda67468c138b12831970b1fb9c"]);
await client.waitForTransactionReceipt({ hash: oTx, confirmations: 1 });

// console.log("Calling counter.incBy(5)");
// const tx = await counter.write.incBy([5n]);

// console.log("Waiting for the counter.incBy(5) tx to confirm");
// await client.waitForTransactionReceipt({ hash: tx, confirmations: 1 });

console.log("Deployment successful!");