extends CharacterBody2D


var plus_one_active = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not plus_one_active:
		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			velocity.x = lerp(velocity.x, 0.0, 0.4)
		move_and_slide()


func push(speed : float, direction : float) -> void:
	print(direction)
	velocity = Vector2(speed, 0).rotated(direction)


func delete() -> void:
	queue_free()


func animate_get_ore() -> void:
	plus_one_active = true
	$Sprite2D.hide()
	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D2.show()
	
	var tween = create_tween()
	
	tween.tween_property($Sprite2D2, "position", Vector2(0, -60), 3)
	
	await tween.finished
	
	queue_free()
