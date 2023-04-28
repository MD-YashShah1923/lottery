// //SPDX-License-Identifier: MIT
// pragma solidity ^0.8.7;
// //0x02C0f62c2DE98F29687672794661D8f9bdF7999d

// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";

// import "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";

// contract Lottery is VRFV2WrapperConsumerBase, Ownable {
//     struct LotteryStruct {
//         uint256 id;
//         string title;
//         string description;
//         string image;
//         uint256 prize;
//         uint256 ticketPrice;
//         uint256 participants;
//         uint256 winners;
//         bool drawn;
//         address owner;
//         uint256 createdAt;
//         uint256 expiresAt;
//     }

//     struct ParticipantStruct {
//         address account;
//         string lotteryNumber;
//         bool paid;
//     }

//     struct LotteryResultStruct {
//         uint256 id;
//         bool completed;
//         bool paidout;
//         uint256 timestamp;
//         uint256 sharePerWinner;
//         ParticipantStruct[] winners;
//     }

//     mapping(uint256 => LotteryStruct) lotteries;
//     mapping(uint256 => ParticipantStruct[]) lotteryParticipants;
//     mapping(uint256 => string[]) lotteryLuckyNumbers;
//     mapping(uint256 => mapping(uint256 => bool)) luckyNumberUsed;
//     mapping(uint256 => LotteryResultStruct) lotteryResult;
//     uint256 public feeToCreator;
//     uint256 public serviceBalance;
//     uint256 public winnerIndex;

//     constructor(
//         uint256 _servicePercent
//     ) VRFV2WrapperConsumerBase(linkAddress, wrapperAddress) {
//         feeToCreator = _servicePercent;
//     }

//     using Counters for Counters.Counter;
//     Counters.Counter private _totalLotteries;

//     bytes32 public keyHash;
//     uint256 public check;
//     uint256 public idrequest;

//     uint256 public fee;
//     event RequestSent(uint256 requestId, uint32 numWords);
//     event RequestFulfilled(
//         uint256 requestId,
//         uint256[] randomWords,
//         uint256 payment
//     );

//     struct RequestStatus {
//         uint256 paid; // amount paid in link
//         bool fulfilled; 
//         uint256[] randomWords;
//     }
//     mapping(uint256 => RequestStatus)
//         public s_requests; /* requestId --> requestStatus */

//     // past requests Id.
//     uint256[] public requestIds;
//     uint256 public lastRequestId;

    
//     uint32 callbackGasLimit = 1000000;

    
//     uint16 requestConfirmations = 3;

    
//     uint32 numWords = 1;

//     // Address LINK - hardcoded for Sepolia
//     address linkAddress = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;

//     // address WRAPPER - hardcoded for Sepolia
//     address wrapperAddress = 0x99aFAf084eBA697E584501b8Ed2c0B37Dd136693;

//     function requestRandomWords()
//         external
//         onlyOwner
//         returns (uint256 requestId)
//     {
//         requestId = requestRandomness(
//             callbackGasLimit,
//             requestConfirmations,
//             numWords
//         );
//         s_requests[requestId] = RequestStatus({
//             paid: VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit),
//             randomWords: new uint256[](0),
//             fulfilled: false
//         });
//         requestIds.push(requestId);
//         lastRequestId = requestId;
//         emit RequestSent(requestId, numWords);
//         return requestId;
//     }

//     function fulfillRandomWords(
//         uint256 _requestId,
//         uint256[] memory _randomWords
//     ) internal override {
//         require(s_requests[_requestId].paid > 0, "request not found");
//         s_requests[_requestId].fulfilled = true;
//         s_requests[_requestId].randomWords = _randomWords;
//         emit RequestFulfilled(
//             _requestId,
//             _randomWords,
//             s_requests[_requestId].paid
//         );
//         uint256 index = _randomWords[0] % 3;
//         check = index;
//         ParticipantStruct[] memory winners = new ParticipantStruct[](1);
//         ParticipantStruct[] memory participants = lotteryParticipants[1];
//         winners[0] = participants[check];
//         lotteryResult[1].winners.push(winners[0]);
//     }

//     function getRequestStatus(
//         uint256 _requestId
//     )
//         external
//         view
//         returns (uint256 paid, bool fulfilled, uint256[] memory randomWords)
//     {
//         require(s_requests[_requestId].paid > 0, "request not found");
//         RequestStatus memory request = s_requests[_requestId];
//         return (request.paid, request.fulfilled, request.randomWords);
//     }

//     /**
//      * Allow withdraw of Link tokens from the contract
//      */
//     function withdrawLink() public onlyOwner {
//         LinkTokenInterface link = LinkTokenInterface(linkAddress);
//         require(
//             link.transfer(msg.sender, link.balanceOf(address(this))),
//             "Unable to transfer"
//         );
//     }

//     //  struct RequestStatus {
//     //     uint256 paid; // amount paid in link
//     //     bool fulfilled; // whether the request has been successfully fulfilled
//     //     uint256[] randomWords;
//     // }
//     // mapping(uint256 => RequestStatus)
//     //     public s_requests; /* requestId --> requestStatus */

//     // uint256[] public requestIds;
//     // uint256 public lastRequestId;

//     // uint32 callbackGasLimit = 1000000;

//     // // The default is 3, but you can set this higher.
//     // uint16 requestConfirmations = 3;

//     // // For this example, retrieve 2 random values in one request.
//     // // Cannot exceed VRFV2Wrapper.getConfig().maxNumWords.
//     // uint32 numWords = 1;

//     // // Address LINK - hardcoded for Sepolia
//     // address linkAddress = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;

//     // // address WRAPPER - hardcoded for Sepolia
//     // address wrapperAddress = 0x99aFAf084eBA697E584501b8Ed2c0B37Dd136693;

//     function createLottery(
//         string memory title,
//         string memory description,
//         string memory image,
//         uint256 prize,
//         uint256 ticketPrice,
//         uint256 expiresAt
//     ) public {
//         require(bytes(title).length > 0, "title cannot be empty");
//         require(bytes(description).length > 0, "description cannot be empty");
//         require(bytes(image).length > 0, "image cannot be empty");
//         require(prize > 0 ether, "prize cannot be zero");
//         require(ticketPrice > 0 ether, "ticketPrice cannot be zero");
//         require(
//             expiresAt > currentTime(),
//             "expireAt cannot be less than the future"
//         );

//         _totalLotteries.increment();
//         LotteryStruct memory lottery;

//         lottery.id = _totalLotteries.current();
//         lottery.title = title;
//         lottery.description = description;
//         lottery.image = image;
//         lottery.prize = prize;
//         lottery.ticketPrice = ticketPrice;
//         lottery.owner = msg.sender;
//         lottery.createdAt = currentTime();
//         lottery.expiresAt = expiresAt;

//         lotteries[lottery.id] = lottery;
//     }

//     function importLuckyNumbers(
//         uint256 id,
//         string[] memory luckyNumbers
//     ) public {
//         require(luckyNumbers.length > 0, "Lucky numbers cannot be zero");
//         require(lotteries[id].owner == msg.sender, "Unauthorized entity");
//         require(lotteryLuckyNumbers[id].length < 1, "Already generated");
//         lotteryLuckyNumbers[id] = luckyNumbers;
//     }

//     function buyTicket(uint256 id, uint256 luckyNumberId) public payable {
//         require(
//             !luckyNumberUsed[id][luckyNumberId],
//             "Lucky number already used"
//         );
//         require(
//             msg.value >= lotteries[id].ticketPrice,
//             "insufficient ethers to buy ticket"
//         );

//         lotteries[id].participants++;
//         lotteryParticipants[id].push(
//             ParticipantStruct(
//                 msg.sender,
//                 lotteryLuckyNumbers[id][luckyNumberId],
//                 false
//             )
//         );

//         luckyNumberUsed[id][luckyNumberId] = true;
//         serviceBalance += msg.value;
//     }

//     // function randomlySelectWinners(uint256 id, uint256 numOfWinners) public {
//     //     require(
//     //         lotteries[id].owner == msg.sender ||
//     //         msg.sender == owner(),
//     //         "Unauthorized entity"
//     //     );
//     //     require(!lotteryResult[id].completed, "Lottery have already been completed");
//     //     require(
//     //         numOfWinners <= lotteryParticipants[id].length,
//     //         "Number of winners exceeds number of participants"
//     //     );

//     //     ParticipantStruct[] memory winners = new ParticipantStruct[](numOfWinners);
//     //     ParticipantStruct[] memory participants = lotteryParticipants[id];

//     //     uint256[] memory indices = new uint256[](participants.length);
//     //     for (uint256 i = 0; i < participants.length; i++) {
//     //         indices[i] = i;
//     //     }

//     //     for (uint256 i = participants.length - 1; i >= 1; i--) {
//     //         uint256 j = uint256(
//     //             keccak256(abi.encodePacked(currentTime(), i))
//     //         ) % (i + 1);
//     //         uint256 temp = indices[j];
//     //         indices[j] = indices[i];
//     //         indices[i] = temp;
//     //     }

//     //     for (uint256 i = 0; i < numOfWinners; i++) {
//     //         winners[i] = participants[indices[i]];
//     //         lotteryResult[id].winners.push(winners[i]);
//     //     }

//     //     lotteryResult[id].completed = true;
//     //     lotteryResult[id].timestamp = currentTime();
//     //     lotteries[id].winners = lotteryResult[id].winners.length;
//     //     lotteries[id].drawn = true;

//     //     payLotteryWinners(id);
//     // }
//     // function fulfillRandomness(bytes32 requestId, uint256 randomness) internal virtual override  {

//     //     // require(
//     //     //     lotteries[1].owner == msg.sender ||
//     //     //     msg.sender == owner(),
//     //     //     "Unauthorized entity"
//     //     // );
//     //     // require(!lotteryResult[1].completed, "Lottery have already been completed");
//     //     // require(
//     //     //     1 <= lotteryParticipants[1].length,
//     //     //     "Number of winners exceeds number of participants"
//     //     // );
//     //     // ParticipantStruct[] memory winners = new ParticipantStruct[](1);
//     //     // ParticipantStruct[] memory participants = lotteryParticipants[1];

//     //       winnerIndex = randomness % lotteryParticipants[1].length;

//     //     //  winners[0] = participants[winnerIndex];
//     //     //  lotteryResult[1].winners.push(winners[0]);

//     //     // lotteryResult[1].completed = true;
//     //     // lotteryResult[1].timestamp = currentTime();
//     //     // lotteries[1].winners = lotteryResult[1].winners.length;
//     //     // lotteries[1].drawn = true;

//     //     // payLotteryWinners(1);

//     //     // Emit that the game has ended

//     //     // set the gameStarted variable to false

//     // }

//     /**
//      * getRandomWinner is called to start the process of selecting a random winner
//      */

//     // require(
//     //     lotteries[id].owner == msg.sender ||
//     //     msg.sender == owner(),
//     //     "Unauthorized entity"
//     // );
//     // require(!lotteryResult[id].completed, "Lottery have already been completed");

//     // // ParticipantStruct[] memory winners = new ParticipantStruct[](1);
//     // // ParticipantStruct[] memory participants = lotteryParticipants[id];
//     // requestId = requestRandomness(
//     //     callbackGasLimit,
//     //     requestConfirmations,
//     //     numWords
//     // );
//     // s_requests[requestId] = RequestStatus({
//     //     paid: VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit),
//     //     randomWords: new uint256[](0),
//     //     fulfilled: false
//     // });
//     // requestIds.push(requestId);
//     // lastRequestId = requestId;

//     // return requestId;

//     function payLotteryWinners(uint256 id) public {
//         ParticipantStruct[] memory winners = lotteryResult[id].winners;
//         uint256 totalShares = lotteries[id].ticketPrice *
//             lotteryParticipants[id].length;
//         uint256 platformShare = (totalShares * feeToCreator) / 100;
//         uint256 netShare = totalShares - platformShare;
//         uint256 sharesPerWinner = netShare / winners.length;

//         for (uint256 i = 0; i < winners.length; i++)
//             payTo(winners[i].account, sharesPerWinner);

//         payTo(owner(), platformShare);
//         serviceBalance -= totalShares;
//         lotteryResult[id].id = id;
//         lotteryResult[id].paidout = true;
//         lotteryResult[id].sharePerWinner = sharesPerWinner;
//     }

//     function getLotteries()
//         public
//         view
//         returns (LotteryStruct[] memory Lotteries)
//     {
//         Lotteries = new LotteryStruct[](_totalLotteries.current());

//         for (uint256 i = 1; i <= _totalLotteries.current(); i++) {
//             Lotteries[i - 1] = lotteries[i];
//         }
//     }

//     function getLottery(uint256 id) public view returns (LotteryStruct memory) {
//         return lotteries[id];
//     }

//     function getLotteryParticipants(
//         uint256 id
//     ) public view returns (ParticipantStruct[] memory) {
//         return lotteryParticipants[id];
//     }

//     function getLotteryLuckyNumbers(
//         uint256 id
//     ) public view returns (string[] memory) {
//         return lotteryLuckyNumbers[id];
//     }

//     function getLotteryResult(
//         uint256 id
//     ) public view returns (LotteryResultStruct memory) {
//         return lotteryResult[id];
//     }

//     function payTo(address to, uint256 amount) internal {
//         (bool success, ) = payable(to).call{value: amount}("");
//         require(success, "transferring of amounts failed");
//     }

//     function currentTime() internal view returns (uint256) {
//         uint256 newNum = (block.timestamp * 1000) + 1000;
//         return newNum;
//     }
// }
