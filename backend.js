const express = require("express");
// import routes from "./routes/lottery.mjs";

const router = express.Router();
const useThis = require("./routes/lottery.js");

const app = express();
const { ethers } = require("hardhat");
const abi = require("./artifacts/contracts/Lottery.sol/Lottery.json");

const provider = new ethers.providers.JsonRpcProvider(
  process.env.API_URL
);
// const contractAddress ="0xfe553F4ea6E26646422580f636b7Daa9821A51A2"
const contractAddress ="0xF24129669D21f137E9546826c953aD0882E9F1e9";


const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
const lottery = new ethers.Contract(contractAddress, abi.abi, provider);


// const web3 = new Web3("wss://sepolia.infura.io/ws/v3/3b7605f98f494f3b93c16dd985ea8cc5");



// const LotteryContract = new web3.eth.Contract(LotteryABI.abi, contractAddress);
// const ownerAddress = process.env.ADDRESS;

app.use(express.json()); //this is the build in express body-parser 
app.use(                //this mean we don't need to use body-parser anymore
  express.urlencoded({
    extended: true,
  })
); 


app.get("/",(req,res)=>{
    res.send("Hello Yash Shah This side");
})
app.use('/createLottery',useThis);
    // const { title, description,image,prize,ticketPrice,expiresAt } = req.body;
    // // const prizeAmount = web3.utils.fromWei(prize.toString(), 'ether');
    // // const ticketamount = web3.utils.fromWei(ticketPrice.toString(),'ether');
    // // const amountInWei = ethers.BigNumber.from(prize);
    // // const prize1 = ethers.utils.formatEther(amountInWei);
    // // const ticketprize1 = ethers.utils.formatEther(ticketPrice);
    // // const prize12 = ethers.utils.formatEther(ticketprize1);

    // const main = async () => {
    //     console.log(`wallet address: ${wallet.address}`);
    //     const result = await lottery
    //       .connect(wallet)
    //       .createLottery("lottery", "tryluck", "hey", 10000, 100, 119999977777799);
    //     console.log(result.hash);
    //     res.send(result.hash);
    //   };
    //   main();
    

   
   
    
  // });
app.use('/importLuckyNumber',useThis);
    // const {id,luckyNumbers} = req.body;
    // const main = async() =>{
    //   const result = await lottery.connect(wallet).importLuckyNumbers(id,luckyNumbers);
    //   console.log(result.hash);
    //   res.send(result.hash);


    // }
    // main();


app.post('/getLotteryLuckyNumbers',(req,res) =>{
  const {id} = req.body;
  const main = async() => {
    const result = await lottery.getLotteryLuckyNumbers(id);
    console.log(result);
    res.send(result);
  }
  main();
})
app.get('/lastrequestid', async(req,res) =>{
  const result = await lottery.lastRequestId();
  console.log(result);
  res.send(result);

})
app.post('/buyTicket',(req,res) =>{
  const {id,luckyid,privatekey} = req.body;
  const wallet1 = new ethers.Wallet(privatekey,provider);

  const main = async() => {
    const result = await lottery.connect(wallet1).buyTicket(id,luckyid,{value : ethers.utils.parseEther("0.00000000000001")});
    console.log(result);
    
    console.log(result.hash);
    res.send(result);
    
  }
  main();
})

app.post('/requestRandomWords',(req,res) =>{
  // const {id} = req.body;
  const main = async() => {
    const result = await lottery.connect(wallet).requestRandomWords();
    await result.wait();
    console.log(result);
    res.send(result)
    
    // console.log(result.hash);
    // res.send(result);
    
  }
  main();
})
app.post('/getRequestStatus',(req,res) =>{
  // const {id} = req.body;
  const main = async() => {
    const id = await lottery.connect(wallet).lastRequestId();
    
    console.log(id);
    
    console.log("-------------------------------");
    const result = await lottery.connect(wallet).getRequestStatus(id);
    console.log(result);
    
    console.log(result.hash);
    res.send(result);
    
  }
  main();
})    
app.post('/getLotteryResult',(req,res) =>{
  const {id} = req.body;
  const main = async() => {
    const result = await lottery.connect(wallet).getLotteryResult(id);
    console.log(result);
    
    console.log(result.hash);
    res.send(result);
    
  }
  main();
})
app.post('/payLotteryWinners',(req,res) =>{
  const {id} = req.body;
  const main = async() => {
    const result = await lottery.connect(wallet).payLotteryWinners(id);
    console.log(result);
    
    console.log(result.hash);
    res.send(result);
    
  }
  main();
})
app.post('/getLottery',(req,res) =>{
  const {id} = req.body;
  const main = async() => {
    const result = await lottery.connect(wallet).getLottery(id);
    console.log(result);
    
    console.log(result.hash);
    res.send(result);
    
  }
  main();
})
app.post('/getLotteries',(req,res) =>{
  const {id} = req.body;
  const main = async() => {
    const result = await lottery.connect(wallet).getLotteries();
    console.log(result);
    
    console.log(result.hash);
    res.send(result);
    
  }
  main();
})
app.post('/getLotteryParticipant',(req,res) =>{
  const {id} = req.body;
  const main = async() => {
    const result = await lottery.connect(wallet).getLotteryParticipants(id);
    console.log(result);
    
    console.log(result.hash);
    res.send(result);
    
  }
  main();
})     
app.get("/about",(req,res) =>{
    res.send("about page");
})
const start = async() =>{
    
    app.listen(8000,()=>{
        console.log("listenig to port");
    })

}
start();
