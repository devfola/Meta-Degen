// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error ZERO_ADDRESS_NOT_ALLOWED();
error MAXIMUM_TOKEN_SUPPLY_REACHED();
error INSUFFICIENT_ALLOWANCE_BALANCE();
error INSUFFICIENT_BALANCE();
error ONLY_OWNER_IS_ALLOWED();
error BALANCE_MORE_THAN_TOTAL_SUPPLY();
error CANNOT_BURN_ZERO_TOKEN();
error ONLY_OWNER_OF_THE_ERC20_CAN_DEPLOY_THIS_CONTRACT();
error YOU_HAVE_REGISTERED();
error OWNER_CANNOT_REGISTER();
error N0_PLAYERS_TO_REWARD();
error YOU_CANNOT_TRANSFER_TO_ADDRESS_ZERO();
error TRANSFER_FAILED();
error YOU_ARE_NOT_REGISTERED();
error PLAYER_DOES_NOT_EXIST();
error PLAYER_NOT_SUSPENDED();
error PROP_DOES_NOT_EXIST();
error THE_RECEIVER_IS_NOT_A_PLAYER();
error PLAYER_NOT_REGISTERED();
error CANNOT_TRANSFER_ADDRESS_ZERO();

contract DegenToken is ERC20, Ownable {
    struct Player {
        address player;
        string playerName;
        bool isRegistered;
    }

    struct GameItem {
        string itemName;
        address owner;
        bytes32 _itemId;
        uint256 amount;
    }

    mapping(address => Player) players;
    mapping(bytes32 => GameItem) gameItems;
    mapping(address => mapping(bytes32 => GameItem)) playerItems;

    event PlayerRegisters(address player, bool success);

    event PlayerP2P(address sender, address recipient, uint256 amount);
    event TokenBurnt(address owner, uint256 _amount);
    event ItemCreated(
        address owner,
        string _itemName,
        bytes32 _itemId,
        uint256 _amount
    );
    event ItemReedemed(address newOwner, bytes32 _itemId, string itemName);

    constructor() ERC20("Degen", "DGN") Ownable() {}

    function addressZeroCheck() private view {
        if (msg.sender == address(0)) revert ZERO_ADDRESS_NOT_ALLOWED();
    }

    function isRegistered() private view {
        if (!players[msg.sender].isRegistered) revert YOU_ARE_NOT_REGISTERED();
    }

    function playerRegister(string memory _playerName) external {
        if (players[msg.sender].player != address(0))
            revert YOU_HAVE_REGISTERED();

        Player storage _player = players[msg.sender];
        _player.player = msg.sender;
        _player.playerName = _playerName;
        _player.isRegistered = true;

        emit PlayerRegisters(msg.sender, true);
    }

    function mint(address _to, uint256 _amount) public onlyOwner {
        if (!players[_to].isRegistered) revert PLAYER_NOT_REGISTERED();
        _mint(_to, _amount);
    }

    function playerP2PTransfer(address _recipient, uint256 _amount)
        external
        returns (bool)
    {
        isRegistered();
        if (_recipient == address(0)) revert CANNOT_TRANSFER_ADDRESS_ZERO();
        if (!players[_recipient].isRegistered) revert PLAYER_NOT_REGISTERED();

        if (transfer(_recipient, _amount)) {
            emit PlayerP2P(msg.sender, _recipient, _amount);
            return true;
        }

        revert TRANSFER_FAILED();
    }

    function playerCheckTokenBalance() external view returns (uint256) {
        isRegistered();
        return balanceOf(msg.sender);
    }

    function lockPlayerAccount(address player) external onlyOwner {
        Player storage _player = players[player];
        if (!_player.isRegistered) revert PLAYER_DOES_NOT_EXIST();

        _player.isRegistered = false;
    }

    function releasePlayerAccount(address player) external onlyOwner {
        Player storage _player = players[player];
        if (_player.isRegistered) revert PLAYER_NOT_SUSPENDED();

        _player.isRegistered = true;
    }

    function playerBurnsTheirToken(uint256 _amount) external {
        isRegistered();

        _burn(msg.sender, _amount);

        emit TokenBurnt(msg.sender, _amount);
    }

    function OwnerAddGameItem(string calldata _itemName, uint256 _amount)
        external
        onlyOwner
    {
        bytes32 _itemId = keccak256(abi.encodePacked(_itemName, _amount));

        GameItem storage _gameStorage = gameItems[_itemId];
        _gameStorage.owner = address(this);
        _gameStorage._itemId = _itemId;
        _gameStorage.itemName = _itemName;
        _gameStorage.amount = _amount;

        emit ItemCreated(address(this), _itemName, _itemId, _amount);
    }

    function playerReedemItems(bytes32 _itemId) external {
        isRegistered();

        GameItem storage _item = gameItems[_itemId];

        uint256 _amount = _item.amount;

        if (balanceOf(msg.sender) < _amount) revert INSUFFICIENT_BALANCE();

        transfer(address(this), _amount);

        _item.owner = msg.sender;

        playerItems[msg.sender][_itemId] = _item;

        emit ItemReedemed(msg.sender, _itemId, _item.itemName);
    }

    function getGameItem(bytes32 _itemId)
        external
        view
        returns (GameItem memory _gameItem)
    {
        isRegistered();
        _gameItem = gameItems[_itemId];
    }
}

//0xf9f6b541efe8dd64aef0938436681e680a4a21b21eacee81e7053d9c9c243291
