

    /*function addRole(uint256 a, address _addr, uint8 _type) external onlyOwner {
        if(_type == 1){_auctions[a]._minter_role.addr[_auctions[a]._minter_role.count] = _addr;_auctions[a]._minter_role.count++;}
        if(_type == 2){_auctions[a]._pauser_role.addr[_auctions[a]._pauser_role.count] = _addr;_auctions[a]._pauser_role.count++;}
        if(_type == 3){_auctions[a]._editor_role.addr[_auctions[a]._editor_role.count] = _addr;_auctions[a]._editor_role.count++;}
    }

    function deleteRole(uint256 a, address _addr, uint8 _type) external onlyOwner {
        uint16 currentCount;
        if(_type == 1) currentCount = _auctions[a]._minter_role.count;
        if(_type == 2) currentCount = _auctions[a]._pauser_role.count;
        if(_type == 3) currentCount = _auctions[a]._editor_role.count;
        for (uint16 index = 0; index < currentCount; index++) {
            if(_type == 1 && _auctions[a]._minter_role.addr[index] == _addr){
                _auctions[a]._minter_role.addr[index] = address(0);
            }else if(_type == 2 && _auctions[a]._pauser_role.addr[index] == _addr){
                _auctions[a]._pauser_role.addr[index] = address(0);
            }else if(_type == 3 && _auctions[a]._editor_role.addr[index] == _addr){
                _auctions[a]._editor_role.addr[index] = address(0);
            }
        }
    }

    function getAllRole(uint256 a, uint8 _type) external OwnerContract(a) view returns (ROLE[] memory){
        uint16 currentCount;
        if(_type == 1) currentCount = _auctions[a]._minter_role.count;
        if(_type == 2) currentCount = _auctions[a]._pauser_role.count;
        if(_type == 3) currentCount = _auctions[a]._editor_role.count;
        ROLE[] memory result = new ROLE[](currentCount);
        for(uint256 i = 0; i < currentCount; i++){
            ROLE storage _role = _auctions[a]._minter_role[i];
            result[i] = _role;
        }
        return result;
    }*/