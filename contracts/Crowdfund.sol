pragma solidity ^0.4.24;

contract Crowdfund {
  address owner;
  uint256 goal;
  bool reached;
  uint blockDeadline;
  mapping(address => uint256) contributions;

  event GoalReached();
  event FundsWithrawed(uint amount);
  event FundsRefunded(uint amount);

  modifier isOwner() {
    require(msg.sender == owner);
    _;
  }

  modifier isOpen() {
    require(address(this).balance < goal);
    require(!timeLimitPast());
    require(!reached);
    _;
  }

  modifier handleForciblySentEther() {
    if(address(this).balance > 0) {
      msg.sender.transfer(address(this).balance);
    }
    _;
  }


  modifier crowdfundSucceeded() {
    require(reached);
    _;
  }

  modifier crowdfundFailed()  {
    require(timeLimitPast());
    require(!reached);
    _;
  }

  constructor(uint256 _goal, uint _blockDeadline) handleForciblySentEther() {
    owner = msg.sender;
    goal = _goal;
    reached = false;
    blockDeadline = _blockDeadline;
  }

  function timeLimitPast() view public returns (bool) {
    return block.number > blockDeadline;
  }


  function contribute() public payable isOpen() {
    require(address(this).balance + msg.value <= goal); // No refunds
    contributions[msg.sender] += msg.value;
    if(address(this).balance == goal) {
      reached = true;
      emit GoalReached();
    }
  }

  function refund() public crowdfundFailed () {
    uint256 amount = contributions[msg.sender];

    //avoid reentry
    contributions[msg.sender] = 0; 
    msg.sender.transfer(amount);

    emit FundsRefunded(amount);
    
  }

  function withdrawFunds(uint256 amount)
  public
  isOwner
  crowdfundSucceeded {
    msg.sender.transfer(amount);
    emit FundsWithrawed(amount);
  }
}
