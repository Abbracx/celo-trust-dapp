// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

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

contract Trust{

    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;
    address internal admin; // Owner of the contract
    uint internal childCount = 0;

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

        address payable child;
        string name;
        uint amount;
        uint timeToMaturity;
        bool paid;
        Status status;
    }

    mapping (uint => Kid) internal Kids;
    mapping (string => uint) public KidsIndex;


  constructor() {
    admin = msg.sender;
  }

    function addKid (address payable _kid,
                    string memory _name,
                    uint _amount,
                    uint _timeToMaturity) public payable {

        uint timeToMaturity = block.timestamp + _timeToMaturity;
        bool _paid = false;

        require (msg.sender == admin, "Only owner can add kid.");
        require (Kids[childCount].status == Status.NOT_ADDED, "Kid already exist");
        require ( _kid != msg.sender, "Dude You cant add yourself.");


        IERC20Token(cUsdTokenAddress).transferFrom(msg.sender, payable(address(this)), _amount);

        Kids[childCount] = Kid(payable(_kid), _name, _amount, timeToMaturity, _paid, Status.IS_ADDED);
        KidsIndex[_name] = childCount;


        emit Registered(msg.sender, _kid, block.timestamp);
        childCount++;
    }

    function getKid(string memory _name) view public returns(
        address child,
        string memory name,
        uint amount,
        uint timeToMaturity,
        bool paid ){

        require (keccak256(bytes(_name)) == keccak256(bytes(Kids[KidsIndex[_name]].name)));
        return (
            Kids[KidsIndex[_name]].child,
            Kids[KidsIndex[_name]].name,
            Kids[KidsIndex[_name]].amount,
            Kids[KidsIndex[_name]].timeToMaturity,
            Kids[KidsIndex[_name]].paid
            );
    }

    function getKid(uint _index) view public returns(
        address child,
        string memory name,
        uint amount,
        uint timeToMaturity,
        bool paid ){

        return (
            Kids[_index].child,
            Kids[_index].name,
            Kids[_index].amount,
            Kids[_index].timeToMaturity,
            Kids[_index].paid
            );
    }

    function withdrawAmount(string memory _name) public {

        address _child = payable(msg.sender);

        //only the kid can withdraw his money deposited
        require (Kids[KidsIndex[_name]].child == _child, "Only valid kid can withdraw");
        require (Kids[KidsIndex[_name]].amount > 0, "Cannot withdraw zero value.");
        require (Kids[KidsIndex[_name]].paid == false, "Paid Already.");
        require (Kids[KidsIndex[_name]].timeToMaturity < block.timestamp, "Sorry You cannot withdraw now.");

        IERC20Token(cUsdTokenAddress).transfer(_child, Kids[KidsIndex[_name]].amount);
        Kids[KidsIndex[_name]].paid = true;
    }

    function getChildCount() view public returns(uint){
        return childCount;
    }

    function showKidAmount(string memory _name) view public returns(uint){
        return Kids[KidsIndex[_name]].amount;
    }

    function showContractAmount() view public returns(uint){
        return address(this).balance;
    }

    function getAdmin() view public returns(address){
        return admin;
    }

}
