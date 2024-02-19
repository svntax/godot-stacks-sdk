extends Node

enum WalletType { NONE, STACKS }
var current_wallet_type = WalletType.NONE

var wallet : String = ""
var btc_addresses : Array = []

const USER_DATA_SAVE_PATH = "user://user_data.cfg"
const DATA_SECTION = "StacksData" # Name of the section in the user data file that contains the user's info.

func set_wallet_type(wallet_type: int) -> void:
	current_wallet_type = wallet_type

func clear_wallet() -> void:
	wallet = ""
	clear_bitcoin_addresses()
	current_wallet_type = WalletType.NONE

func clear_bitcoin_addresses() -> void:
	btc_addresses.clear()

func is_valid_wallet_type(wallet_type: int) -> bool:
	return wallet_type in [WalletType.STACKS]
