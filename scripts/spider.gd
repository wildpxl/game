extends CharacterBody2D

@export var speed = 15
@export var wander_speed = 15  # Speed for wandering
@export var wander_time = 2.0  # Time to wander before changing direction
@export var attack_range = 35  # Define a reasonable range for the attack
@export var wander_radius = 100  # Radius within which the character will wander

var player_chase = false
var player = null
var is_wandering = false
var wander_timer = 0.0
var wander_direction = Vector2.ZERO
var wander_center = Vector2.ZERO

var attack_timer = 0.0  # Timer to control attack delay
@export var attack_damage = 10  # Damage dealt by the enemy's attack
@export var attack_delay = 1.0  # Time between attacks

func _ready():
	randomize()
	is_wandering = true
	wander_timer = wander_time  # Initialize the wander timer
	wander_center = position  # Set the center for the wander area

func _physics_process(delta):
	if player_chase and player:
		# Move towards the player
		var direction = (player.position - position).normalized()
		velocity = direction * speed
		move_and_slide()

		# Play the appropriate animation based on movement direction
		play_animation(direction)

		# Attack if within range
		if position.distance_to(player.position) <= attack_range:
			attack_timer -= delta
			if attack_timer <= 0:
				perform_attack()
				attack_timer = attack_delay
	else:
		# Handle wandering when not chasing
		if is_wandering:
			wander_timer -= delta
			if wander_timer <= 0:
				# Change direction after wandering for a while
				wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
				wander_timer = wander_time
			velocity = wander_direction * wander_speed
			move_and_slide()
			
			# Constrain movement to within the wander area
			if position.distance_to(wander_center) > wander_radius:
				position = wander_center + (position - wander_center).normalized() * wander_radius
			
			# Play wandering animation
			play_animation(wander_direction)

func play_animation(direction):
	if direction.x > 0:
		$AnimatedSprite2D.play("SwS")  # Side walk
		$AnimatedSprite2D.flip_h = false
	elif direction.x < 0:
		$AnimatedSprite2D.play("SwS")  # Side walk
		$AnimatedSprite2D.flip_h = true
	elif direction.y > 0:
		$AnimatedSprite2D.play("FwS")  # Forward walk (down)
		$AnimatedSprite2D.flip_h = false
	elif direction.y < 0:
		$AnimatedSprite2D.play("BiS")   # Backward idle (up)
	else:
		$AnimatedSprite2D.play("SiS")   # Side idle

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):  # Ensure the player is in the correct group
		player = body
		player_chase = true
		is_wandering = false

func _on_detection_area_body_exited(body):
	if body == player:
		player = null
		player_chase = false
		is_wandering = true

func perform_attack():
	if player:
		player.take_damage(attack_damage)  # Call the player's take_damage function or similar
