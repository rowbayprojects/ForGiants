extends Node2D


var room_size : Vector2i
@onready var camera_man = get_tree().get_first_node_in_group("camera_man")


func set_room_area_size():
	$Area2D/CollisionShape2D.shape.extents = Vector2(160 * room_size.x - 10, 88 * room_size.y - 16)
	$Area2D.position = Vector2(160 * room_size.x, 88 * room_size.y)


func set_room_size(room_width, room_height):
	room_size = Vector2i(room_width, room_height)
	set_room_area_size()


func _on_area_2d_body_entered(_body):
	camera_man.set_room_size(room_size)
	camera_man.set_current_room_location(global_position + Vector2(160, 88))
	camera_man.camera_transition()
