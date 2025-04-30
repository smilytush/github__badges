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
// Updated on 2025-04-27 09:07:46 - Session: morning - Commit: 3
// Updated on 2025-04-27 09:08:06 - Session: morning - Commit: 4
// Updated on 2025-04-27 09:08:24 - Session: morning - Commit: 5
// Updated on 2025-04-28 16:56:19 - Session: morning - Commit: 1 - Intensity: 5 (Dark green)
// Updated on 2025-04-28 16:56:35 - Session: morning - Commit: 2 - Intensity: 5 (Dark green)
// Updated on 2025-04-28 16:56:50 - Session: morning - Commit: 3 - Intensity: 5 (Dark green)
// Updated on 2025-04-28 16:57:08 - Session: morning - Commit: 4 - Intensity: 5 (Dark green)
// Updated on 2025-04-28 16:57:27 - Session: morning - Commit: 5 - Intensity: 5 (Dark green)
// Updated on 2025-04-30 11:08:07 - Forced commit
