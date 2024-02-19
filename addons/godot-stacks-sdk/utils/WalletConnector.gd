extends Node

signal wallet_connected(wallet)

# JavaScript methods for web API

var connect_to_wallet_callback = JavaScriptBridge.create_callback(_on_wallet_connected)
func connect_to_wallet(wallet_name: String) -> void:
	var window = JavaScriptBridge.get_interface("window")
	var wallet_provider = null
	var wallet = wallet_name.to_lower()
	
	match wallet:
		"stacks":
			wallet_provider = window.StacksProvider
		_:
			window.alert("Wallet not set!")
	
	if !wallet_provider:
		emit_signal("wallet_connected", "")
		return
	
	# https://leather.gitbook.io/developers/bitcoin/connect-users/get-addresses
	wallet_provider.request("getAddresses").then(connect_to_wallet_callback)

func _on_wallet_connected(res):
	# Response is [[JavaScriptObject]]
	var json_response = res[0]
	if json_response.result:
		var json_addresses = json_response.result.addresses # Array of addresses.
		var js_json = JavaScriptBridge.get_interface("JSON")
		var json_string = js_json.stringify(json_addresses)
		var json = JSON.new()
		json.parse(json_string)
		var addresses_array = json.get_data()
		# Search for the STX address
		for address_obj in addresses_array:
			var symbol = address_obj.symbol
			if symbol == "STX":
				StacksGlobals.wallet = address_obj.address
			elif symbol == "BTC":
				StacksGlobals.btc_addresses.append(address_obj.address)
	
	emit_signal("wallet_connected", StacksGlobals.wallet)
