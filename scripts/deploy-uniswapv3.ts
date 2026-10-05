import { network } from "hardhat";

const { viem, networkName } = await network.create();
const client = await viem.getPublicClient();

console.log(`Deploying Counter to ${networkName}...`);

const counter = await viem.deployContract("PoolerUniswpV3", ["0x61fFE014bA17989E743c5F6cB21bF9697530B21e", "0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45"]);

console.log("PoolerUniswpV3 address:", counter.address);

// console.log("Calling counter.incBy(5)");
// const tx = await counter.write.incBy([5n]);

// console.log("Waiting for the counter.incBy(5) tx to confirm");
// await client.waitForTransactionReceipt({ hash: tx, confirmations: 1 });

console.log("Deployment successful!");