extends CharacterBody2D

@export var speed = 10
@export var wander_speed = 5
@export var wander_time = 2.0
@export var attack_range = 35
@export var wander_radius = 100
@export var health = 50
@export var max_health = 50  # Save the max health for respawning
@export var attack_damage = 5
@export var attack_delay = 1.0
@export var aggression_range = 150  # Range within which the enemy will become aggressive
@export var respawn_time = 30.0  # Time before respawn in seconds

@export var seed_scene: PackedScene  # Exported PackedScene for the pumpkin seed

var player = null
var is_wandering = true
var wander_timer = 0.0
var wander_direction = Vector2.ZERO
var wander_center = Vector2.ZERO
var attack_timer = attack_delay
var attacking = false
var player_chase = false
var player_in_attack_range = false  # New flag to track if the player is within attack range

var original_position = Vector2.ZERO  # Store the original position for respawning

func _ready():
	original_position = position  # Store the initial position
	$AnimatedSprite2Dp.play("Sidlep")  # Start with idle animation
	wander_timer = wander_time
	wander_center = position
	is_wandering = true
	add_to_group("enemies")  # Add the enemy to the "enemies" group
	print("Enemy is ready and seed_scene assigned: ", seed_scene != null)  # Debugging line

func _physics_process(delta):
	if !visible:  # Skip processing if the enemy is hidden (i.e., dead)
		return

	velocity = Vector2.ZERO

	if player:
		var distance_to_player = position.distance_to(player.global_position)

		if distance_to_player <= aggression_range:
			player_chase = true
			is_wandering = false
			chase_player(delta, distance_to_player)
		else:
			player_chase = false
			if is_wandering:
				wander(delta)
	else:
		if is_wandering:
			wander(delta)

func die() -> void:
	visible = false  # Hide the enemy instead of removing it
	player = null  # Reset player reference
	player_chase = false
	is_wandering = true
	attacking = false
	print("Enemy will respawn in ", respawn_time, " seconds.")
	
	# Drop a pumpkin seed item upon death
	drop_pumpkin_seed()
	
	# Use call_deferred to safely disable the collision shape
	$CollisionShape2D.call_deferred("set_disabled", true)
	
	# Start the respawn timer
	await get_tree().create_timer(respawn_time).timeout
	respawn()

# Function to drop the pumpkin seed
func drop_pumpkin_seed():
	if seed_scene == null:
		print("Error: seed_scene is not assigned!")
		return
	
	var seed_instance = seed_scene.instantiate()
	seed_instance.global_position = global_position  # Place the seed where the enemy died
	get_tree().root.add_child(seed_instance)  # Add the seed instance to the game world
	print("Pumpkin seed dropped at: ", seed_instance.global_position)

# Respawn the enemy at the original position
func respawn() -> void:
	print("Respawning enemy...")
	position = original_position  # Move back to the original position
	health = max_health  # Reset health to maximum
	visible = true  # Make the enemy visible again
	$AnimatedSprite2Dp.play("Sidlep")  # Reset animation
	player = null  # Reset the player reference
	is_wandering = true  # Reset to wandering state
	
	# Re-enable the collision shape when the enemy becomes visible
	$CollisionShape2D.call_deferred("set_disabled", false)

func chase_player(delta, distance_to_player):
	var direction = position.direction_to(player.global_position).normalized()
	velocity = direction * speed
	move_and_slide()

	update_animations(direction)

	# Attack if within range
	if distance_to_player <= attack_range:
		if not player_in_attack_range:
			print("Player within attack range")  # This will only print once
			player_in_attack_range = true
		
		if not attacking:
			attack_timer -= delta
			if attack_timer <= 0:
				perform_attack()
				attack_timer = attack_delay
	else:
		if player_in_attack_range:
			print("Player left attack range")  # Print when the player leaves the attack range
			player_in_attack_range = false

func wander(delta):
	wander_timer -= delta
	if wander_timer <= 0:
		wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		wander_timer = wander_time

	velocity = wander_direction * wander_speed
	move_and_slide()

	# Constrain movement to within the wander area
	if position.distance_to(wander_center) > wander_radius:
		position = wander_center + (position - wander_center).normalized() * wander_radius

	update_animations(wander_direction)

func _on_detection_area_body_entered(body):
	if body.is_in_group("character_body_2_dplayer"):
		player = body
		print("Player detected by enemy")  # Debugging

func _on_detection_area_body_exited(body):
	if body == player:
		player = null
		player_chase = false
		is_wandering = true
		player_in_attack_range = false  # Reset the attack range flag when the player leaves
		print("Player left detection area")  # Debugging

# Updated take_damage method with a detailed print statement
func take_damage(amount: int) -> void:
	health -= amount
	print("Enemy hit! Took ", amount, " damage. Remaining health: ", health)  # Added detailed print statement
	if health <= 0:
		print("Enemy defeated!")  # Print statement to indicate the enemy has been killed
		die()

func perform_attack() -> void:
	if attacking:
		return  # Prevent multiple triggers

	attacking = true  # Set the attacking flag to true
	if player:
		print("Enemy attacking player!")  # Debugging
		
		# Determine the direction to the player and play the appropriate attack animation
		var direction_to_player = (player.global_position - position).normalized()
		
		if abs(direction_to_player.x) > abs(direction_to_player.y):
			if direction_to_player.x > 0:
				$AnimatedSprite2Dp.play("Sattackp")  # Attack to the right
				$AnimatedSprite2Dp.flip_h = false
			else:
				$AnimatedSprite2Dp.play("Sattackp")  # Attack to the left
				$AnimatedSprite2Dp.flip_h = true
		else:
			if direction_to_player.y > 0:
				$AnimatedSprite2Dp.play("Fattackp")  # Attack downwards
				$AnimatedSprite2Dp.flip_h = false
			else:
				$AnimatedSprite2Dp.play("Battackp")  # Attack upwards
		
		# Wait for the attack animation duration before inflicting damage
		await get_tree().create_timer(0.5).timeout  # Adjust the duration as needed
		
		# Check if the player is still within attack range and take damage
		if player and position.distance_to(player.global_position) <= attack_range:
			print("Enemy dealt damage to the player")  # Debugging
			player.take_damage(attack_damage)
		
		attacking = false  # Reset attacking state after attack

# New unified function for handling animations
func update_animations(direction: Vector2) -> void:
	var anim_sprite = $AnimatedSprite2Dp

	# Prevent overriding the attack animation
	if anim_sprite.animation == "Attack" and anim_sprite.is_playing():
		return

	if direction.length() > 0:
		if direction.x > 0:
			anim_sprite.play("Swalkp")   # Right movement animation
			anim_sprite.flip_h = false
		elif direction.x < 0:
			anim_sprite.play("Bwalkp")  # Left movement animation
			anim_sprite.flip_h = true
		elif direction.y > 0:
			anim_sprite.play("Fwalkp")  # Down movement animation
			anim_sprite.flip_h = false
		elif direction.y < 0:
			anim_sprite.play("Bwalkp")  # Up movement animation (or adjust as needed)
	else:
		anim_sprite.play("Sidlep")
