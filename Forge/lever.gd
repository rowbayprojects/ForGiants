extends StaticBody2D


var forge_active = true


func activate_lever() -> void:
	if forge_active:
		$Switch.play()
		begin_forging_process()
		forge_active = false


func begin_forging_process() -> void:
	$Sprite2D.frame = 1
	get_tree().get_first_node_in_group("forge_controller").begin_forging_process()


func reset_sprite() -> void:
	$Sprite2D.frame = 0
	forge_active = true
