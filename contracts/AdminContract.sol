// SPDX-License-Identifier: MIT
// ADMIN CONTROLLER
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import './AuctionContract.sol';
import './TokenContract.sol';

contract AdminController is Ownable {

    struct ContractStruct {
        string name;
        string symbol;
        address addrToken;
        address addrAuction;
        address owner;
        uint256 id;
        bool valid;
    }

    mapping( uint256 => ContractStruct ) _contracts;
    uint256 countContract;

    function getAllContracts() external view returns (ContractStruct[] memory){
        ContractStruct[] memory result = new ContractStruct[](countContract);
        for(uint256 i = 0; i < countContract; i++){
            ContractStruct storage classe = _contracts[i];
            result[i] = classe;
        }
        return result;
    }

    /*function createContract(string memory _name, string memory _symbol, string memory _initBaseURI) external {
        TokenContract instanceTokenContract = new TokenContract(_name, _symbol, _initBaseURI);
        AuctionContract instanceAuctionContract = new AuctionContract(address(instanceTokenContract));
        _contracts[countContract] = ContractStruct(_name, _symbol,address(instanceTokenContract),address(instanceAuctionContract),msg.sender,countContract,true);
        countContract++;
    }*/

    function addContract(string memory _name, string memory _symbol, string memory _initBaseURI, address tokenContract, address auctionContract ) external{
        _contracts[countContract] = ContractStruct(_name, _symbol,tokenContract,auctionContract,msg.sender,countContract,true);
        countContract++;
    }

    function updateContract(address oldAddrAuction, address newAddrAuction) external{
        for(uint256 i = 0; i < countContract; i++){
            if(_contracts[i].valid == true && _contracts[i].addrAuction == oldAddrAuction){
                _contracts[i].addrAuction = newAddrAuction;
                break;
            }
        }
    }

    function getMyContractAddress() external view returns(address){
        for (uint256 index = 0; index < countContract; index++) {
            if(_contracts[index].owner == msg.sender && _contracts[index].valid == true){
                return _contracts[index].addrAuction;
            }
        }
    }

    function pauseAllContracts(bool pause) external onlyOwner {
        for (uint256 index = 0; index < countContract; index++) {
            if(_contracts[index].valid==true){
                AuctionContract _auctionContrat = AuctionContract(_contracts[index].addrAuction);
                _auctionContrat.pause(pause);
                TokenContract _tokenContract = TokenContract(_contracts[index].addrToken);
                _tokenContract.pause(pause);
            }
        }
    }

    /*function pauseOneContracts(bool pause) external onlyOwner {
        for (uint256 index = 0; index < countContract; index++) {
            if(_contracts[index].valid==true && ){
                AuctionContract _auctionContrat = AuctionContract(_contracts[index].addrAuction);
                _auctionContrat.pause(pause);
                TokenContract _tokenContract = TokenContract(_contracts[index].addrToken);
                _tokenContract.pause(pause);
            }
        }
    }*/

}
