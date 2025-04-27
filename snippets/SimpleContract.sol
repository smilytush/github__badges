// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleStorage {
    uint256 private value;
    address public owner;
    
    event ValueChanged(uint256 newValue);
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }
    
    function setValue(uint256 _value) public onlyOwner {
        value = _value;
        emit ValueChanged(_value);
    }
    
    function getValue() public view returns (uint256) {
        return value;
    }
}
// Updated on 2025-04-25 08:06:15 - Session: morning
// Updated on 2025-04-25 21:55:58 - Session: afternoon
// Updated on 2025-04-26 10:21:34 - Session: morning
// Updated on 2025-04-26 21:51:19 - Session: afternoon
// Updated on 2025-04-27 00:51:18 - Session: morning
// Updated on 2025-04-27 08:19:45 - Session: morning
// Updated on 2025-04-27 09:07:09 - Session: morning - Commit: 1
// Updated on 2025-04-27 09:07:28 - Session: morning - Commit: 2
