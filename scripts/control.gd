extends Control

@onready var background_sprite = $BackgroundSprite
@onready var button_sprite = $ButtonSprite
@onready var animation_player = $AnimationPlayer
@onready var button_press_timer = $ButtonPressTimer

# Path to the world scene
var world_scene_path = "res://scenes/control.tscn"

func _ready() -> void:
	print("Menu is ready")

	# Set the Control node to scale to cover the whole screen
	self.rect_min_size = get_viewport().size

	# Center the background sprite
	background_sprite.rect_position = Vector2.ZERO
	background_sprite.scale = Vector2(
		get_viewport().size.x / background_sprite.texture.get_size().x,
		get_viewport().size.y / background_sprite.texture.get_size().y
	)

	# Center the button sprite
	button_sprite.rect_position = Vector2(
		(get_viewport().size.x - button_sprite.rect_size.x) / 2,
		(get_viewport().size.y - button_sprite.rect_size.y) / 2
	)

	# Play idle animation immediately
	animation_player.play("Idle")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		print("Key pressed")
		handle_menu_transition()

func handle_menu_transition() -> void:
	# Change button and background textures
	button_sprite.texture = load("res://art/menubutton2.png")
	background_sprite.texture = load("res://art/menuBG2.png")
	button_press_timer.start()  # Start the timer for button press effect
	animation_player.play("Transition")  # Play the transition animation

func _on_ButtonPressTimer_timeout() -> void:
	print("ButtonPressTimer timeout")
	button_sprite.texture = load("res://art/menubutton1.png")
	background_sprite.texture = load("res://art/menuBG1.png")
	animation_player.play("Idle")  # Return to idle animation
	change_to_world_scene()  # Transition to the world scene

func change_to_world_scene() -> void:
	# Ensure the path is correct and the scene is available
	if ResourceLoader.exists(world_scene_path):
		var new_scene = load(world_scene_path)
		if new_scene:
			get_tree().change_scene_to(new_scene)
		else:
			print("Failed to load the world scene.")
	else:
		print("Scene path does not exist:", world_scene_path)

# Optional: Handle animation events if needed
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	print("Animation finished:", anim_name)

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	print("Animation started:", anim_name)
