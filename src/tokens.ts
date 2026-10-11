// import {getContract} from "viem";

// Token interface
export interface IToken
{
    symbol: string;
    address: string;
    decimals: number;
}


export class TokenGatherer
{

    public async getTokens(): Promise<IToken[] | undefined> {
        return undefined;
    }
}