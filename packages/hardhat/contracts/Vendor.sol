pragma solidity ^0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
    event SellTokens(
        address buyer,
        uint256 amountOfETH,
        uint256 amountOfTokens
    );

    YourToken public yourToken;

    constructor(address tokenAddress) {
        yourToken = YourToken(tokenAddress);
    }

    uint256 public constant tokensPerEth = 100;

    // ToDo: create a payable buyTokens() function:
    function buyTokens() public payable {
        uint256 amountOfEth = msg.value;
        require(amountOfEth > 0, "Eth is required to buy tokens");

        uint256 amountOfTokens = amountOfEth * tokensPerEth;
        uint256 balanceOfVendor = address(yourToken).balance;
        require(
            balanceOfVendor > amountOfTokens,
            "the vendor does not have enough tokens left"
        );

        address buyer = msg.sender;
        bool sent = yourToken.transfer(buyer, amountOfTokens);
        require(sent, "Transfer Failed");

        emit BuyTokens(buyer, amountOfEth, amountOfTokens);
    }

    // ToDo: create a withdraw() function that lets the owner withdraw ETH
    function withdraw() public onlyOwner {
        uint256 vendorBalance = address(this).balance;
        require(vendorBalance > 0, "Vendor does not have any ETH to withdraw");

        // Send ETH
        address owner = msg.sender;
        (bool sent, ) = owner.call{value: vendorBalance}("");
        require(sent, "Failed to withdraw");
    }

    // ToDo: create a sellTokens(uint256 _amount) function:
    function sellTokens(uint256 amount) public {
        require(amount > 0, "Must sell a token amount greater than 0");

        address user = msg.sender;
        uint256 userBalance = yourToken.balanceOf(user);
        require(userBalance >= amount, "User does not have enough tokens");

        uint256 amountOfEth = amount / tokensPerEth;
        uint256 vendorEthBalance = address(this).balance;
        require(
            vendorEthBalance > amountOfEth,
            "Vendor does not have enough ETH"
        );

        bool sent = yourToken.transferFrom(user, address(this), amount);
        require(sent, "Failed to transfer tokens");

        (bool ethSent, ) = user.call{value: amountOfEth}("");
        require(ethSent, "Failed to send back eth");

        emit SellTokens(user, amountOfEth, amount);
    }
}
