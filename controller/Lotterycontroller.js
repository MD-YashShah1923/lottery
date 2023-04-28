const { ethers } = require("hardhat");
const abi = require("../artifacts/contracts/Lottery.sol/Lottery.json");

const provider = new ethers.providers.JsonRpcProvider(
  process.env.API_URL
);
const contractAddress ="0xF24129669D21f137E9546826c953aD0882E9F1e9"

const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
const lottery = new ethers.Contract(contractAddress, abi.abi, provider);



exports.createLotter = async (req, res) => {
    // const{title,prize,endat} = req.body;
    console.log(`wallet address: ${wallet.address}`);
    // const amountInWei = ethers.BigNumber.from(prize);
    // const prize1 = ethers.utils.formatEther(amountInWei);
    // const prize12 = ethers.utils.parseEther(prize);
    // const endat1 = ethers.utils.parseEther(endat);
    const result = await lottery
          .connect(wallet)
          .createLottery("try your luck",100,12323232454554);

    console.log(result.hash);
    res.send(result.hash);
};
exports.importLuckyNumber = async(req,res) =>{
     const {id,luckyNumbers} = req.body;
     const result = await lottery.connect(wallet).importLuckyNumbers(id,luckyNumbers);
     console.log(result.hash);
     res.send(result.hash);
}

exports.getLotteryLuckyNumbers = async(req,res) =>{
    const {id} = req.body;
  
    const result = await lottery.getLotteryLuckyNumbers(id);
    console.log(result);
    res.send(result);
  
}
