// SPDX-License-Identifier: MIT
// ADMIN CONTROLLER
pragma solidity ^0.8.0;

import './TokenContract.sol';
import './AuctionContract.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract AccountContract is Ownable , AuctionContract {

    mapping( uint256 => Account ) _accounts;
    uint256 countAccount;

    event Accounts(address indexed owner, uint256 bid);
    event Collections(address indexed tokenAddr, address owner);

    /**
    call by sdk
     */
    function createAccount() external {
        bool alreadyExist;
        for (uint256 index = 0; index < countAccount; index++) {
            if(_accounts[index].owner == msg.sender && msg.sender != address(0)){ alreadyExist=true;break;}
        }
        require(alreadyExist==false,"Address already exist");
        Account storage account = _accounts[countAccount];
        account.owner = msg.sender;
        countAccount++;
    }

    function isMyAccount() internal view returns(uint256){
        bool IAmOwner;
        uint256 userId;
        for (uint256 index = 0; index < countAccount; index++) {
            if(_accounts[index].owner == msg.sender && msg.sender != address(0)){
                IAmOwner = true;
                userId = index;
                break;
            }
        }
        require(IAmOwner==true,"User not exist");
        return userId;
    }

    /*function setParamsAccount() external {
        uint256 idAccount = isMyAccount();
        _accounts[idAccount].paramsAccount = 
    }*/

    function closeAccount() external {

    }

    /**
    Call by sdk
    We create auction and add into accounts map auction
     */
    function addAuction() external {
        bool userExist;
        uint256 userId;
        for (uint256 index = 0; index < countAccount; index++) {
            if(_accounts[index].owner == msg.sender && msg.sender != address(0)){ userExist=true;userId=index;break;}
        }
        require(userExist==true,"User not valid");
        _accounts[userId]._auctions[_accounts[userId].countAuction] = createAuction();
        _accounts[userId].countAuction++;
    }

    /**
    Call by token contract
    Token contract created by SDK, this function only add into map
    */
    function addCollection(address ownerTokenAddr) external {
        bool userExist;
        for (uint256 index = 0; index < countAccount; index++) {
            if(_accounts[index].owner == ownerTokenAddr && ownerTokenAddr != address(0)){
                _accounts[index]._collections[_accounts[index].countCollection] = msg.sender;
                _accounts[index].countCollection++;
                userExist=true;
                break;
            }
        }
        require(userExist==true,"User not exist");
    }
    


    /**
    On set le tableau de token dans l'auction avec un tableau directement, plus rapide ,plus opti
     */
    function setRole(uint256 a, uint8 _type, address[] memory roleArray) external OwnerContract(a) {
        if(_type == 1){_accounts[a]._minter_role = roleArray;}
        if(_type == 2){_accounts[a]._pauser_role = roleArray;}
        if(_type == 3){_accounts[a]._editor_role = roleArray;}
    }

    /**
    Pour récuperer le tableau coter front, le mêttre a jour coter front puis renvoyer vers solidity quand on modif
     */
    function getRole(uint256 a, uint8 _type) external view returns(address[] memory) {
        if(_type == 1){return _accounts[a]._minter_role;}else
        if(_type == 2){return _accounts[a]._pauser_role;}else
        if(_type == 3){return _accounts[a]._editor_role;}
    }

    modifier hasRole(uint256 a, uint8 _type){
        require(_type == 1 || _type == 2 || _type == 3, "type is not valid");
        uint256 currentCount;
        bool _hasRole;
        if(_type == 1) currentCount = _accounts[a]._minter_role.length;
        if(_type == 2) currentCount = _accounts[a]._pauser_role.length;
        if(_type == 3) currentCount = _accounts[a]._editor_role.length;
        for (uint256 index = 0; index < currentCount; index++) {
            if(msg.sender == _accounts[a]._minter_role[index]){_hasRole = true; break;}
        }
        require(_hasRole == true,"You have not permission");
        _;
    }

}