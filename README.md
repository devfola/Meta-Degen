 
# Degen Token
Degen Token is a token that players in the game can earn and then exchanged the token for rewards in the in-game store.

## Description
This is an ERC20 upgrade, which means it has all the functions of the ERC20 and also other functions.
It is meant to be a gamer token, where players of the game can earn the token, use the token for in-game transaction and also be able to send it to each other. Players can earn token, check their balance, transfer token, and redeem items on the platform witht their token. 

Aside from the normal ERC20 functions, it has additional 10 functions:

- playerRegister(string memory _playerName): allows players to register on the platform; without registration, players cannot access the platform.
- mint(address _to, uint256 _amount): allows the owner of the contract to mint (_amount) token to player (_to).
- playerP2PTransfer(address _recipient, uint256 _amount): allows players transfer tokens between themselves.
- playerCheckTokenBalance(): allows a user (msg.sender) to check his/her token balance in the contract.
- lockPlayerAccount(address player): allows owner/admin to lock the account of a player that offended or go against the rule of the platform.
- releasePlayerAccount(address player): allows owner/admin to unlock a player's account when forgiven.
- playerBurnsTheirToken(uint256 _amount): allows user (msg.sender) to burn (_amount) token no longer needed.
- ownerAddGameItem(string calldata _itemName, uint256 _amount): allows owner/admin to add items to the game-store for players to redeem.
- playerReedemItems(bytes32 _itemId): allows players to redeem items on the platform.
- getGameItem(bytes32 _itemId): returns an item with item id (_itemId).

## Getting Started
```git clone https://github.com/devfola/Meta-Degen.git``` to clone the project. 
After cloning the github, do the following to get the code running on your computer.

- Inside the project directory, in the terminal type: npm i
- Open two terminals in your VS code or your preferred IDE
- In the first terminal type: ```npx hardhat``` compile to compile your contracts
- In the second terminal type: ```npx hardhat node``` to set up local nodes
- Go back to the first terminal and type: ```npx hardhat run --network localhost scripts/deploy.js``` to deploy your contract
- To interact with the functions in the contract, you can create another file in the script folder to write your interaction scripts.

## Authors
Warith Adebowale

## License
This project is licensed under the MIT License - see the LICENSE.md file for details
