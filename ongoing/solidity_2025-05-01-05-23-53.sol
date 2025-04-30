modifier onlyOwner() {
    require(msg.sender == owner, 'Not authorized');
    _;
}

