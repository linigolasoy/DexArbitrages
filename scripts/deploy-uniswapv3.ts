import { network } from "hardhat";

const { viem, networkName } = await network.create();
const client = await viem.getPublicClient();

console.log(`Deploying Counter to ${networkName}...`);

const counter = await viem.deployContract("PoolerUniswpV3", 
    [
        "0x61fFE014bA17989E743c5F6cB21bF9697530B21e", // Quoter
        "0xE592427A0AEce92De3Edee1F18E0157C05861564", // Router
        "UniswapV3"]);

console.log("PoolerUniswpV3 address:", counter.address);

// console.log("Calling counter.incBy(5)");
// const tx = await counter.write.incBy([5n]);

// console.log("Waiting for the counter.incBy(5) tx to confirm");
// await client.waitForTransactionReceipt({ hash: tx, confirmations: 1 });

console.log("Deployment successful!");