pragma solidity ^0.4.11;

contract BlessedBlocks {
    mapping (address => bet) bets; //map an address to a bet
	uint public startTime;
	uint public endTime;
	uint[] secrets; //storing all collected secrets
	uint public betAmount; //the required bet amount, in finney
	uint public numBettors;
	uint winSecret;
	bool winSet;
	uint public curTime;
	bytes32 myhash;
	uint finalBalance;
	uint public revealTimeOffset;
	uint numWinners;
	address public temple; //the address of the initializing entity
	struct bet{
	    bool paid; //if this bet was paid out or not
	    bytes32 hash; //the hash of the bettor address and their secret number
	    uint secret; //the revealed secret populated during the reveal phase
        bool gotSecret; //tracks the submission of the secret	    
	}
	//store collected ether
	
	//Create a new bettor entry, passing in the hash that will be proof of win
	function submitBet(bytes32 _hash) public payable {
		require(msg.value == (betAmount * 1 finney));
		require(now <= endTime);
		require(bets[msg.sender].hash == 0);
		bets[msg.sender].paid = false;
        bets[msg.sender].hash = _hash;
	}
	
	function revealSecret(uint _secret) public{
	     //ensure that the checking entity has actually made a bet and that they are not resubmitting a secret
//	    require(bets[msg.sender].hash != 0 && bets[msg.sender].gotSecret == false);
	    //check to make sure the time is after betting phase is over
//		require(now < revealTimeOffset);
		myhash = 0x815fb7b57f02ad10b400541d6f547e2cf0090e3e0a42b19626b756a0e39bcaec;
		//match the previously submitted hash to ensure that the bettor is honest
//    	require(bets[msg.sender].hash == keccak256(_secret,msg.sender));
//		bets[msg.sender].secret = _secret;
//		bets[msg.sender].gotSecret = true;
		//keep count of how many bets have been made, do it at this stage because if you don't submit an N value you lose your deposit
		numBettors++; 
	}
	function getTime() public {
	    curTime = now;
	}
	function checkWinnings() public{
	    uint picker = 0;
	    //time must be after the reveal window
	    require(now > revealTimeOffset);
	    //the checking party must have revealed their secret number and not collected their winnings yet
	    require(bets[msg.sender].gotSecret == true && bets[msg.sender].paid == false);
	    if (winSet== false) {
	        for (uint i = 0; i < secrets.length; i++){
	            picker = picker ^ secrets[i];
	        }
    	   //choose the winning number from the array of secret numbers 
            winSecret = secrets[(picker % secrets.length)];
            //count the number of winners that chose the same secret
    	   for (uint x = 0; x < secrets.length; x++){
    	       if (secrets[x] == winSecret) {numWinners++;}
    	   }
    	   finalBalance = this.balance;
    	   //set the flag
    	   winSet = true;
	   }
	   if (winSecret == bets[msg.sender].secret){
	       //send the winnings, divided by number of winners
	       msg.sender.transfer(finalBalance/numWinners);
	       bets[msg.sender].paid = true;
	   }
	}	

	//function: set up the rules for the bet
	function BlessedBlocks(uint _timeLimit,uint _betAmount,uint _revealTimeOffset) public {
		temple = msg.sender;
        startTime = now;
        endTime = (_timeLimit * 1 seconds) + startTime;
        revealTimeOffset = (_revealTimeOffset * 1 seconds) + endTime;
		betAmount = _betAmount;
	}
}

