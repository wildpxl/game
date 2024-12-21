extends Node2D

@export var growth_duration = 60  # Duration for each stage in seconds
var current_stage = "seed"  # Set initial stage to match lowercase

@export var seed_frames: SpriteFrames
@export var sprout_frames: SpriteFrames
@export var flower_frames: SpriteFrames

var plant_sprite: AnimatedSprite2D
var progress_bar: ProgressBar
var growth_timer: Timer

func _ready():
	# Assign nodes
	plant_sprite = $AnimatedSprite2D
	progress_bar = $ProgressBar
	growth_timer = $Timer

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

	# Initialize ProgressBar
	progress_bar.min_value = 0
	progress_bar.max_value = growth_duration * 3
	progress_bar.value = 0

	# Check that all frames are assigned
	if not seed_frames:
		print("Error: seed frames not assigned!")
		return
	if not sprout_frames:
		print("Error: sprout frames not assigned!")
		return
	if not flower_frames:
		print("Error: flower frames not assigned!")
		return

	# Start with the seed animation
	plant_sprite.frames = seed_frames
	play_seed_animation()

func play_seed_animation():
	if seed_frames.has_animation("seed"):
		plant_sprite.frames = seed_frames
		plant_sprite.play("seed")

		# Start the growth process
		start_growth_process()
	else:
		print("Error: 'seed' animation not found in seed_frames!")

func start_growth_process():
	print("Starting seed stage...")
	current_stage = "seed"
	
	growth_timer.wait_time = growth_duration
	growth_timer.start()

	if not growth_timer.is_connected("timeout", Callable(self, "_on_timer_timeout")):
		growth_timer.connect("timeout", Callable(self, "_on_timer_timeout"))

	update_progress_bar()

func _on_timer_timeout():
	print("Transitioning stage from:", current_stage)
	match current_stage:
		"seed":
			grow_to_sprout()
		"sprout":
			grow_to_flower()
		"flower":
			grow_to_pumpkin()

func update_progress_bar():
	if progress_bar:
		progress_bar.value = (["seed", "sprout", "flower"].find(current_stage) + 1) * growth_duration

func grow_to_sprout():
	print("Growing to sprout stage...")
	current_stage = "sprout"
	
	plant_sprite.frames = sprout_frames
	if sprout_frames.has_animation("sprout"):
		plant_sprite.play("sprout")
	else:
		print("Error: 'sprout' animation not found in sprout_frames!")
		return
	
	update_progress_bar()
	growth_timer.start()

func grow_to_flower():
	print("Growing to flower stage...")
	current_stage = "flower"
	
	plant_sprite.frames = flower_frames
	if flower_frames.has_animation("flower"):
		plant_sprite.play("flower")
	else:
		print("Error: 'flower' animation not found in flower_frames!")
		return
	
	update_progress_bar()
	growth_timer.start()

func grow_to_pumpkin():
	print("Fully grown! Harvest your pumpkin.")
	current_stage = "pumpkin"
	
	plant_sprite.visible = false
	var pumpkin_sprite = Sprite2D.new()
	pumpkin_sprite.texture = preload("res://resources/pumpkin.png") 
	pumpkin_sprite.position = plant_sprite.position
	add_child(pumpkin_sprite)

	if progress_bar:
		progress_bar.value = growth_duration * 3
	
	emit_signal("ready_to_harvest", self)
