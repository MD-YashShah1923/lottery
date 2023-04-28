const { ethers } = require("hardhat");
const abi = require("./artifacts/contracts/Lock.sol/Lottery.json");

const provider = new ethers.providers.JsonRpcProvider(
  process.env.API_URL
);
const contractAddress ="0xfe553F4ea6E26646422580f636b7Daa9821A51A2"

const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
const lottery = new ethers.Contract(contractAddress, abi.abi, provider);

const main = async () => {
  console.log(`wallet address: ${wallet.address}`);
  const result = await lottery
    .connect(wallet)
    .createLottery("lottery", "try your luck", "hey", 10000, 100, 119999977777799);
  console.log(result.hash);
};
main();