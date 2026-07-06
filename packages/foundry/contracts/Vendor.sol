pragma solidity 0.8.20; //Do not change the solidity version as it negatively impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    /////////////////
    /// Errors //////
    /////////////////

    // Errors go here...
    error InvalidEthAmount();
    error InsufficientVendorTokenBalance(uint256 available, uint256 required);
    error EthTransferFailed(address to, uint256 amount);
    error InvalidTokenAmount();
    error InsufficientVendorEthBalance(uint256 available, uint256 required);
    //////////////////////
    /// State Variables //
    //////////////////////

    YourToken public immutable yourToken;
    uint256 public constant tokensPerEth = 100;

    ////////////////
    /// Events /////
    ////////////////

    // Events go here...
    event BuyTokens(
        address indexed buyer,
        uint256 amountOfETH,
        uint256 amountOfTokens
    );
    event SellTokens(
        address indexed seller,
        uint256 amountOfTokens,
        uint256 amountOfETH
    );
    ///////////////////
    /// Constructor ///
    ///////////////////

    constructor(address tokenAddress) Ownable(msg.sender) {
        yourToken = YourToken(tokenAddress);
    }

    ///////////////////
    /// Functions /////
    ///////////////////

    function buyTokens() external payable {
        if (msg.value == 0) revert InvalidEthAmount();
        uint256 amount = msg.value * tokensPerEth;
        if (amount > yourToken.balanceOf(address(this)))
            revert InsufficientVendorTokenBalance(
                yourToken.balanceOf(address(this)),
                amount
            );
        yourToken.transfer(msg.sender, amount);
        emit BuyTokens(msg.sender, msg.value, amount);
    }

    function withdraw() public onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        if (!success)
            revert EthTransferFailed(msg.sender, address(this).balance);
    }

    function sellTokens(uint256 amount) public {
        if (amount == 0) revert InvalidTokenAmount();
        uint256 ethToBePayed = amount / tokensPerEth;
        if (ethToBePayed > address(this).balance)
            revert InsufficientVendorEthBalance(
                address(this).balance,
                ethToBePayed
            );
        yourToken.transferFrom(msg.sender, address(this), amount);
        (bool success, ) = payable(msg.sender).call{value: ethToBePayed}("");
        if (!(success)) revert EthTransferFailed(msg.sender, ethToBePayed);
        emit SellTokens(msg.sender, amount, ethToBePayed);
    }
}
