// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;
    uint256 _totalAddresses;
    mapping(uint256 => address) _addresses;
    mapping(address => uint256) leaderboard;

    event NewWave(address indexed from, uint256 timestamp, string message);

    struct Wave {
        address waver; // The address of the user who waved.
        string message; // The message the user sent.
        uint256 timestamp; // The timestamp when the user waved.
    }

    Wave[] waves;

    mapping(address => uint256) public lastWavedAt;

    constructor() payable {
        console.log("hey!");
        _totalAddresses = 0;
    }

    function wave(string memory _message) public {
        // Uncomment to enable cooldown

        // require(
        //     lastWavedAt[msg.sender] + 30 seconds < block.timestamp,
        //     "Wait 30 seconds"
        // );

        /*
         * Update the current timestamp we have for the user
         */
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves++;
        console.log("%s has waved", msg.sender);
        // register address
        _addresses[_totalAddresses] = msg.sender;
        leaderboard[msg.sender] = leaderboard[msg.sender] + 1;
        _totalAddresses++;

        /*
         * This is where I actually store the wave data in the array.
         */
        waves.push(Wave(msg.sender, _message, block.timestamp));
        emit NewWave(msg.sender, block.timestamp, _message);

        // send prizes
        uint256 prizeAmount = 0.0001 ether;
        require(
            prizeAmount <= address(this).balance,
            "Trying to withdraw more money than the contract has."
        );
        (bool success, ) = (msg.sender).call{value: prizeAmount}("");
        require(success, "Failed to withdraw money from contract.");
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("We have %d total waves!", totalWaves);
        return totalWaves;
    }

    // Get the address of the user who waved the most.
    function getMostWaves() public view returns (address) {
        uint256 acc = 0;
        address winner;
        for (uint256 i = 0; i < _totalAddresses; i++) {
            // console.log(
            //     "%s has waved %d times",
            //     _addresses[i],
            //     leaderboard[_addresses[i]]
            // );
            if (leaderboard[_addresses[i]] > acc) {
                acc = leaderboard[_addresses[i]];
                winner = _addresses[i];
            }
        }
        console.log("The most waves is %d by %s", acc, winner);
        return winner;
    }
}
