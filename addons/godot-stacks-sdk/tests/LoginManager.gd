extends Node

onready var button_stacks_wallet = get_node("%ButtonStacksWallet")

onready var wallet_connector = $WalletConnector

onready var loading_rect = $LoadingRect
onready var loading_label = $LoadingLabel
onready var loading_cancel_button = $LoadingCancelButton

func _ready():
	hide_loading_ui()
	
	var user_config = ConfigFile.new()
	var err = user_config.load(StacksGlobals.USER_DATA_SAVE_PATH)
	if err == ERR_FILE_NOT_FOUND:
		print("No user data found.")
	elif err != OK:
		print("Error when attempting to load user data.")
	else:
		var account = user_config.get_value(StacksGlobals.DATA_SECTION, "StacksAccount", "")
		var wallet_type = user_config.get_value(StacksGlobals.DATA_SECTION, "StacksWalletType", -1)
		if account != null and account != "" and wallet_type != null and StacksGlobals.is_valid_wallet_type(wallet_type):
			# Wallet account detected, skip the login screen
			StacksGlobals.wallet = account
			StacksGlobals.set_wallet_type(wallet_type)
			get_tree().change_scene("res://addons/godot-stacks-sdk/tests/TestMainScene.tscn")
	
	# Connect the buttons to their respective callbacks
	button_stacks_wallet.connect("pressed", self, "Button_StacksWallet")
	
	# Connect the WalletConnector signal to handle wallet sign in
	wallet_connector.connect("wallet_connected", self, "_on_wallet_connected")

func Button_StacksWallet():
	show_loading_ui()
	wallet_connector.connect_to_wallet("stacks")
	StacksGlobals.set_wallet_type(StacksGlobals.WalletType.STACKS)

func _on_wallet_connected(wallet: String):
	if wallet == null or wallet.empty():
		print("Failed to connect wallet.")
		StacksGlobals.clear_wallet()
		hide_loading_ui()
		return
	
	# At this point, StacksGlobals.wallet should be set.
	print("Connected with wallet: " + wallet)
	save_user_login()
	get_tree().change_scene("res://addons/godot-stacks-sdk/tests/TestMainScene.tscn")

func save_user_login() -> void:
	var user_config = ConfigFile.new()
	var err = user_config.load(StacksGlobals.USER_DATA_SAVE_PATH)
	if err != OK:
		user_config = ConfigFile.new()
	user_config.set_value(StacksGlobals.DATA_SECTION, "StacksAccount", StacksGlobals.wallet)
	user_config.set_value(StacksGlobals.DATA_SECTION, "StacksWalletType", StacksGlobals.current_wallet_type)
	user_config.save(StacksGlobals.USER_DATA_SAVE_PATH)

func show_loading_ui() -> void:
	loading_rect.show()
	loading_label.show()
	loading_cancel_button.show()

func hide_loading_ui() -> void:
	loading_rect.hide()
	loading_label.hide()
	loading_cancel_button.hide()

func _on_LoadingCancelButton_pressed():
	hide_loading_ui()
