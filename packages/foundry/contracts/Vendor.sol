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
            revert InsufficientVendorTokenBalance(yourToken.balanceOf(address(this)),amount);
        yourToken.transfer(msg.sender, amount);
        emit BuyTokens(msg.sender, msg.value, amount);
    }

    function withdraw() public onlyOwner {}

    function sellTokens(uint256 amount) public {}
}
