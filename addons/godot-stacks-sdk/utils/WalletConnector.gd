extends Node

signal wallet_connected(wallet)

# JavaScript methods for web API

var connect_to_wallet_callback = JavaScript.create_callback(self, "_on_wallet_connected")
func connect_to_wallet(wallet_name: String) -> void:
	var window = JavaScript.get_interface("window")
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
	
	# https://hirowallet.gitbook.io/developers/bitcoin/connect-users/request-addresses
	wallet_provider.request("getAddresses").then(connect_to_wallet_callback)

func _on_wallet_connected(res):
	# Response is [[JavaScriptObject]]
	var json = res[0]
	if json.result:
		var json_addresses = json.result.addresses # Array of addresses.
		var js_json = JavaScript.get_interface("JSON")
		var json_string = js_json.stringify(json_addresses)
		var parsed_json = JSON.parse(json_string)
		if parsed_json.error == OK:
			var addresses = parsed_json.result
			# Search for the STX address
			for address_obj in addresses:
				var symbol = address_obj.symbol
				if symbol == "STX":
					StacksGlobals.wallet = address_obj.address
	
	emit_signal("wallet_connected", StacksGlobals.wallet)
