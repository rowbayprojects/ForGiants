extends CharacterBody2D


@export var damage : int = 1

var duration : int = 1000


func _physics_process(delta) -> void:
	position += velocity * delta
	
	duration -= delta
	if duration <= 0:
		queue_free()


func _on_hit_box_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(damage, rotation)
