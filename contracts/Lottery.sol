//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
//0x02C0f62c2DE98F29687672794661D8f9bdF7999d

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";
contract Lottery is VRFV2WrapperConsumerBase,Ownable {
    struct LotteryStruct {
        uint256 id;
        string title;
        
        uint256 ticketPrice;
        uint256 participants;
        uint256 winners;
        address owner;
        uint256 createdAt;
        uint256 expiresAt;
    }

    struct ParticipantStruct {
        address account;
        string lotteryNumber;
        bool paid;
    }

    struct LotteryResultStruct {
        uint256 id;
        bool completed;
        bool paidout;
        uint256 timestamp;
        uint256 winnerShares;
        ParticipantStruct[] winners;
    }
    mapping(uint256 => LotteryStruct) lotteries;
    mapping(uint256 => ParticipantStruct[]) lotteryParticipants;
    mapping(uint256 => string[]) lotteryLuckyNumbers;
    mapping(uint256 => mapping(uint256 => bool)) luckyNumberUsed;
    mapping(uint256 => LotteryResultStruct) lotteryResult;
    uint256 public feeToCreator;
    uint256 public contractBalance;
    uint256 public winnerIndex;

    constructor(uint256 _servicePercent)  VRFV2WrapperConsumerBase(linkAddress, wrapperAddress) {
        
        
        feeToCreator = _servicePercent;
    }
    uint public lotteryNum =1;
    using Counters for Counters.Counter;
    Counters.Counter private _totalLotteries;
   
    bytes32 public keyHash;
    uint256 public check;
    uint256 public idrequest;
    
    uint256 public fee ;
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(
        uint256 requestId,
        uint256[] randomWords,
        uint256 payment
    );

    struct RequestStatus {
        uint256 paid; // amount paid in link
        bool fulfilled; // whether the request has been successfully fulfilled
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus)
        public s_requests; /* requestId --> requestStatus */

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;
    

  
    uint32 callbackGasLimit = 1000000;

    
    uint16 requestConfirmations = 3;

    
    uint32 numWords = 1;

    // Address LINK - hardcoded for Sepolia
    address linkAddress = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;

    // address WRAPPER - hardcoded for Sepolia
    address wrapperAddress = 0x99aFAf084eBA697E584501b8Ed2c0B37Dd136693;

    

    function requestRandomWords()
        external
        onlyOwner
        returns (uint256 requestId)
    {
        requestId = requestRandomness(
            callbackGasLimit,
            requestConfirmations,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            paid: VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit),
            randomWords: new uint256[](0),
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].paid > 0, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(
            _requestId,
            _randomWords,
            s_requests[_requestId].paid
        );
        uint256 index = _randomWords[0] % 3;
        check = index;
        ParticipantStruct[] memory winners = new ParticipantStruct[](1);
        ParticipantStruct[] memory participants = lotteryParticipants[lotteryNum];
        winners[0] = participants[check];
        lotteryResult[lotteryNum].winners.push(winners[0]);
        payLotteryWinners(lotteryNum);

    }

    function getRequestStatus(
        uint256 _requestId
    )
        external
        view
        returns (uint256 paid, bool fulfilled, uint256[] memory randomWords)
    {
        require(s_requests[_requestId].paid > 0, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.paid, request.fulfilled, request.randomWords);
    }

    /**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(linkAddress);
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }
    function addLink(uint _amount) public onlyOwner {
        LinkTokenInterface link1 = LinkTokenInterface(linkAddress);
        require(
            link1.transfer(address(this),_amount),
            "Unable to transfer"
        );
    }
    
    function createLottery(
        string memory title,
        
        uint256 ticketPrice,
        uint256 expiresAt
    ) public {
        require(bytes(title).length > 0, "title cannot be empty");
        require(ticketPrice > 0 ether, "ticketPrice cannot be zero");
        require(expiresAt > currentTime(),"expireAt cannot be less than the future");
        _totalLotteries.increment();
        LotteryStruct memory lottery;

        lottery.id = _totalLotteries.current();
        lottery.title = title;
        lottery.ticketPrice = ticketPrice;
        lottery.owner = msg.sender;
        lottery.createdAt = currentTime();
        lottery.expiresAt = expiresAt;
        lotteries[lottery.id] = lottery;
    }

    function importLuckyNumbers(uint256 id, string[] memory luckyNumbers)
        public
    {
        require(luckyNumbers.length > 0, "Lucky numbers cannot be zero");
        require(lotteries[id].owner == msg.sender, "Unauthorized entity");
        require(lotteryLuckyNumbers[id].length < 1, "Already generated");
        lotteryLuckyNumbers[id] = luckyNumbers;
    }

    function buyTicket(uint256 id, uint256 luckyNumberId) public payable {
        require(!luckyNumberUsed[id][luckyNumberId],"Lucky number already used");
        require(msg.value >= lotteries[id].ticketPrice,"insufficient ethers to buy ticket");
        lotteries[id].participants++;
        lotteryParticipants[id].push(
            ParticipantStruct(
                msg.sender,
                lotteryLuckyNumbers[id][luckyNumberId],
                false
            )
        );

        luckyNumberUsed[id][luckyNumberId] = true;
        contractBalance += msg.value;
    }

    function payLotteryWinners(uint256 id) public {
        ParticipantStruct[] memory winners = lotteryResult[id].winners;
        uint256 totalShares = lotteries[id].ticketPrice * lotteryParticipants[id].length;
        uint256 platformShare = (totalShares * feeToCreator) / 100 ;
        uint256 netShare = totalShares - platformShare;
        uint256 sharesPerWinner = netShare / winners.length;

        for (uint256 i = 0; i < winners.length; i++) 
            payTo(winners[i].account, sharesPerWinner);

        payTo(owner(), platformShare);
        contractBalance -= totalShares;
        lotteryResult[id].id = id;
        lotteryResult[id].paidout = true;
        lotteryResult[id].winnerShares = sharesPerWinner;
    }

    function getLotteries() public view returns (LotteryStruct[] memory Lotteries) {
        Lotteries = new LotteryStruct[](_totalLotteries.current());

        for (uint256 i = 1; i <= _totalLotteries.current(); i++) {
            Lotteries[i - 1] = lotteries[i];
        }
    }

    function getLottery(uint256 id) public view returns (LotteryStruct memory) {
        return lotteries[id];
    }

    function getLotteryParticipants(uint256 id) public view returns (ParticipantStruct[] memory) {
        return lotteryParticipants[id];
    }
    
    function getLotteryLuckyNumbers(uint256 id) public view returns (string[] memory) {
        return lotteryLuckyNumbers[id];
    }
    
    function getLotteryResult(uint256 id) public view returns (LotteryResultStruct memory) {
        return lotteryResult[id];
    }


    function payTo(address to, uint256 amount) internal {
        (bool success, ) = payable(to).call{value: amount}("");
        require(success,"transferring of amounts failed");
    }

    function currentTime() internal view returns (uint256) {
        uint256 newNum = (block.timestamp * 1000) + 1000;
        return newNum;
    }
}