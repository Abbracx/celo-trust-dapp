// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;
// pragma experimental ABIEncoderV2;

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
    uint public childCount;

    //an enumeration to make sure kid is not added twice
    enum Status {NOT_ADDED, IS_ADDED}
    Status status = Status.NOT_ADDED;

    //event to trigger that a kid has been registered
    event Registered (
        address indexed by,
        address indexed who,
        uint when
        );

    //Kid struct type to store kid needed attributes
    struct Kid {
        string name;
        address payable child;
        uint amount;
        uint timeToMaturity;
        bool paid;
        Status status;
    }

    mapping (uint => Kid) internal Kids;
    mapping (string => uint) public KidsIndex;


  constructor() {
    childCount = 0;
    admin = msg.sender;
  }

    function addKid (address payable _kid,
                    string memory _name,
                    uint _timeToMaturity)
                    external payable {

        uint timeToMaturity = block.timestamp + _timeToMaturity;
        bool _paid = false;

        require (msg.sender == admin, "Only owner can add kid.");
        require (Kids[childCount].status == Status.NOT_ADDED, "Kid already exist");

        Kids[childCount] = Kid(_name, _kid, msg.value, timeToMaturity, _paid, Status.IS_ADDED);
        KidsIndex[_name] = childCount;


        emit Registered(msg.sender, _kid, block.timestamp);
        childCount++;
    }


    function getKid(string memory _name) external view returns(
        string memory name,
        address child,
        uint amount,
        uint timeToMaturity,
        bool paid ){

        if(keccak256(bytes(_name)) == keccak256(bytes(Kids[KidsIndex[_name]].name))){
            return (
                Kids[KidsIndex[_name]].name,
                Kids[KidsIndex[_name]].child,
                Kids[KidsIndex[_name]].amount,
                Kids[KidsIndex[_name]].timeToMaturity,
                Kids[KidsIndex[_name]].paid
                );
        }

    }


    function withdrawAmount(string memory _name) external {

        address _child = msg.sender;

        //only the kid can withdraw his money deposited
        require (Kids[KidsIndex[_name]].child == _child, "Only valid kid can withdraw");
        require (Kids[KidsIndex[_name]].amount > 0, "Cannot withdraw zero value.");
        require (Kids[KidsIndex[_name]].paid == false, "Paid Already.");
        require (Kids[KidsIndex[_name]].timeToMaturity < block.timestamp, "Sorry You cannot withdraw now.");

        // payable(_kid).transfer(kid.amount);
        // code below is to prevent reeentrancy as oppose to msg.sender.transfer(Amount)

        (bool success, ) = payable(_child).call{value:Kids[KidsIndex[_name]].amount}("");
        require(success, "Transfer failed.");
        Kids[KidsIndex[_name]].paid = true;
  }


}

