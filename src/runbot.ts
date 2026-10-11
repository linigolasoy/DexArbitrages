import {IToken, TokenGatherer} from  './tokens.ts';
import {config} from './config.ts';

import { network } from "hardhat";

const { viem, networkName } = await network.create();
const client = await viem.getPublicClient();

const oArbitrager = await viem.getContractAt("ArbitragerFlash", "0xd2566d160521a4ad1f8f67cbf582d31bca8edb8a");


// TODO: Get token details
console.log("01.- Get token details");
const oGather: TokenGatherer = new TokenGatherer();
const aTokens : IToken[] | undefined = await oGather.getTokens();
if( aTokens == undefined ) { console.error("Could not find tokens"); }

// TODO: Get bases an loan amounts
console.log("02.- Get bases and loan amounts ");
// TODO: Create pairs
console.log("03.- Create token ");
// TODO: Get avaliable pools
console.log("04.- Get avaliable pools ");
// TODO: Loop for pairs and pools
console.log("05.- Pool pair loop");



console.log("99.- Ending...");
