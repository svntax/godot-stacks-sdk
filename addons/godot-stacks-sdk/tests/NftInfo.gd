extends PanelContainer

# Simple display for Stacks NFTs

signal fetch_metadata(card, principal, nft_id)

var nft_id : int = -1
var principal : String = ""
onready var nft_name = get_node("%Name")
onready var nft_metadata = get_node("%Metadata")
onready var nft_image = get_node("%NftImage")
onready var fetch_metadata_button = get_node("%FetchMetadataButton")

func _ready():
	fetch_metadata_button.connect("pressed", self, "_fetch_metadata_pressed")

func set_nft_id(id: int):
	nft_id = id

func set_principal(address: String):
	principal = address

func _fetch_metadata_pressed():
	emit_signal("fetch_metadata", self, principal, nft_id)
