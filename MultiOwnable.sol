pragma solidity ^0.4.18;


/**
 * @title MultiOwnable
 * @dev The MultiOwnable contract has owners addresses and provides basic authorization control
 * functions, this simplifies the implementation of "users permissions".
 */
contract MultiOwnable {
    address public manager; // address used to set owners
    address[] public owners;
    mapping(address => bool) public ownerByAddress;

    event AddOwner(address owner);
    event RemoveOwner(address owner);

    modifier onlyOwner() {
        require(ownerByAddress[msg.sender] == true);
        _;
    }

    /**
     * @dev MultiOwnable constructor sets the manager
     */
    function MultiOwnable() public {
        manager = msg.sender;
        _addOwner(msg.sender);
    }

    /**
     * @dev Function to add owner address
     */
    function addOwner(address _owner) public {
        require(msg.sender == manager);
        _addOwner(_owner);

    }

    /**
     * @dev Function to remove owner address
     */
    function removeOwner(address _owner) public {
        require(msg.sender == manager);
        _removeOwner(_owner);

    }

    function _addOwner(address _owner) internal {
        ownerByAddress[_owner] = true;
        
        owners.push(_owner);
        AddOwner(_owner);
    }

    function _removeOwner(address _owner) internal {

        if (owners.length == 0)
            return;

        ownerByAddress[_owner] = false;
        
        uint id = indexOf(_owner);
        remove(id);
        RemoveOwner(_owner);
    }

    function getOwners() public constant returns (address[]) {
        return owners;
    }

    function indexOf(address value) internal returns(uint) {
        uint i = 0;
        while (i < owners.length) {
            if (owners[i] == value) {
                break;
            }
            i++;
        }
    return i;
  }

  function remove(uint index) internal {
        if (index >= owners.length) return;

        for (uint i = index; i<owners.length-1; i++){
            owners[i] = owners[i+1];
        }
        delete owners[owners.length-1];
        owners.length--;
    }

}