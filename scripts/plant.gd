extends Node2D

@export var growth_duration = 60  # Duration for each stage in seconds
var current_stage = "seed"  # Set the initial stage to "seed"
var growth_elapsed = 0.0  # Tracks elapsed time for the current growth stage

var plant_sprite: AnimatedSprite2D
var progress_bar: ProgressBar
var growth_timer: Timer
var animation_player: AnimationPlayer

@export var pumpkin_scene: PackedScene  # Assign your pumpkin item scene here
signal ready_to_harvest


func _ready():
	# Assign nodes
	plant_sprite = $AnimatedSprite2D
	progress_bar = $ProgressBar
	growth_timer = $Timer
	animation_player = $AnimationPlayer

	# Error handling
	if not plant_sprite:
		print("Error: AnimatedSprite2D node not found!")
		return
	if not progress_bar:
		print("Error: ProgressBar node not found!")
		return
	if not growth_timer:
		print("Error: Timer node not found!")
		return
	if not animation_player:
		print("Error: AnimationPlayer node not found!")
		return

	# Initialize ProgressBar to represent 0-100 for each stage
	progress_bar.min_value = 0
	progress_bar.max_value = 100
	progress_bar.value = 0

	# Start with the seed animation and begin the growth process
	play_animation("Seed")
	start_growth_process()


func play_animation(animation_name: String):
	print("Attempting to play animation:", animation_name)

	# Check if the animation exists in the AnimationPlayer
	if animation_player.has_animation(animation_name.capitalize()):
		animation_player.play(animation_name.capitalize())
		print("Playing animation:", animation_name.capitalize())
	else:
		print("Error: Animation", animation_name, "not found in AnimationPlayer!")
		return
	# Ensure the AnimatedSprite2D plays the correct animation
	if plant_sprite.animation != animation_name:
		plant_sprite.animation = animation_name.to_lower()  # Remove the .lower() part
		plant_sprite.play()


func start_growth_process():
	print("Starting growth process for stage:", current_stage)

	# Stop and start the timer for the current stage
	growth_timer.stop()
	growth_timer.wait_time = growth_duration
	growth_timer.start()
	growth_elapsed = 0.0  # Reset elapsed time

	# Connect the timeout signal if not already connected
	if not growth_timer.is_connected("timeout", Callable(self, "_on_timer_timeout")):
		growth_timer.connect("timeout", Callable(self, "_on_timer_timeout"))
		print("Timer connected successfully")

	# Make sure _process() is used to gradually update
	set_process(true)


func _process(delta):
	# If the timer is running, calculate the elapsed time
	if growth_timer.time_left > 0:
		growth_elapsed += delta  # Increment elapsed time by delta (frame time)
		update_progress_bar()

		# Update based on how far into the growth process we are
		var one_third_time = growth_duration / 3

		var two_third_time = (2 * growth_duration) / 3

func update_progress_bar():
	if progress_bar and growth_timer.time_left > 0:
		var elapsed_time = growth_duration - growth_timer.time_left
		progress_bar.value = (elapsed_time / growth_duration) * 100


func _on_timer_timeout():
	print("Transitioning stage from:", current_stage)
	match current_stage:
		"seed":
			grow_to_sprout()
		"sprout":
			grow_to_flower()
		"flower":
			grow_to_pumpkin()


func grow_to_sprout():
	print("Growing to sprout stage...")
	current_stage = "sprout"
	play_animation("Sprout")  # Ensure proper capitalization
	update_progress_bar()
	start_growth_process()


func grow_to_flower():
	print("Growing to flower stage...")
	current_stage = "flower"
	play_animation("Flower")  # Ensure proper capitalization
	update_progress_bar()
	start_growth_process()


func grow_to_pumpkin():
	print("Fully grown! Harvest your pumpkin.")
	current_stage = "pumpkin"
	plant_sprite.visible = false

	if pumpkin_scene != null:  # Ensure the pumpkin scene is assigned
		var pumpkin_instance = pumpkin_scene.instantiate()
		pumpkin_instance.global_position = plant_sprite.global_position  # Spawn at the plant's position
		get_parent().add_child(pumpkin_instance)  # Add it to the same parent as the plant
		print("Pumpkin item spawned at position:", pumpkin_instance.global_position)
	else:
		print("Error: Pumpkin scene not assigned!")

	if progress_bar:
		progress_bar.value = progress_bar.max_value
		progress_bar.visible = false  # Hide the progress bar after completion
		print("Progress bar hidden after full growth.")

	emit_signal("ready_to_harvest", self)
