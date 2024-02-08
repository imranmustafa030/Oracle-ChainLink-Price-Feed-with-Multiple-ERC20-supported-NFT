// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./PriceFeed.sol";
import "hardhat/console.sol";

contract MyNFT is ERC721URIStorage, PriceFeed{
    constructor() ERC721("MyToken", "MTK") {}
    
    address owner;
    function mint(address _to, uint256 _tokenID, string calldata _uri) external{
        _mint(_to, _tokenID);
        _setTokenURI(_tokenID, _uri);
        owner = msg.sender;
    }

    function BuyInUSD (uint256 _tokenID, uint256 _amount, IERC20 _address) public payable {
        IERC20 paytoken = _address;
        int Price = getValue();
        uint256 newPrice = convertIntToUint256(Price);
        require(_amount >= newPrice, "Ether Price is Changed, Please Check Latest Price");
        paytoken.transferFrom(msg.sender, address(this), _amount);
        ERC721(address(this)).transferFrom(owner, msg.sender, _tokenID);
        paytoken.transfer(owner, _amount);
        
    }
    function SendAmountToOwner(IERC20 _paytoken) public payable {
        IERC20 paytoken = _paytoken;
        paytoken.transfer(msg.sender, paytoken.balanceOf(address(this)));
    }
    function getValue() public view returns (int){
        // PriceFeed price;
        int latestPrice = PriceFeed.getChainlinkDataFeedLatestAnswer();
        latestPrice = latestPrice/100000000;
        return latestPrice;
    }
    function convertIntToUint256(int256 intValue) internal pure returns (uint256) {
        return uint256(intValue);
    }

}