extends Control


@onready var start_button : Button = $VBoxContainer2/VBoxContainer/StartButton
@onready var options_button : Button = $VBoxContainer2/VBoxContainer/OptionsButton
@onready var quit_button : Button = $VBoxContainer2/VBoxContainer/QuitButton
@onready var options_menu : OptionsMenu = $OptionsMenu


func _ready():
	get_viewport().size = DisplayServer.screen_get_size()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	get_tree().paused = true
	start_button.pressed.connect(start_game)
	options_button.pressed.connect(on_options_pressed)
	quit_button.pressed.connect(get_tree().quit)


func start_game() -> void:
	get_tree().paused = false
	hide()
	start_button.set_deferred("disabled", true)
	options_button.set_deferred("disabled", true)
	quit_button.set_deferred("disabled", true)


func on_options_pressed() -> void:
	$VBoxContainer2/VBoxContainer.hide()
	$VBoxContainer2/MarginContainer.hide()
	options_menu.show()
	options_menu.set_process(true)


func _on_options_menu_exit_options_menu():
	$VBoxContainer2/VBoxContainer.show()
	$VBoxContainer2/MarginContainer.show()
	options_menu.hide()
	options_menu.set_process(false)
