// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract Rent {

    address payable owner;
    address payable tenant;
    address payable middleman;

    uint256 rentAmount;
    uint256 bailAmount;
    uint256 totalAmount;
    uint256 unblockDate;
    bool isActive;

    event Withdrawal(uint amount, uint when, bool withBailReturn);
    event RentPaid(uint amount, uint when);

    modifier afterUnblockDate() {
        require(block.timestamp > unblockDate, "Unblock date must be in the future");
        _;
    }

    modifier onlyMiddleman(){
        require(msg.sender == middleman, "Only middleman can call this function");
        _;
    }

    constructor(address payable _tenant, address payable _middleman, uint256 _rentAmount, uint256 _unblockDate, uint256 _bailAmount) {
        require(_unblockDate > block.timestamp, "Unblock date must be in the future");
        owner = payable(msg.sender);
        tenant = _tenant;
        middleman = _middleman;
        rentAmount = _rentAmount;
        unblockDate = _unblockDate;
        bailAmount = _bailAmount;
        totalAmount = _rentAmount + _bailAmount;
    }

    function payRent() public payable {
        require(!isActive, "Rent is already active");
        require(msg.value == totalAmount, "Rent amount must be equal to the total amount");
        require(msg.sender == tenant, "Only tenant can pay rent");
        isActive = true;
    }

    function withdraw() public payable afterUnblockDate onlyMiddleman {
        tenant.transfer(address(this).balance - rentAmount);
        owner.transfer(rentAmount);
        emit Withdrawal(rentAmount, block.timestamp, true);
    }

    function withdrawNoBailReturn() public payable afterUnblockDate onlyMiddleman {
        owner.transfer(address(this).balance);
        emit Withdrawal(address(this).balance, block.timestamp, false);
    }

}