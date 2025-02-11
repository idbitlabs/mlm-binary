// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract MLM_Binary is ReentrancyGuard {
    struct Member {
        address sponsor;
        address left;
        address right;
        uint256 balance;
        uint256 dailyPairs;
        uint256 lastReset;
    }

    mapping(address => Member) public members;
    address[] public memberList;
    address public owner;
    IERC20 public token;
    uint256 public memberCount = 0;

    uint256 public constant JOIN_FEE = 1000 * 10**18;
    uint256 public constant SPONSOR_BONUS = 100 * 10**18;
    uint256 public constant PAIRING_BONUS = 50 * 10**18;
    uint256 public constant DAILY_PAIR_LIMIT = 12;

    event MemberRegistered(address indexed member, address indexed sponsor);
    event PairBonusPaid(address indexed member, uint256 amount);
    event SponsorBonusPaid(address indexed sponsor, uint256 amount);
    event Withdrawn(address indexed member, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can execute");
        _;
    }

    constructor(address _tokenAddress) {
        owner = msg.sender;
        token = IERC20(_tokenAddress);
    }

    function register(address _sponsor) external {
        require(members[msg.sender].sponsor == address(0), "Already registered");
        require(members[_sponsor].sponsor != address(0) || _sponsor == owner, "Invalid sponsor");
        require(token.transferFrom(msg.sender, address(this), JOIN_FEE), "Token transfer failed");

        members[msg.sender] = Member({
            sponsor: _sponsor,
            left: address(0),
            right: address(0),
            balance: 0,
            dailyPairs: 0,
            lastReset: block.timestamp / 1 days
        });

        memberList.push(msg.sender);
        memberCount++;

        assignPosition(_sponsor, msg.sender);
        paySponsorBonus(_sponsor);
        checkAndPayPairingBonus(_sponsor);
    }

    function assignPosition(address _sponsor, address _newMember) private {
        if (members[_sponsor].left == address(0)) {
            members[_sponsor].left = _newMember;
        } else if (members[_sponsor].right == address(0)) {
            members[_sponsor].right = _newMember;
        } else {
            address placement = findPlacement(members[_sponsor].left);
            members[placement].left = _newMember;
        }
    }

    function findPlacement(address _member) private view returns (address) {
        if (members[_member].left == address(0)) {
            return _member;
        } else if (members[_member].right == address(0)) {
            return _member;
        } else {
            return findPlacement(members[_member].left);
        }
    }

    function paySponsorBonus(address _sponsor) private {
        (bool success, ) = address(token).call(abi.encodeWithSelector(token.transfer.selector, _sponsor, SPONSOR_BONUS));
        require(success, "Transfer sponsor bonus failed");
        emit SponsorBonusPaid(_sponsor, SPONSOR_BONUS);
    }

    function checkAndPayPairingBonus(address _sponsor) private {
        uint256 today = block.timestamp / 1 days;

        if (members[_sponsor].lastReset < today) {
            members[_sponsor].dailyPairs = 0;
            members[_sponsor].lastReset = today;
        }
        
        if (members[_sponsor].dailyPairs >= DAILY_PAIR_LIMIT) {
            return;
        }
        
        if (members[_sponsor].left != address(0) && members[_sponsor].right != address(0)) {
            (bool success, ) = address(token).call(abi.encodeWithSelector(token.transfer.selector, _sponsor, PAIRING_BONUS));
            require(success, "Pairing bonus transfer failed");
            members[_sponsor].balance += PAIRING_BONUS;
            members[_sponsor].dailyPairs++;
            emit PairBonusPaid(_sponsor, PAIRING_BONUS);
        }
    }

    function withdraw() external nonReentrant {
        uint256 amount = members[msg.sender].balance;
        require(amount > 0, "No balance to withdraw");
        members[msg.sender].balance = 0;
        (bool success, ) = address(token).call(abi.encodeWithSelector(token.transfer.selector, msg.sender, amount));
        require(success, "Withdraw failed");
        emit Withdrawn(msg.sender, amount);
    }

    function getAllMembers() public view onlyOwner returns (Member[] memory) {
        require(memberCount > 0, "No members found");

        Member[] memory membersArray = new Member[](memberCount);
        for (uint i = 0; i < memberCount; i++) {
            membersArray[i] = members[memberList[i]];
        }

        return membersArray;
    }

    function getMemberInfo(address _member) external view returns (Member memory) {
        return members[_member];
    }
}
