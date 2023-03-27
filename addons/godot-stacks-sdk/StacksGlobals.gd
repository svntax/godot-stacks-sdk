extends Node

enum WalletType { NONE, STACKS }
var current_wallet_type = WalletType.NONE

var wallet : String = ""

const USER_DATA_SAVE_PATH = "user://user_data.cfg"
const DATA_SECTION = "StacksData" # Name of the section in the user data file that contains the user's info.

func set_wallet_type(wallet_type: int) -> void:
	current_wallet_type = wallet_type

func clear_wallet() -> void:
	wallet = ""
	current_wallet_type = WalletType.NONE

func is_valid_wallet_type(wallet_type: int) -> bool:
	return wallet_type in [WalletType.STACKS]
