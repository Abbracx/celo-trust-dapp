// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

interface IERC20Token {
  function transfer(address, uint256) external returns (bool);
  function approve(address, uint256) external returns (bool);
  function transferFrom(address, address, uint256) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address) external view returns (uint256);
  function allowance(address, address) external view returns (uint256);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * The Trust contract does this and that...
 */
contract Trust {

    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;
    address public admin; // Owner of the contract

    //an enumeration to make sure kid is not added twice
    enum Status {NOT_ADDED, IS_ADDED}
    Status status = Status.NOT_ADDED;

    //event to trigger that a kid has been registered
    event Registered (
        address indexed by,
        address indexed who,
        uint when
        );

    //Kid struct type to store kid needed attribute
    struct Kid {
        string name;
        uint amount;
        uint timeToMaturity;
        bool paid;
        Status status;
    }

    mapping (address => Kid) public Kids;

    Kid [] list_of_kids;

  constructor() {
        admin = msg.sender;
  }

  function addKid (address _kid, string memory _name, uint _timeToMaturity) external payable {

        uint timeToMaturity = block.timestamp + _timeToMaturity;
        bool _paid = false

        require (msg.sender == admin, "Only owner can add kid.");
        require (Kids[_kid].status != Status.IS_ADDED, "Kid already exist");

        Kids[_kid] = Kid(_name, msg.value, timeToMaturity, _paid, Status.IS_ADDED);
        list_of_kids.push(_kid);
        emit Registered(msg.sender, _kid, block.timestamp);
  }

  function showKidAmount (address _kid) external view returns(uint, string memory) {
        return (Kids[_kid].amount, Kids[_kid].name);
  }


  function withdrawAmount() external returns(bool)  {


        uint amount;
        address _kid = msg.sender;
        Kid memory kid = Kids[_kid];



        require (kid.amount > 0, "Cannot withdraw zero value.");
        require (kid.paid == false, "Paid Already.");
        require (kid.timeToMaturity <= block.timestamp, "Sorry You cannot withdraw.");

        // payable(_kid).transfer(kid.amount);
        // code below is to prevent reeentrancy as oppose to msg.sender.transfer(Amount)
        amount = kid.amount;
        kid.amount = 0;
        (bool success, ) = payable(_kid).call{value:amount}("");
        require(success, "Transfer failed.");
        kid.paid = true;
        return success;
  }

  function getAllkids () returns(Kid[] memory) external {
      return list_of_kids
  }



}

