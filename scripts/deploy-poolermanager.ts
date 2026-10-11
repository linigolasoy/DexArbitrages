import { network } from "hardhat";

const { viem, networkName } = await network.create();
const client = await viem.getPublicClient();

console.log(`Deploying PoolerManager to ${networkName}...`);

const oPooler = await viem.deployContract("PoolerManager");

console.log("PoolerManager address:", oPooler.address);

const oTx1 = await oPooler.write.newPooler(["0x4e31724eca6152df6922638b1f471590206363f9"]);
await client.waitForTransactionReceipt({ hash: oTx1, confirmations: 1 });

const oTx2 = await oPooler.write.newPooler(["0xae61f44baff83f29092f556576475515c9190bd6"]);
await client.waitForTransactionReceipt({ hash: oTx2, confirmations: 1 });


// console.log("Calling counter.incBy(5)");
// const tx = await counter.write.incBy([5n]);

// console.log("Waiting for the counter.incBy(5) tx to confirm");
// await client.waitForTransactionReceipt({ hash: tx, confirmations: 1 });

console.log("Deployment successful!");