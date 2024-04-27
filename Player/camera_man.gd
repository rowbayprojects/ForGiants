extends CharacterBody2D


const CAMERA_MAX_DISTANCE : float = 60

var camera_limit = 0.01

var camera_time_x = 0
var pause_time = 0

var camera_lock_x = false
var in_transition = false
var room_size : Vector2i
var current_room_location : Vector2 # Top-left corner of the room
var entrance_location : Vector2i

var tween : Tween
var damage_tween : Tween

@onready var player = get_tree().get_first_node_in_group("player")


func _process(delta):
	
	if pause_time > 0:
		pause_time -= 1
	
	if Input.is_action_just_pressed("pause") and pause_time <= 0:
		$Control/UI/PauseMenu.pause()
		pause_time = 10
	
	if not in_transition:
		follow_player(delta)
		clamp_camera_to_room()


func update_ui(money_amount : int, ore_amount : int) -> void:
	$Control/UI/Control/Money/Label.text = str(money_amount)
	$Control/UI/Control/Ore/Label2.text = str(ore_amount)


func shake_ui(type : String) -> void:
	var ui_element : Control
	if type == "money":
		ui_element = $Control/UI/Control/Money
	else:
		ui_element = $Control/UI/Control/Ore
	
	var shake_tween = create_tween()
	shake_tween.set_ease(Tween.EASE_IN_OUT)
	shake_tween.set_trans(Tween.TRANS_SINE)
	
	var shake : float = 15
	var shake_count : int = 5
	var shake_duration : float = 0.1
	
	ui_element.modulate = Color(1.0, 0.2, 0.2)
	
	for i in shake_count:
		shake_tween.tween_property(ui_element, "position", Vector2(randf_range(-shake, shake), randf_range(-shake, shake)), shake_duration / shake_count)
	shake_tween.tween_property(ui_element, "position", Vector2.ZERO, shake_duration / shake_count)
	
	await shake_tween.finished
	
	ui_element.modulate = Color(1.0, 1.0, 1.0)
	


func follow_player(delta):
	if global_position.x - player.global_position.x > CAMERA_MAX_DISTANCE + 0.5:
		global_position.x = player.global_position.x + CAMERA_MAX_DISTANCE
		camera_time_x = 0
		camera_lock_x = true
	elif global_position.x - player.global_position.x < -CAMERA_MAX_DISTANCE - 0.5:
		global_position.x = player.global_position.x - CAMERA_MAX_DISTANCE
		camera_time_x = 0
		camera_lock_x = true
	else:
		if camera_lock_x:
			camera_time_x += 1
			if camera_time_x >= (camera_limit * 1 / delta):
				camera_lock_x = false
		else:
			var t_x = abs(global_position.x - player.global_position.x) / CAMERA_MAX_DISTANCE
			global_position.x = lerp(global_position.x, player.global_position.x, 1.2 * delta * smoothstep(0.0, 1.0, t_x))
	var t_y = abs(global_position.y - player.global_position.y) / CAMERA_MAX_DISTANCE
	global_position.y = lerp(global_position.y, player.global_position.y, 1.2 * delta * t_y)


func set_room_size(room_size_temp : Vector2i):
	room_size = room_size_temp


func set_current_room_location(location : Vector2):
	current_room_location = location


func determine_entrance_location_from_player():
	var entrance_location_x = floor((player.global_position.x + 160 - current_room_location.x) / 320)
	var entrance_location_y = floor((player.global_position.y + 88 - current_room_location.y) / 176)
	entrance_location = Vector2i(entrance_location_x, entrance_location_y)


func clamp_camera_to_room() -> void:
	
	var leftmost_room_location = current_room_location.x
	var rightmost_room_location = current_room_location.x + (room_size.x - 1) * 320
	var topmost_room_location = current_room_location.y
	var bottommost_room_location = current_room_location.y + (room_size.y - 1) * 176
	
	global_position.x = clamp(global_position.x, leftmost_room_location, rightmost_room_location)
	global_position.y = clamp(global_position.y, topmost_room_location, bottommost_room_location)


func camera_transition() -> void:
	
	determine_entrance_location_from_player()
	in_transition = true
	
	var transition_time = 1.0
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "global_position", current_room_location + Vector2(320 * entrance_location.x, 176 * entrance_location.y), transition_time)
	
	await tween.finished
	
	in_transition = false


func damage_screen() -> void:
	
	if damage_tween:
		damage_tween.kill()
	
	damage_tween = create_tween()
	
	damage_tween.set_ease(Tween.EASE_IN_OUT)
	damage_tween.set_trans(Tween.TRANS_SINE)
	damage_tween.tween_property($Control/DialogBox/TextureRect2, "modulate:a", 1.0, 0.2)
	damage_tween.tween_property($Control/DialogBox/TextureRect2, "modulate:a", 0.0, 0.2)
	


func _on_camera_lock_x_timer_timeout():
	camera_lock_x = false
