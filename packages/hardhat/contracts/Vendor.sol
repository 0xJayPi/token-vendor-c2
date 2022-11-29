pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

error Vendor__TransferFailed();

contract Vendor is Ownable {
    uint256 public constant tokensPerEth = 100;

    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
    event SellTokens(
        address seller,
        uint256 amountOfETH,
        uint256 amountOfTokens
    );

    YourToken public yourToken;

    constructor(address tokenAddress) {
        yourToken = YourToken(tokenAddress);
    }

    function buyTokens() public payable {
        uint256 _amountToTransfer;
        _amountToTransfer = tokensPerEth * msg.value;

        yourToken.transfer(msg.sender, _amountToTransfer);

        emit BuyTokens(msg.sender, msg.value, _amountToTransfer);
    }

    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        if (!success) {
            revert Vendor__TransferFailed();
        }
    }

    function sellTokens(uint256 _amount) public payable {
        uint256 _amountToTransfer;
        _amountToTransfer = _amount / tokensPerEth;

        yourToken.transferFrom(msg.sender, address(this), _amount);

        (bool success, ) = payable(msg.sender).call{value: _amountToTransfer}(
            ""
        );
        if (!success) {
            revert Vendor__TransferFailed();
        }

        emit SellTokens(msg.sender, msg.value, _amountToTransfer);
    }
}
