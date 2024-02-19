# godot-stacks-sdk
A simple SDK to integrate Stacks into Godot.

### Note: This project is still a work-in-progress.

To-Do's:
- Mobile is untested

## Features
- User login/logout through Leather wallet.
- Fetch the user's NFT balance and Ordinals.

## API Calls
API calls are implemented based on Hiro's hosted API. See `TestMainScene.tscn` for an example scene of how to use them. More can be added to the `Stacks.gd` script.

## Getting Started
Download Godot 4.2.1, and then either clone this repository and import the project, or copy the `addons/godot-stacks-sdk` directory into your own project's `addons` directory and enable the SDK from Godot's plugins menu.

### Wallet Login/Logout
See `TestLogin.tscn` for an example login scene.

To connect to a user's wallet, add a Node with the `WalletConnector.gd` script attached to it. Then you can call WalletConnector's `connect_to_wallet()` function and `StacksGlobals.set_wallet_type()` with the wallet type the user picks (currently only `NONE` and `STACKS`). The wallet type needs to be passed into the above functions for the connection process to carry out properly.

When a wallet connection succeeds or fails, `WalletConnector.gd` emits a `wallet_connected` signal with the wallet string as its parameter. An empty string means the connection failed somehow, in which case you'll want to clear all global wallet data with `StacksGlobals.clear_wallet()`. If the connection was successful, you can save the user's wallet and wallet type by writing to a ConfigFile, which lets you keep the user logged in. In the example login scene, we check if there's a user config file saved on ready, and we skip the login screen if a wallet is found.

You can log out the user by calling `Stacks.logout()`, which deletes all data from the config file located at `StacksGlobals.USER_DATA_SAVE_PATH` and from the `StacksGlobals` singleton itself.

### Using the Stacks API
See `TestMainScene.tscn` for an example on how to use the Stacks API. Note that this scene also has its own node with `WalletConnector.gd` attached to it.

## Notes
- C# is currently not used because Godot 4.2.1 does not support C# for web builds, but for now, the SDK's current features still work.
