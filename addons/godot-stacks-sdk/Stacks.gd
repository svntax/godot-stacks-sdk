extends Node

# For testnet, replace `mainnet` with `testnet`
var api_endpoint = "https://api.mainnet.hiro.so"

# https://hirosystems.github.io/stacks-blockchain-api/#tag/Accounts/operation/get_account_balance
func get_account_balance(principal: String):
	var url_format = api_endpoint + "/extended/v1/address/{principal}/balances"
	var url = url_format.format({"principal": principal})
	var headers = ["Content-Type: application/json"]
	var use_ssl = true
	
	var api_result = query_api(url, headers, use_ssl, HTTPClient.METHOD_GET)
	
	if api_result is GDScriptFunctionState:
		api_result = yield(api_result, "completed")
	
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
	var use_ssl = true
	
	var api_result = query_api(url, headers, use_ssl, HTTPClient.METHOD_GET)
	
	if api_result is GDScriptFunctionState:
		api_result = yield(api_result, "completed")
	
	return api_result

# https://docs.hiro.so/metadata/#tag/Tokens/operation/getNftMetadata
func get_nft_metadata(principal: String, token_id: int):
	var url_format = api_endpoint + "/metadata/v1/nft/{principal}/{token_id}"
	var url = url_format.format({"principal": principal, "token_id": token_id})
	var headers = ["Content-Type: application/json"]
	var use_ssl = true
	
	var api_result = query_api(url, headers, use_ssl, HTTPClient.METHOD_GET)
	
	if api_result is GDScriptFunctionState:
		api_result = yield(api_result, "completed")
	
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

func query_api(url: String, headers: Array, use_ssl: bool, method: int, query: String = "") -> Dictionary:
	var http = HTTPRequest.new()
	add_child(http)
	http.request(url, headers, use_ssl, method, query)
	
	# [result, status code, response headers, body]
	var response = yield(http, "request_completed")
	if response[0] != OK:
		var message = "An error occurred in the HTTP request."
		push_error(message)
		return create_error_response(message)
	
	var body = response[3]
	var json = JSON.parse(body.get_string_from_utf8())
	if json.error != OK:
		var message = "Error when parsing JSON response."
		push_error(message)
		return create_error_response(message)
	
	http.queue_free()
	
	return json

# Format for error messages
func create_error_response(message: String) -> Dictionary:
	return {
		"error": {
			"message": message
		}
	}
