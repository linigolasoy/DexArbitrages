import { network } from "hardhat";

const { viem, networkName } = await network.create();
const client = await viem.getPublicClient();

console.log(`Deploying PoolerManager to ${networkName}...`);

const counter = await viem.deployContract("PoolerManager");

console.log("PoolerManager address:", counter.address);

// console.log("Calling counter.incBy(5)");
// const tx = await counter.write.incBy([5n]);

// console.log("Waiting for the counter.incBy(5) tx to confirm");
// await client.waitForTransactionReceipt({ hash: tx, confirmations: 1 });

console.log("Deployment successful!");