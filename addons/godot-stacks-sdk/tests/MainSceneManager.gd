extends Node2D

const NftInfoCard = preload("res://addons/godot-stacks-sdk/tests/NftInfo.tscn")

onready var wallet_connector = $WalletConnector

onready var wallet_label = $UI/WalletLabel
onready var check_user_nfts_button = $UI/CheckUserNFTsButton
onready var nft_list_container = $UI/NftList/HBoxContainer
onready var nft_list_label = $UI/NftListLabel
onready var token_address_input = $UI/TokenAddress
onready var nft_error_label = get_node("%NftErrorLabel")

func _ready():
	nft_error_label.hide()
	# Get and display the wallet address
	wallet_label.text = "Wallet: " + StacksGlobals.wallet

# Queries user NFT data
func get_tokens() -> void:
	# Note: SP2W12MNM4SPV37VZHN4GCDG35G9ACG3FDKK7WF04 is the address for the
	# "MetaBoy - First Odyssey" collection.
	var token_address = token_address_input.text
	var json = Stacks.get_account_balance(StacksGlobals.wallet)
	
	if json is GDScriptFunctionState:
		json = yield(json, "completed")
	
	var account_balance = json.result
	
	# Clear the list of NFTs displayed
	for entry in nft_list_container.get_children():
		entry.queue_free()
	
	nft_error_label.hide()
	
	# Fetch the user's NFTs
	if account_balance.has("non_fungible_tokens"):
		var tokens : Dictionary = account_balance.get("non_fungible_tokens")
		if tokens.empty():
			nft_error_label.show()
			nft_error_label.text = "No NFTs found."
		else:
			var nft_found = false
			for key in tokens:
				var collection_address = key.split(".")[0]
				if collection_address == token_address_input.text:
					nft_found = true
					nft_list_label.text = "NFT Collection: " + str(key)
					# List the NFTs from the given collection address
					var asset_identifiers = [key]
					var nft_holdings_json = Stacks.get_nft_holdings(StacksGlobals.wallet, asset_identifiers)
					if nft_holdings_json is GDScriptFunctionState:
						nft_holdings_json = yield(nft_holdings_json, "completed")
					var nft_holdings = nft_holdings_json.result
					if nft_holdings.has("results"):
						var nft_results : Array = nft_holdings.get("results")
						for nft in nft_results:
							var nft_id = nft.get("value").get("repr")
							# NFT ID is an unsigned int, so it starts with "u"
							nft_id = str(nft_id).substr(1) 
							
							var nft_card = NftInfoCard.instance()
							nft_list_container.add_child(nft_card)
							nft_card.nft_name.text = "NFT ID: " + nft_id
							
							nft_card.set_nft_id(int(nft_id))
							var principal = key.split("::")[0]
							nft_card.set_principal(principal)
							nft_card.connect("fetch_metadata", self, "fetch_nft_metadata")
			if not nft_found:
				nft_error_label.show()
				nft_error_label.text = "No NFTs found."
	else:
		nft_error_label.show()
		nft_error_label.text = "Failed to get NFTs"

func fetch_nft_metadata(nft_card, principal: String, nft_id: int):
	var json = Stacks.get_nft_metadata(principal, nft_id)
	nft_card.fetch_metadata_button.disabled = true
	
	if json is GDScriptFunctionState:
		json = yield(json, "completed")
	
	var nft_metadata = json.result
	nft_card.nft_metadata.text = str(nft_metadata)
	nft_card.fetch_metadata_button.disabled = false

func _on_CheckUserNFTsButton_pressed():
	check_user_nfts_button.disabled = true
	check_user_nfts_button.text = "Fetching user's NFTs..."
	yield(get_tokens(), "completed")
	check_user_nfts_button.disabled = false
	check_user_nfts_button.text = "Check user's NFTs"

func _on_LogoutButton_pressed():
	Stacks.logout()
	get_tree().change_scene("res://addons/godot-stacks-sdk/tests/TestLogin.tscn")

