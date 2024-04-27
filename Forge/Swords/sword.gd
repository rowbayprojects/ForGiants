extends CharacterBody2D


const obj_fireball = preload("res://Forge/fireball.tscn")

var forging_progress : int = 0
@export var forging_threshold : int = 3

@onready var collision = $CollisionShape2D


func check_progress() -> void:
	if forging_progress >= forging_threshold:
		forging_progress = 0
		if $Sprite2D.frame < 3:
			$Sprite2D.frame += 1
		else:
			$Sprite2D.frame += 1
			get_tree().get_first_node_in_group("forge_controller").finish_forging_process()


func add_forging_progress(value : int) -> void:
	forging_progress += value
	check_progress()


func shoot(direction : float, speed : float, spawn_position : Vector2) -> void:
	var new_fireball = obj_fireball.instantiate()
	new_fireball.velocity = Vector2(speed, 0).rotated(deg_to_rad(direction))
	new_fireball.position = spawn_position
	new_fireball.rotate(deg_to_rad(direction - 90))
	print(new_fireball.rotation)
	get_parent().add_child(new_fireball)


func appear() -> void:
	forging_progress = 0
	$Sprite2D.frame = 0
	visible = true
	$CollisionShape2D.set_deferred("disabled", false)
	set_collision_layer_value(3, true)


func disappear() -> void:
	$EndTimer.start()


func _on_end_timer_timeout():
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	set_collision_layer_value(3, false)
