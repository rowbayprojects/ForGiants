extends Node2D


var forge_level : int = 1
var sword

var sword_center : Vector2 = Vector2.ZERO
var sword_width : float = 0
var sword_height : float = 0


var time : int = 0


func _ready() -> void:
	set_forge_level(1)


func begin_forging_process():
	
	if get_tree().get_first_node_in_group("player").ore >= forge_level:
		
		get_tree().get_first_node_in_group("player").call("add_ore", -forge_level)
		
		get_tree().get_first_node_in_group("dialog_box").next_dialog("dialog_forging")
		
		$ForgeDoor/AnimationPlayer.play("close")
		
		sword.appear()
		
		$AnimationPlayer.play("forging_begin")
		
		$ForgeCeilingBlocker/CollisionShape2D.set_deferred("disabled", false)
		
		$ForgeTimer.start()
	
	else:
		
		get_tree().get_first_node_in_group("camera_man").shake_ui("ore")
		
		await get_tree().create_timer(0.3).timeout		
		$Lever.reset_sprite()


func finish_forging_process() -> void:
	
	$AnimationPlayer.play("forging_finish")
	
	sword.disappear()
	
	$Lever.reset_sprite()
	
	$ForgeTimer.stop()
	
	$ForgeTimer.wait_time = 0
	
	$ForgeCeilingBlocker/CollisionShape2D.set_deferred("disabled", true)
	
	$ForgeDoor/AnimationPlayer.play("open")
	
	get_tree().get_first_node_in_group("player").call("add_money", 20 * pow(2, forge_level - 1))


func finish_forging_process_without_rewards() -> void:
	
	if $ForgeTimer.time_left > 0:
	
		$AnimationPlayer.play("forging_finish")
		
		sword.disappear()
		
		$Lever.reset_sprite()
		
		$ForgeTimer.stop()
		
		$ForgeTimer.wait_time = 0
		
		$ForgeCeilingBlocker/CollisionShape2D.set_deferred("disabled", true)
		
		$ForgeDoor/AnimationPlayer.play("open")


func upgrade_forge() -> void:
	var money_cost = 0
	match forge_level:
		1:
			money_cost = 20
		2:
			money_cost = 60
		3:
			money_cost = 120
	
	if get_tree().get_first_node_in_group("player").money >= money_cost:
		set_forge_level(forge_level + 1)
		get_tree().get_first_node_in_group("player").call("add_money", -money_cost)
	else:
		get_tree().get_first_node_in_group("camera_man").shake_ui("money")


func set_forge_level(value : int):
	
	if value > 3:
		return
	
	forge_level = value
	get_tree().get_first_node_in_group("forge_room").set_room_size(1, value)
	get_tree().get_first_node_in_group("camera_man").set_room_size(Vector2i(1, value))
	
	match forge_level:
		1: # Small Sword
			sword = $SmallSword
			sword_center = Vector2(0, 0)
			sword_width = 12
			sword_height = 103
			
			$Hot.position = Vector2(0, 80)
		2: # Medium Sword
			sword = $MediumSword
			sword_center = Vector2(0, 164.5 - 92.5)
			sword_width = 16
			sword_height = 247
			
			$Hot.position = Vector2(0, 256)
			
			$ForgeDividerLevel2/AnimationPlayer.play("open")
		3: # Big Sword
			sword = $BigSword
			sword_center = Vector2(0, 247.5 - 92.5)
			sword_width = 24
			sword_height = 369
			
			$Hot.position = Vector2(0, 415)
			
			$ForgeDividerLevel3/AnimationPlayer.play("open")


func get_random_position_on_sword() -> Vector2:
	
	var random_x_on_sword = randf_range(sword_center.x - sword_width / 2, sword_center.x + sword_width / 2)
	var random_y_on_sword = randf_range(sword_center.y - sword_height / 2, sword_center.y + sword_height / 2)
	
	return Vector2(random_x_on_sword, random_y_on_sword)


func _on_timer_timeout():
	time += 1
	
	if time >= 13:
		match forge_level:
			1:
				sword.shoot(randf_range(-45, -135), 100, get_random_position_on_sword())
			2:
				sword.shoot(randf_range(-45, -135), 100, get_random_position_on_sword())
				await get_tree().create_timer(0.1).timeout
				sword.shoot(randf_range(-45, -135), 100, get_random_position_on_sword())
			3:
				sword.shoot(randf_range(-45, -135), 100, get_random_position_on_sword())
				await get_tree().create_timer(0.1).timeout
				sword.shoot(randf_range(-45, -135), 100, get_random_position_on_sword())
				await get_tree().create_timer(0.1).timeout
				sword.shoot(randf_range(-45, -135), 100, get_random_position_on_sword())


func _on_hot_body_entered(body):
	get_tree().get_first_node_in_group("player").call("take_damage", 2, deg_to_rad(randi_range(-135, -225)))
	$HotTimer.start()


func _on_hot_timer_timeout():
	get_tree().get_first_node_in_group("player").call("take_damage", 2, deg_to_rad(randi_range(-135, -225)))


func _on_hot_body_exited(body):
	$HotTimer.stop()


func _on_spike_body_entered(body):
	get_tree().get_first_node_in_group("player").call("take_damage", 5, deg_to_rad(randi_range(-135, -225)))
	$SpikeTimer.start()


func _on_spike_timer_timeout():
	get_tree().get_first_node_in_group("player").call("take_damage", 5, deg_to_rad(randi_range(-135, -225)))


func _on_spike_2_body_entered(body):
	get_tree().get_first_node_in_group("player").call("take_damage", 5, deg_to_rad(randi_range(-135, -225)))
	$SpikeTimer.start()


func _on_spike_body_exited(body):
	$SpikeTimer.stop()


func _on_spike_2_body_exited(body):
	$SpikeTimer.stop()


func _on_basket_body_entered(body):
	await get_tree().create_timer(0.1).timeout
	
	body.animate_get_ore()
	
	get_tree().get_first_node_in_group("player").add_ore(1)
