extends Node

# For testnet, replace `mainnet` with `testnet`
var api_endpoint = "https://api.mainnet.hiro.so"

var ordinals_api_endpoint = "https://api.hiro.so"

# https://hirosystems.github.io/stacks-blockchain-api/#tag/Accounts/operation/get_account_balance
func get_account_balance(principal: String):
	var url_format = api_endpoint + "/extended/v1/address/{principal}/balances"
	var url = url_format.format({"principal": principal})
	var headers = ["Content-Type: application/json"]
	var api_result = await query_api(url, headers, HTTPClient.METHOD_GET)
	
	return api_result

# https://hirosystems.github.io/stacks-blockchain-api/#tag/Non-Fungible-Tokens/operation/get_nft_holdings
func get_nft_holdings(principal: String, asset_identifiers: Array, \
		limit: int = 50, offset: int = 0, unanchored: bool = false, tx_metadata: bool = false):
	var url_format = api_endpoint + "/extended/v1/tokens/nft/holdings?principal={principal}"
	var url = url_format.format({"principal": principal})
	
	for asset_id in asset_identifiers:
		url += "&asset_identifiers=" + asset_id
	if limit >= 0:
		url += "&limit=" + str(limit)
	if offset > 0:
		url += "&offset=" + str(offset)
	if unanchored:
		url += "&unanchored=" + str(unanchored)
	if tx_metadata:
		url += "&tx_metadata=" + str(tx_metadata)
	
	var headers = ["Content-Type: application/json"]
	var api_result = await query_api(url, headers, HTTPClient.METHOD_GET)
	
	return api_result

# https://docs.hiro.so/metadata/#tag/Tokens/operation/getNftMetadata
func get_nft_metadata(principal: String, token_id: int):
	var url_format = api_endpoint + "/metadata/v1/nft/{principal}/{token_id}"
	var url = url_format.format({"principal": principal, "token_id": token_id})
	var headers = ["Content-Type: application/json"]
	
	var api_result = await query_api(url, headers, HTTPClient.METHOD_GET)
	
	return api_result

# Ordinals API

# https://docs.hiro.so/ordinals/list-of-inscriptions
func get_inscriptions(params: Dictionary):
	var url = ordinals_api_endpoint + "/ordinals/v1/inscriptions"
	if not params.is_empty():
		url += "?"
		var first_param = true
		
		if params.has("addresses"):
			var addresses : Array = params.get("addresses", [])
			if addresses.is_empty():
				return create_error_response("No BTC addresses found.")
			
			for address in addresses:
				if not first_param:
					url += "&"
				first_param = false
				url += "address=" + str(address)
		
		if params.has("limit"):
			var limit : int = params.get("limit", 20)
			if not first_param:
				url += "&"
			first_param = false
			url += "limit=" + str(limit)
		
		if params.has("offset"):
			var offset : int = params.get("offset", 0)
			if not first_param:
				url += "&"
			first_param = false
			url += "offset=" + str(offset)
	
	var headers = ["Content-Type: application/json"]
	var api_result = await query_api(url, headers, HTTPClient.METHOD_GET)
	
	return api_result

# https://docs.hiro.so/ordinals/specific-inscription
func get_inscription(inscription_id):
	var url_format = ordinals_api_endpoint + "/ordinals/v1/inscriptions/{id}"
	var url = url_format.format({"id": inscription_id})
	var headers = ["Content-Type: application/json"]
	var api_result = await query_api(url, headers, HTTPClient.METHOD_GET)
	
	return api_result

# Clears the user's wallet and related data from the saved config file.
func logout() -> void:
	StacksGlobals.clear_wallet()
	var save_path = StacksGlobals.USER_DATA_SAVE_PATH
	var data_section = StacksGlobals.DATA_SECTION
	
	var user_config = ConfigFile.new()
	var err = user_config.load(save_path)
	if err == ERR_FILE_NOT_FOUND:
		print("No user data found.")
	elif err != OK:
		print("Error when attempting to load user data.")
	else:
		if user_config.has_section(data_section):
			user_config.erase_section(data_section)
			user_config.save(save_path)

func query_api(url: String, headers: Array, method: int, query: String = "") -> Dictionary:
	var http = HTTPRequest.new()
	add_child(http)
	http.request(url, headers, method, query)
	
	# [result, status code, response headers, body]
	var response = await http.request_completed
	if response[0] != OK:
		var message = "An error occurred in the HTTP request."
		push_error(message)
		return create_error_response(message)
	
	var body = response[3]
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var json_data = json.get_data()
	
	http.queue_free()
	
	return json_data

# Format for error messages
func create_error_response(message: String) -> Dictionary:
	return {
		"error": {
			"message": message
		}
	}
