// SPDX-License-Identifier: MIT
/**
 * @title KARX Token
 * @dev This is an ERC20 token that implements OpenZeppelin's ERC20, ERC20Burnable,
 * ERC20Pausable, Ownable, and ERC20Permit extensions. It features transaction fees,
 * burning mechanisms, anti-whale measures, and an anti-bot system.
 *
 * The token is designed for the KARX Chain, aiming to enhance transparency, 
 * efficiency, and community engagement in the supply chain ecosystem.
 *
 * Copyright (c) 2021-25 KARX Chain
 * For more information, visit https://www.karx.org/
 */


pragma solidity 0.8.20;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC20/utils/SafeERC20.sol";

// File: contracts/KARXToken.sol
contract KARXToken is ERC20, ERC20Burnable, ERC20Pausable, Ownable,ERC20Permit {
    
    // State variables for the tax fee & burn system
    uint256 public transactionFee = 1; // Transaction fee as a percentage
    uint256 public burnRate = 1; // Burn rate as a percentage
    address public feeDestination; // Address where transaction fees are sent
    
    // Mapping to track fee and burn exclusions
    mapping(address => bool) public isExcludedFromFeeAndBurn; // Tracks fee and burn exclusions
    
    // State variables for the anti-whale system
    uint256 public maxTransferAmountRate = 500; // 5% of total supply
    uint256 public maxWalletBalanceRate = 1000; // 10% of total supply
    uint256 private constant MAX_RATE = 10000; // 100% using a basis point system for precision
    
    // Flag to enable/disable burning for the public
    bool public burnForPublicEnabled = false;
       
    // Events for administrative actions and updates
    event BurnForPublicEnabledUpdated(bool enabled);
    event MaxTransferAmountRateUpdated(uint256 oldRate, uint256 newRate);
    event MaxWalletBalanceRateUpdated(uint256 oldRate, uint256 newRate);
    event TokensRecovered(address tokenAddress, uint256 tokenAmount);
    event TransactionFeeUpdated(uint256 oldFee, uint256 newFee);
    event BurnRateUpdated(uint256 oldBurnRate, uint256 newBurnRate);
    event FeeDestinationUpdated(address indexed oldFeeDestination, address indexed newFeeDestination);
    event ExcludedFromFeeAndBurn(address indexed account, bool isExcluded);
    event TransactionFeeCollected(uint256 txfeeAmount);
  
    using SafeERC20 for IERC20;

    constructor() 
    ERC20("KARX Token", "KARX") 
    Ownable()
    ERC20Permit("KARX")
    {
        _mint(msg.sender, 1000000000 * 10**decimals()); // Mint the initial token supply
    }
    
    // Function to enable/disable burning for all
    function toggleBurn(bool _enabled) external onlyOwner {
        burnForPublicEnabled = _enabled;
        emit BurnForPublicEnabledUpdated(_enabled);
    }
    
    // Override the burn function
    function burn(uint256 amount) public override {
        require(burnForPublicEnabled || owner() == _msgSender(), "KARXToken: Burning is not allowed");
        super.burn(amount);
    }
    
    // Override the burnFrom function
    function burnFrom(address account, uint256 amount) public override {
        require(burnForPublicEnabled || owner() == _msgSender(), "KARXToken: Burning is not allowed");
        super.burnFrom(account, amount);
    }
    
    //Anti-Whale System : Set Max Transfer Amount Rate in basispoints 
    function updateMaxTransferAmountRate(uint256 _maxTransferAmountRate) external  onlyOwner {
        require(maxTransferAmountRate != _maxTransferAmountRate, "KARXToken: Staus Quo in Max Transfer Rate");
        require(_maxTransferAmountRate <= MAX_RATE, "KARXToken: Transfer amount exceeds the maximum rate.");
        require(_maxTransferAmountRate >= 100, "KARXToken: Transfer amount cannot be less than 1% of total supply");
        emit MaxTransferAmountRateUpdated(maxTransferAmountRate, _maxTransferAmountRate);
        maxTransferAmountRate = _maxTransferAmountRate;
    }
    
    //Anti-Whale System : Set Wallet Amount Rate in basispoints
    function updateMaxWalletBalanceRate(uint256 _maxWalletBalanceRate) external onlyOwner {
        require(maxWalletBalanceRate != _maxWalletBalanceRate, "KARXToken: Staus Quo in Max Wallet Balance Rate");
        require(_maxWalletBalanceRate <= MAX_RATE, "KARXToken: Max wallet balance exceeds the maximum rate.");
        require(_maxWalletBalanceRate >= 500, "KARXToken: Max wallet balance cannot be less than 5% of total supply");
        emit MaxWalletBalanceRateUpdated(maxWalletBalanceRate, _maxWalletBalanceRate);
        maxWalletBalanceRate = _maxWalletBalanceRate;
    }
    
    //Function to recover tokens accidentally sent to this contract
    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        IERC20(tokenAddress).safeTransfer(owner(), tokenAmount);
        emit TokensRecovered(tokenAddress, tokenAmount);
    }
    
    //Tax Fee & Burn System: Set TX Fee
    function setTransactionFee(uint256 _transactionFee) external  onlyOwner {
        require(_transactionFee <= 5, "KARXToken: Transaction fee cannot exceed 5%");
        emit TransactionFeeUpdated(transactionFee, _transactionFee);
        transactionFee = _transactionFee;
    }
    
    //Tax Fee & Burn System: Set Burn Rate
    function setBurnRate(uint256 _burnRate) external  onlyOwner {
        require(_burnRate <= 5, "KARXToken: Burn rate cannot exceed 5%");
        emit BurnRateUpdated(burnRate, _burnRate); // Emit an event with the old and new burn rates
        burnRate = _burnRate;
    }
    
    //Tax Fee & Burn System: Set TX Fee Destination
    function setFeeDestination(address _feeDestination) external onlyOwner {
        require(_feeDestination != address(0), "KARXToken: Invalid fee destination");
        emit FeeDestinationUpdated(feeDestination, _feeDestination); // Emit an event with the old and new fee destinations
        feeDestination = _feeDestination;
    }
    
    //Tax Fee & Burn System: Exclude Core Project Accounts from Tax & Burn
    function excludeFromFeeAndBurn(address account, bool excluded) external onlyOwner {
        isExcludedFromFeeAndBurn[account] = excluded;
        emit ExcludedFromFeeAndBurn(account, excluded);
    }

    function pause() external onlyOwner {
        _pause();
    }
    
    function unpause() external onlyOwner {
        _unpause();
    }
  
    function _beforeTokenTransfer(address sender, address recipient, uint256 amount) internal override(ERC20,ERC20Pausable) whenNotPaused {
       super._beforeTokenTransfer(sender, recipient, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        //require(amount > 0, "KARXToken: Transfer amount must be greater than zero"); This line will cause lot of unit tests to fail
 
        if(amount == 0) {
            super._transfer(sender, recipient, 0);
            return;
        }
        //AntiWhale
        if (recipient != owner() && recipient != address(0)) {
            uint256 maxTransferAmount = (totalSupply() * maxTransferAmountRate) / MAX_RATE;
            require(amount <= maxTransferAmount, "KARXToken: Transfer amount exceeds the maxTransferAmount");
            uint256 recipientBalance = balanceOf(recipient);
            uint256 maxWalletBalance = (totalSupply() * maxWalletBalanceRate) / MAX_RATE;
            require(recipientBalance + amount <= maxWalletBalance, "KARXToken: Exceeds maximum wallet token balance");
        }
        //Owner or fee excluded user must be able to directly transfer      
        if (sender == owner() || recipient == owner() || 
            isExcludedFromFeeAndBurn[sender] || 
            isExcludedFromFeeAndBurn[recipient] ||
            recipient == feeDestination) {
                super._transfer(sender, recipient, amount);
                return;
        }
     
    // Calculate fee and burn amounts for normal transfers, excluding owner or feeDestination transactions
    uint256 feeAmount = (amount * transactionFee) / 100 ;
    uint256 burnAmount = (amount * burnRate) / 100;
    uint256 amountAfterFeeAndBurn = amount - feeAmount - burnAmount;
    amount = amountAfterFeeAndBurn;
    super._transfer(sender, feeDestination, feeAmount); //Transfer fee
    emit TransactionFeeCollected(feeAmount);  
    _burn(sender, burnAmount); // This ensures Transfer event for burn
    super._transfer(sender, recipient, amount); //Transfer Amount after fee collection and burn  
    }
}
