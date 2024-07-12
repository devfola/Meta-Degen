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
    GameProp[] public degenProps;

    struct Player {
        address playerAddress;
        string playerName;
        bool isRegistered;
    }

    struct GameProp {
        address currentOwner;
        bytes32 propId;
        string propName;
        uint256 amount;
    }

    mapping(address => Player) public players;
    mapping(bytes32 => GameProp) public gameProps;
    mapping(address => mapping(bytes32 => GameProp)) public playerProps;

    event PlayerRegisters(address player, bool success);
    event PlayerP2P(address sender, address recipient, uint256 amount);
    event TokenBurnt(address owner, uint256 amount);
    event propsCreated(address creator, bytes32 propId);
    event PropRedeemed(address newOwner, bytes32 propId, string propName);

    constructor() ERC20("Degen", "DGN") Ownable(msg.sender) {}

    function addressZeroCheck() private view {
        if (msg.sender == address(0)) revert ZERO_ADDRESS_NOT_ALLOWED();
    }

    function isRegistered() private view {
        if (!players[msg.sender].isRegistered) revert YOU_ARE_NOT_REGISTERED();
    }

    function playerRegister(string memory _playerName) external {
        if (players[msg.sender].playerAddress != address(0))
            revert YOU_HAVE_REGISTERED();

        Player storage _player = players[msg.sender];
        _player.playerAddress = msg.sender;
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

    function ownerAddGameProps(string calldata _propName, uint256 _amount)
        external
        onlyOwner
    {
        bytes32 _propId = keccak256(abi.encodePacked(_propName, _amount));

        GameProp storage _gameProp = gameProps[_propId];
        _gameProp.currentOwner = address(this);
        _gameProp.propId = _propId;
        _gameProp.propName = _propName;
        _gameProp.amount = _amount;

        degenProps.push();

        emit propsCreated(address(this), _propId);
    }

    function playerRedeemProp(bytes32 _propId) external {
        isRegistered();

        GameProp storage _gameProp = gameProps[_propId];

        uint256 _amount = _gameProp.amount;

        if (balanceOf(msg.sender) < _amount) revert INSUFFICIENT_BALANCE();

        transfer(address(this), _amount);

        _gameProp.currentOwner = msg.sender;

        playerProps[msg.sender][_propId] = _gameProp;

        emit PropRedeemed(msg.sender, _propId, _gameProp.propName);
    }
}
//0x5f649f8ff0cd9201a37975ebc604b955353474fff3cbecc6dec8308ab68f4e92
//0x76f5f907b606e4cdc6f91b3d4d30e9590ac243d5e7dbd66fea53666fbc907462
//0x74df9e1dc16c096da37a8b3924819f887c40cc3da095bc0dd517fb1eda04bf04