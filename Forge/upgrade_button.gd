extends StaticBody2D


var button_active = true


func activate_button() -> void:
	$Switch.play()
	button_active = false
	
	$Sprite2D.frame = 1
	
	get_tree().get_first_node_in_group("forge_controller").call("upgrade_forge")
	
	await get_tree().create_timer(0.3).timeout
	$Sprite2D.frame = 0
	
	button_active = true


func _on_area_2d_body_entered(body):
	if button_active:
		activate_button()
