// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./CrowdFundingContract.sol";

contract CrowdSourcingFactory is Ownable {
    address public immutable crowdFundingImplementation;
    address[] public deployedContracts;
    uint256 public fundingFee = 0.001 ether;

    event CrowdFundingCreated(
        address indexed owner,
        uint256 amount,
        address cloneAddress,
        string fundingCID
    );

    constructor(address _implementation) Ownable() {
        crowdFundingImplementation = _implementation;
    }

    function createCrowdFundingContract(
        string memory _fundingCID,
        uint256 _amount,
        uint256 _duration
    ) external payable returns (address) {
        require(msg.value >= fundingFee, "Funding Fee is not enough!");
        address clone = Clones.clone(crowdFundingImplementation);
        (bool success, ) = clone.call(
            abi.encodeWithSignature(
                "initialize(string,uint256,uint256)",
                _fundingCID,
                _amount,
                _duration
            )
        );
        require(success, "Can not create crowd funding contract!");
        deployedContracts.push(clone);
        emit CrowdFundingCreated(msg.sender, _amount, clone, _fundingCID);
        return clone;
    }

    function withdrawFunds() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "nothing to withdraw");
        (bool success, ) = payable(msg.sender).call{value: balance}("");
        require(success, "withdrawal failed");
    }

    function getDeployedContracts() public view returns (address[] memory) {
        return deployedContracts;
    }

    receive() external payable {}
}
