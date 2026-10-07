import { network } from "hardhat";

const { viem, networkName } = await network.create();
const client = await viem.getPublicClient();

console.log(`Deploying ArbitragerFlash to ${networkName}...`);

const oArbitrager = await viem.deployContract("ArbitragerFlash", ["0xa39e94bd8834ef7634f2eab11f2499ec3f2dbd11"]);



console.log("ArbitragerFlash address:", oArbitrager.address);


console.log("Deployment successful!");