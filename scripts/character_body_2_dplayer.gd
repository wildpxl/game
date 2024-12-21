extends CharacterBody2D

@onready var inventory = $Control/InventoryUI  # Reference the inventory UI scene
@onready var inventory_manager = $InventoryManager  # Reference the InventoryManager node

func _process(delta):
	if Input.is_action_just_pressed("inventory") and inventory != null:
		inventory.visible = not inventory.visible
		print("Toggling inventory visibility:", inventory.visible)
		if inventory.visible:
			inventory.update_inventory_ui()
		# Check for the planting action with "P" key
	if Input.is_action_just_pressed("plant"):
		if has_item("Pumpkin Seed"):
			print("Player has a Pumpkin Seed, planting now...")
			plant_seed()
			remove_item_from_inventory("Pumpkin Seed")  # Remove the seed after planting
		else:
			print("No Pumpkin Seed in inventory!")

func add_to_inventory(item: Resource):
	if item == null:
		print("Error: Tried to add a null item.")
		return
		
	if item is Item:  # Ensure that the item is indeed an Item type
		inventory_manager.add_item(item)
		print("Picked up: ", item.name)
		print("Current inventory: ", inventory_manager.get_items())  # Debugging print
		
		# Update the InventoryUI with the current items\
		inventory.set_items(inventory_manager.get_items()) # Pass the items to the UI to update


		# Update the InventoryUI with the current items
		inventory.set_items(inventory_manager.get_items())  # Pass the items to the UI to update
	else:
		print("Error: Tried to add a non-Item resource to the inventory.")

const speed = 75
var current_dir = "none"
var health = 100  # Player's initial health
var can_attack = true  # To manage attack cooldown
var attacking = false  # Track if an attack is in progress
@export var attack_damage = 10  # Damage dealt to enemies
@export var max_health = 100  # Maximum health for respawn
@export var regen_amount = 5  # Health points regained every 30 seconds

# XP system variables
var attack_xp = 0  # XP for the attack stat
@export var xp_to_level_up = 100  # XP required to level up the attack stat
var attack_level = 1  # Current attack level
@export var attack_xp_gain = 5  # XP gained per hit

@export var plant_scene: PackedScene  # Assign the plant scene here

func _ready():
	$AnimatedSprite2D.play("Fidle")
	$HitboxArea2D.monitoring = true  # Ensure monitoring is enabled for HitboxArea2D
	$HitboxArea2D.connect("body_entered", Callable(self, "_on_player_hitbox_body_entered"))

	# Initialize the health, attack, and level displays
	update_health_display()
	update_level_display()  # Add this to initialize the level label

	# Start health regeneration
	start_health_regeneration()

func start_health_regeneration():
	var regen_timer = Timer.new()
	regen_timer.wait_time = 30.0
	regen_timer.one_shot = false
	regen_timer.connect("timeout", Callable(self, "_on_regen_timer_timeout"))
	add_child(regen_timer)
	regen_timer.start()

func _on_regen_timer_timeout() -> void:
	if health < max_health and !attacking:
		health = min(health + regen_amount, max_health)
		print("Player health regenerated to: ", health)
		update_health_display()

func _physics_process(_delta):
	player_movement(_delta)
	
	# Check for attack input
	if Input.is_action_just_pressed("attack") and can_attack and !attacking:
		print("Attempting to attack...")
		perform_attack()
	
	# Check for the pickup action
	if Input.is_action_just_pressed("pickup_item"):
		check_for_item_pickup()
	
	# Check for the planting action with "P" key
	if Input.is_action_just_pressed("plant"):
		if has_item("Pumpkin Seed"):
			print("Player has a Pumpkin Seed, planting now...")
			plant_seed()
			remove_item_from_inventory("Pumpkin Seed")
		else:
			print("No Pumpkin Seed in inventory!")

func player_movement(_delta):
	var moved = false
	if Input.is_action_pressed("ui_right"):
		current_dir = "right"
		velocity = Vector2(speed, 0)
		moved = true
	elif Input.is_action_pressed("ui_left"):
		current_dir = "left"
		velocity = Vector2(-speed, 0)
		moved = true
	elif Input.is_action_pressed("ui_down"):
		current_dir = "down"
		velocity = Vector2(0, speed)
		moved = true
	elif Input.is_action_pressed("ui_up"):
		current_dir = "up"
		velocity = Vector2(0, -speed)
		moved = true
	else:
		velocity = Vector2.ZERO  # Reset velocity when no input is detected
	
	play_anim(moved)
	move_and_slide()

# Function to handle playing animations during movement
func play_anim(moved):
	if attacking:
		return
	
	update_animations()
	var anim = $AnimatedSprite2D
	match current_dir:
		"right":
			anim.flip_h = false
			if moved:
				anim.play("Swalk")
			else:
				anim.play("Sidle")
		"left":
			anim.flip_h = true
			if moved:
				anim.play("Swalk")
			else:
				anim.play("Sidle")
		"down":
			anim.flip_h = false
			if moved:
				anim.play("Fwalk")
			else:
				anim.play("Fidle")
		"up":
			anim.flip_h = false
			if moved:
				anim.play("Bwalk")
			else:
				anim.play("Bidle")

func update_animations():
	var anim_sprite = $AnimatedSprite2D
	if anim_sprite.animation in ["Sattack", "Fattack", "Battack"] and anim_sprite.is_playing():
		return

func _on_player_hitbox_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("enemies"):
		print("Hit enemy!")
		_body.take_damage(attack_damage)
		gain_attack_xp()

func gain_attack_xp():
	attack_xp += attack_xp_gain
	print("Gained XP: ", attack_xp_gain, " | Total XP: ", attack_xp)
	if attack_xp >= xp_to_level_up:
		level_up_attack()

func level_up_attack():
	attack_level += 1
	attack_xp -= xp_to_level_up
	attack_damage += 2
	xp_to_level_up = int(xp_to_level_up * 1.2)
	print("Leveled up! New attack level: ", attack_level, ", Attack Damage: ", attack_damage, ", XP for next level: ", xp_to_level_up)
	update_level_display()  # Update the level display when leveling up

func take_damage(amount: int) -> void:
	health -= amount
	print("Player health: ", health)
	update_health_display()
	if health <= 0:
		die()

func die() -> void:
	print("Player died!")
	await get_tree().create_timer(2.0).timeout
	respawn_player()

func respawn_player() -> void:
	var respawn_point = get_tree().root.get_node("Node2D/RespawnPoint")
	if respawn_point != null:
		position = respawn_point.position
		health = max_health
		update_health_display()
		print("Player respawned!")
	else:
		print("RespawnPoint not found! Check your node path.")

# Function to perform an attack
func perform_attack() -> void:
	if not can_attack or attacking:
		return

	print("perform_attack() called")
	can_attack = false
	attacking = true
	
	match current_dir:
		"right", "left":
			$AnimatedSprite2D.play("Sattack")
		"down":
			$AnimatedSprite2D.play("Fattack")
		"up":
			$AnimatedSprite2D.play("Battack")
	
	print("Swinging weapon...")
	$HitboxArea2D.monitoring = true
	print("Hitbox activated")
	await get_tree().create_timer(1.0).timeout
	$HitboxArea2D.monitoring = false
	print("Hitbox deactivated")
	
	can_attack = true
	attacking = false
	print("can_attack reset to true")

func update_health_display() -> void:
	if $HealthLabel:
		$HealthLabel.text = "hp: " + str(health)
	
	if $XPBar:
		$XPBar.value = attack_xp
		$XPBar.max_value = xp_to_level_up

func update_level_display() -> void:
	if $LevelLabel:
		$LevelLabel.text = "str lvl: " + str(attack_level)

# Function to check for nearby items and pick them up
func check_for_item_pickup():
	var overlapping_bodies = $HitboxArea2D.get_overlapping_bodies()
	
	if overlapping_bodies.size() > 0:
		for body in overlapping_bodies:
			if body.is_in_group("items"):
				print("Picking up item: ", body.name)
				if body.has_method("get_item_data"):
					var item_data = body.get_item_data()
					if item_data != null:
						add_to_inventory(item_data)
						body.queue_free()
						return
	else:
		print("No items nearby to pick up.")

# Function to check if the player has a certain item
func has_item(item_name: String) -> bool:
	print("Checking if player has: ", item_name)
	for item in inventory_manager.get_items():  # Make sure to use inventory_manager here
		print("Inventory item: ", item["item"].name)  # Debugging to show what's in the inventory
		if item["item"].name == item_name:
			return true
	return false


# Function to plant the seed
func plant_seed():
	if plant_scene == null:
		print("Error: Plant scene not assigned!")
		return

	var plant_instance = plant_scene.instantiate()
	plant_instance.global_position = self.global_position  # Plant at the player's global position
	get_tree().root.add_child(plant_instance)  # Add it to
	
func remove_item_from_inventory(item_name: String):
	var items = inventory_manager.get_items()  # Fetch items from the inventory manager
	for i in range(items.size()):
		if items[i]["item"].name == item_name:
			if items[i]["quantity"] > 1:
				items[i]["quantity"] -= 1  # Decrease the quantity
				print("Reduced quantity of: ", item_name, " to ", items[i]["quantity"])
			else:
				inventory_manager.remove_item(items[i]["item"])  # Remove the actual item if the quantity is 1
				print("Removed item from inventory: ", item_name)
			inventory.update_inventory_ui()  # Update the UI after removing/reducing the item
			break
