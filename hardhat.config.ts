import hardhatToolboxViemPlugin from "@nomicfoundation/hardhat-toolbox-viem";
import { configVariable, defineConfig } from "hardhat/config";
import type { arbitrum } from "viem/chains";
// import type { polygon } from "viem/chains";

export default defineConfig({
  plugins: [hardhatToolboxViemPlugin],
  solidity: {
    profiles: {
      default: {
        version: "0.8.34",
      },
      production: {
        version: "0.8.34",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    },
  },
  networks: {
    hardhatMainnet: {
      type: "edr-simulated",
      chainType: "l1",
    },
    hardhatOp: {
      type: "edr-simulated",
      chainType: "op",
    },
    polygon: {
      type: "http",
      chainType: "l1",
      url: configVariable("POLYGON_RPC_URL"),
      accounts: [configVariable("POLYGON_PRIVATE_KEY")],
    },
    arbitrum: {
      type: "http",
      chainType: "l1",
      url: configVariable("ARBITRUM_RPC_URL"),
      accounts: [configVariable("ARBITRUM_PRIVATE_KEY")]
    },
  },
});
