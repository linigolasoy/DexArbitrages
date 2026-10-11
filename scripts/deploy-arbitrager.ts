import { network } from "hardhat";

const { viem, networkName } = await network.create();
const client = await viem.getPublicClient();

console.log(`Deploying ArbitragerFlash to ${networkName}...`);

const oArbitrager = await viem.deployContract(
    "ArbitragerFlash", 
    [
        "0x8653a2ce280ccf858d8f99bc8271535329cbad12",
        "0xa97684ead0e402dC232d5A977953DF7ECBaB3CDb"
    ]);
// 0x5234e3111d010134e0f6ef681df011b73c401139



console.log("ArbitragerFlash address:", oArbitrager.address);


console.log("Deployment successful!");