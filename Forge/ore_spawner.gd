extends Node2D


const obj_ore = preload("res://Forge/ore.tscn")

var ore_count : int = 0


func _ready() -> void:
	spawn_ore()


func spawn_ore() -> void:
	var ore_instance = obj_ore.instantiate()
	ore_instance.position = Vector2(randf_range(-80, 80), 0)
	add_child(ore_instance)


func _on_area_2d_body_entered(body):
	ore_count += 1


func _on_area_2d_body_exited(body):
	ore_count -= 1
	if ore_count <= 0:
		spawn_ore()
