import { network } from "hardhat";

const { viem, networkName } = await network.create();
const client = await viem.getPublicClient();

console.log(`Deploying ArbitragerFlash to ${networkName}...`);

// const oArbitrager = await viem.deployContract("ArbitragerFlash", ["0xa39e94bd8834ef7634f2eab11f2499ec3f2dbd11"]);

const oArbitrager = await viem.getContractAt("ArbitragerFlash", "0x3444e82f458cad6dbe18670de57c876ec655eb9e");


console.log("ArbitragerFlash address:", oArbitrager.address);

console.log("Calling swap");

const strTokenIn = "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174";
const strTokenMid = "0xc2132D05D31c914a87C6611C10748AEb04B58e8F";
// const oErc20 = new  viem.getPublicClient()

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


console.log("Calling arbitrage");


const tx2 = await oArbitrager.write.doArbitrage(
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


console.log("   Waiting for the arbitrage(5) tx to confirm", tx2);
await client.waitForTransactionReceipt({ hash: tx2, confirmations: 1 });

console.log("   Sent arbitrage tx successful!");
