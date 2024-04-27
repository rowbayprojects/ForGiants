extends HBoxContainer


@onready var option_button = $OptionButton


const RESOLUTION_DICTIONARY : Dictionary = {
	"640 x 480" : Vector2i(640, 480),
	"1152 x 648" : Vector2i(1152, 648),
	"1280 x 720" : Vector2i(1280, 720),
	"1600 x 900" : Vector2i(1600, 900),
	"1980 x 1080" : Vector2i(1980, 1080),
	"2560 x 1440" : Vector2i(2560, 1440)
}


func _ready() -> void:
	option_button.item_selected.connect(on_resolution_selected)
	add_resolution_items()


func add_resolution_items() -> void:
	for resolution_size_text in RESOLUTION_DICTIONARY:
		option_button.add_item(resolution_size_text)


func on_resolution_selected(index : int) -> void:
	DisplayServer.window_set_size(RESOLUTION_DICTIONARY.values()[index])
