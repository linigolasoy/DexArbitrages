import { network } from "hardhat";
const { viem, networkName } = await network.create();
const client = await viem.getPublicClient();
import * as dotenv from 'dotenv';


// Tokens to swap
const strTokenIn = "0xaf88d065e77c8cC2239327C5EDb3A432268e5831";
const strTokenMid = "0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9";
const nFee : number = 100;
const nPooler : number = 0;


console.log(`Testing poolers on ${networkName}...`);
dotenv.config();
const strAddress = process.env.ARBITRUM_CONTRACT;
const strZeroAddress = strAddress as `0x${string}`;

// Get arbitrager
const oArbitrager = await viem.getContractAt("ArbitragerFlash", strZeroAddress);
console.log("ArbitragerFlash address:", oArbitrager.address);




// Get pooler manager
const strPoolerManager = await oArbitrager.read.getPoolerManager();
const oPoolerManager = await viem.getContractAt("PoolerManager", strPoolerManager);
console.log("PoolerManager address:", oPoolerManager.address);

// const oTx = await oPoolerManager.write.setPooler(["0x251827fa2d135cda67468c138b12831970b1fb9c", BigInt(2)]);
// const oTx = await oPoolerManager.write.newPooler(["0x251827fa2d135cda67468c138b12831970b1fb9c"]);
// await client.waitForTransactionReceipt({ hash: oTx, confirmations: 1 });
// 0x0260f57cb712bb32c2c421ede9728736840fe271
// Get pooler to test
const strPoolerUniV3 = await oPoolerManager.read.getPoolerAddress([BigInt(nPooler)]);
const oPoolerUniV3 = await viem.getContractAt("PoolerUniswpV3", strPoolerUniV3);
console.log("Pooler UniV3 address:", oPoolerUniV3.address);


const strPoolerUniV2 = await oPoolerManager.read.getPoolerAddress([BigInt(1)]);
const oPoolerUniV2 = await viem.getContractAt("PoolerUniswpV2", strPoolerUniV2);
console.log("Pooler UniV2 address:", oPoolerUniV2.address);

const strPoolerPanV3 = await oPoolerManager.read.getPoolerAddress([BigInt(2)]);
const oPoolerPanV3 = await viem.getContractAt("PoolerUniswpV3", strPoolerPanV3);
console.log("Pooler PanV3 address:", oPoolerPanV3.address);

/*
const oTx2 = await oPoolerUniV2.write.doSwap([
    strTokenIn, 
    strTokenMid, 
    0, 
    0, 
    BigInt(100000)
]);
await client.waitForTransactionReceipt({ hash: oTx2, confirmations: 1 });

*/



/*
// const oErc20 = new  viem.getPublicClient()

console.log("Calling arbitrage");


const tx2 = await oArbitrager.write.doArbitrageFlashLoan(
    [
        BigInt(1000000),    
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
                pooler: BigInt(0),
                fee: 100,
                tickSpace: 0
            }
        ]
    ]);


console.log("   Waiting for the arbitrage(5) tx to confirm", tx2);
await client.waitForTransactionReceipt({ hash: tx2, confirmations: 1 });

console.log("   Sent arbitrage tx successful!");
*/