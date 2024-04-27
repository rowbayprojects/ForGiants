extends ColorRect


@onready var resume_button : Button = $CenterContainer/MarginContainer/VBoxContainer/ResumeButton
@onready var options_button : Button = $CenterContainer/MarginContainer/VBoxContainer/OptionsButton
@onready var quit_button : Button = $CenterContainer/MarginContainer/VBoxContainer/QuitButton
@onready var options_menu : OptionsMenu = $OptionsMenu


func _ready() -> void:
	resume_button.pressed.connect(unpause)
	options_button.pressed.connect(on_options_pressed)
	quit_button.pressed.connect(get_tree().quit)


func unpause() -> void:
	get_tree().paused = false
	hide()
	resume_button.set_deferred("disabled", true)
	options_button.set_deferred("disabled", true)
	quit_button.set_deferred("disabled", true)


func pause() -> void:
	get_tree().paused = true
	show()
	resume_button.set_deferred("disabled", false)
	options_button.set_deferred("disabled", false)
	quit_button.set_deferred("disabled", false)


func on_options_pressed() -> void:
	$CenterContainer.hide()
	options_menu.show()
	options_menu.set_process(true)


func _on_options_menu_exit_options_menu():
	$CenterContainer.show()
	options_menu.hide()
	options_menu.set_process(false)
