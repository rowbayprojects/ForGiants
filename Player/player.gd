extends CharacterBody2D

const SCREEN_SCALE = 0.4
const ACCELERATION = 3000 * SCREEN_SCALE
const MAX_SPEED = 18000 * SCREEN_SCALE
const LIMIT_SPEED_Y = 1200 * SCREEN_SCALE
const JUMP_HEIGHT = 48000 * SCREEN_SCALE
const MIN_JUMP_HEIGHT = 12000 * SCREEN_SCALE
const MAX_COYOTE_TIME = 6
const JUMP_BUFFER_TIME = 10
const WALL_JUMP_AMOUNT = 16000 * SCREEN_SCALE
const WALL_JUMP_TIME = 10
const WALL_SLIDE_FACTOR = 0.6
const GRAVITY = 1500
const DASH_SPEED = 80000 * SCREEN_SCALE
const HAMMER_REPEL_SPEED = 108000 * SCREEN_SCALE


var player_velocity = Vector2()
var axis = Vector2()

var coyoteTimer = 0
var jumpBufferTimer = 0
var wallJumpTimer = 0
var dashTime = 0
var hammerTime = 0
var repelTime = 0
var invulnerabilityTime = 0

var canJump = false
var friction = false
var wall_sliding = false
var isDashing = false
var hasDashed = false
var hasUsedHammer = false
var isBeingRepelled = false
var hammerRepelActive = false
var isBeingDamaged = false
var damagedActive = false

var dashVelocity = 0

var player_damage_amount
var damage_direction

# Stats

const MAX_HEALTH : int = 20

var health : int = 20
var money : int = 0
var ore : int = 1


func _physics_process(delta):
	
	get_tree().get_first_node_in_group("camera_man").update_ui(money, ore)
	
	if player_velocity.y <= LIMIT_SPEED_Y:
		if not isDashing and not is_on_floor():
			player_velocity.y += GRAVITY * delta
	if is_on_floor() and player_velocity.y > 0:
		player_velocity.y = 0
	
	friction = false
	
	getInputAxis()
	setHammerRotation()
	useHammer(delta)
	hammerRepel(delta)
	damageBoost(delta)
	dash(delta)
	
	wallSlide(delta)
	
	#basic vertical movement mechanics
	if wallJumpTimer > WALL_JUMP_TIME:
		wallJumpTimer = WALL_JUMP_AMOUNT
		if not isDashing:
			horizontalMovement(delta)
	else:
		wallJumpTimer += 1
	
	if not canJump:
		if not wall_sliding:
			if isBeingDamaged:
				$AnimationPlayer.play("hurt")
			else:
				if player_velocity.y >= 0:
					$AnimationPlayer.play("fall")
				elif player_velocity.y < 0:
					$AnimationPlayer.play("jump")

	#jumping mechanics and coyote time
	if is_on_floor():
		canJump = true
		coyoteTimer = 0
	else:
		coyoteTimer += 1
		if coyoteTimer > MAX_COYOTE_TIME:
			canJump = false
			coyoteTimer = 0
		friction = true
	
	jumpBuffer(delta)
	
	if Input.is_action_just_pressed("jump") and not isDashing:
		if canJump:
			jump(delta)
			frictionOnAir()
		else:
			if $Rotatable/RayCast2D.is_colliding():
				wallJump(delta)
			frictionOnAir()
			jumpBufferTimer = JUMP_BUFFER_TIME #amount of frame
	
	setJumpHeight(delta)
	jumpBuffer(delta)
	
	velocity = player_velocity
	move_and_slide()

func jump(delta):
	$Jump.pitch_scale = randf_range(0.8, 1.2)
	$Jump.play()
	player_velocity.y = -JUMP_HEIGHT * delta

func wallJump(delta):
	$Jump.pitch_scale = randf_range(0.4, 0.6)
	$Jump.play()
	wallJumpTimer = 0
	player_velocity.x = -WALL_JUMP_AMOUNT * $Rotatable.scale.x * delta
	player_velocity.y = -JUMP_HEIGHT * delta
	$Rotatable.scale.x = -$Rotatable.scale.x

func wallSlide(_delta):
	if not canJump:
		if $Rotatable/RayCast2D.is_colliding():
			wall_sliding = true
			hasDashed = false
			player_velocity.y = player_velocity.y * WALL_SLIDE_FACTOR
			player_velocity.x = 0
			$AnimationPlayer.play("wall_slide")
		else:
			wall_sliding = false
	

func frictionOnAir():
	if friction:
		player_velocity.x = lerp(player_velocity.x, 0.0, 0.01)

func jumpBuffer(delta):
	if jumpBufferTimer > 0:
		if is_on_floor():
			jump(delta)
		jumpBufferTimer -= 1

func setJumpHeight(delta):
	if Input.is_action_just_released("jump") and not isDashing:
		if player_velocity.y < -MIN_JUMP_HEIGHT * delta:
			player_velocity.y = -MIN_JUMP_HEIGHT * delta

func horizontalMovement(delta):
	if Input.is_action_pressed("right"):
		if $Rotatable/RayCast2D.is_colliding():
			await get_tree().create_timer(0.1).timeout
			if not isDashing and not isBeingRepelled:
				player_velocity.x = min(player_velocity.x + ACCELERATION * delta, MAX_SPEED * delta)
			$Rotatable.scale.x = 1
			if canJump:
				$AnimationPlayer.play("run")
		else:
			if not isDashing and not isBeingRepelled:
				player_velocity.x = min(player_velocity.x + ACCELERATION * delta, MAX_SPEED * delta)
			$Rotatable.scale.x = 1
			if canJump:
				$AnimationPlayer.play("run")
	
	elif Input.is_action_pressed("left"):
		if $Rotatable/RayCast2D.is_colliding():
			await get_tree().create_timer(0.1).timeout
			if not isDashing and not isBeingRepelled:
				player_velocity.x = max(player_velocity.x - ACCELERATION * delta, -MAX_SPEED * delta)
			$Rotatable.scale.x = -1
			if canJump:
				$AnimationPlayer.play("run")
		else:
			if not isDashing and not isBeingRepelled:
				player_velocity.x = max(player_velocity.x - ACCELERATION * delta, -MAX_SPEED * delta)
			$Rotatable.scale.x = -1
			if canJump:
				$AnimationPlayer.play("run")
	elif is_on_floor():
		player_velocity.x = lerp(player_velocity.x, 0.0, 0.4)
		if canJump:
			$AnimationPlayer.play("idle")


func dash(delta):
	if not hasDashed and not isBeingRepelled:
		if Input.is_action_just_pressed("dash"):
			
			$Dash.pitch_scale = randf_range(0.8, 1.2)
			$Dash.play()
			 
			player_velocity = axis * DASH_SPEED * delta
			dashVelocity = player_velocity
			Input.start_joy_vibration(0, 1, 1, 0.2)
			if axis.x > 0:
				$Rotatable.scale.x = 1
			elif axis.x < 0:
				$Rotatable.scale.x = -1
			isDashing = true
			hasDashed = true
	
	if isDashing:
		
		var t : float = player_velocity.x / dashVelocity.x
		player_velocity = lerp(player_velocity, Vector2.ZERO, 0.2 * t)
		
		if is_on_ceiling():
			dashTime = 10000
			player_velocity.y = 0
		
		dashTime += 1
		if dashTime >= int(0.15 * 1 / delta):
			isDashing = false
			dashTime = 0
	
	if is_on_floor() && player_velocity.y >= 0:
		hasDashed = false


func getInputAxis():
	axis = Vector2.ZERO
	axis.x = get_global_mouse_position().x - global_position.x
	axis.y = get_global_mouse_position().y - global_position.y
	axis = axis.normalized()


func setHammerRotation():
	$HammerRotator.rotation = atan2(axis.y, axis.x) + PI/2


func useHammer(delta):
	if not hasUsedHammer:
		if Input.is_action_just_pressed("use_hammer"):
			
			$Hammer.pitch_scale = randf_range(0.8, 1.2)
			$Hammer.play()
			
			$HammerRotator/Area2D.monitoring = true
			$HammerRotator/Area2D/CollisionShape2D.set_deferred("disabled", false)
			
			if axis.x > 0:
				$HammerRotator/Sprite2D.frame = 1
			else:
				$HammerRotator/Sprite2D.frame = 2
			
			hasUsedHammer = true
	else:
		hammerTime += 1
		if hammerTime >= int(0.1 * 1 / delta):
			
			$HammerRotator/Area2D.monitoring = false
			$HammerRotator/Area2D/CollisionShape2D.set_deferred("disabled", true)
			
			hammerTime = 0
			
			await get_tree().create_timer(0.1).timeout
			
			$HammerRotator/Sprite2D.frame = 0
			hasUsedHammer = false


func hammerRepel(delta) -> void:
	if not isBeingRepelled and hammerRepelActive:
		if axis.x > 0:
			axis = Vector2(-0.5, 0.5)
		else:
			axis = Vector2(0.5, 0.5)
		player_velocity = -axis * HAMMER_REPEL_SPEED * delta
		hammerRepelActive = false
		isBeingRepelled = true
	elif isBeingRepelled:
		isDashing = false
		repelTime += 1
		if repelTime >= int(0.5 * 1 / delta):
			
			isBeingRepelled = false
			repelTime = 0


func resetPlayer() -> void:
	health = MAX_HEALTH
	global_position = Vector2(320, 0)
	
	get_tree().get_first_node_in_group("forge_controller").call("finish_forging_process_without_rewards")
	get_tree().call_group("ore", "delete")
	get_tree().get_first_node_in_group("ore_spawner").call("spawn_ore")


func damageBoost(delta) -> void:
	if not isBeingDamaged and damagedActive:
		
		$Hurt.pitch_scale = randf_range(0.8, 1.2)
		$Hurt.play()
		
		health -= player_damage_amount
		if health <= 0:
			resetPlayer()
		if damage_direction > deg_to_rad(-180):
			axis = Vector2(-0.5, 0.5)
		else:
			axis = Vector2(0.5, 0.5)
		player_velocity = -axis * 36000 * delta
		isBeingDamaged = true
		damagedActive = false
		hasDashed = false
	elif isBeingDamaged:
		isDashing = false
		invulnerabilityTime += 1
		if invulnerabilityTime >= int(0.5 * 1 / delta):
			
			isBeingDamaged = false
			invulnerabilityTime = 0


func take_damage(damage_amount : int, direction : float) -> void:
	player_damage_amount = damage_amount
	damage_direction = direction
	damagedActive = true
	get_tree().get_first_node_in_group("camera_man").damage_screen()


func add_money(amount : int) -> void:
	money += amount


func add_ore(amount : int) -> void:
	ore += amount


func _on_area_2d_body_entered(body):
	if body.is_in_group("lever"):
		body.activate_lever()
	if body.is_in_group("sword"):
		$Metal.pitch_scale = randf_range(0.8, 1.2)
		$Metal.play()
		hammerRepelActive = true
		body.add_forging_progress(1)
	if body.is_in_group("ore"):
		body.push(500, atan2(axis.y, axis.x))
