extends CharacterBody2D

const SPEED = 30
var current_state = IDLE

var dir = Vector2.RIGHT

var is_roaming = true
var is_chatting = false 

var character_body_2Dplayer
var character_body_2Dplayer_in_chat_zone = false

enum {
	IDLE,
	NEW_DIR,
	MOVE
}

# Define the boundaries of the roaming area
var roaming_area = Rect2(Vector2.ZERO, Vector2(500, 300)) # Replace with your desired area

# Define dialogue lines
var dialogue_lines = [
	"Hello there! I'm Pecki!",
	"It's a beautiful day, isn't it?",
	"Be careful out there, it's dangerous!"
]
var current_dialogue_index = 0

@onready var dialogue_label = $DialogueLabel  # Replace with the correct path to your Label node

func _ready():
	randomize()
	# Hide the dialogue label initially
	if dialogue_label:
		dialogue_label.visible = false
		$Timer.timeout.connect(_on_timer_timeout)
	if not $Timer.is_connected("timeout", Callable(self, "_on_timer_timeout")):
		$Timer.connect("timeout", Callable(self, "_on_timer_timeout"))



func _process(delta):
	match current_state:
		IDLE:
			play_idle_animation()
		NEW_DIR:
			dir = choose([Vector2.RIGHT, Vector2.DOWN, Vector2.UP, Vector2.LEFT])
			current_state = MOVE # Automatically transition to MOVE after getting a new direction
		MOVE:
			if not is_chatting:
				move(delta)
				play_walk_animation()

func choose(array):
	array.shuffle()
	return array[0]

func move(delta):
	if is_chatting:
		return

	# Update position based on direction and speed
	var new_position = position + dir * SPEED * delta

	# Constrain position within the roaming area
	if roaming_area.has_point(new_position):
		position = new_position
	else:
		# If outside, adjust the position to stay within bounds
		if new_position.x < roaming_area.position.x:
			position.x = roaming_area.position.x
		elif new_position.x > roaming_area.position.x + roaming_area.size.x:
			position.x = roaming_area.position.x + roaming_area.size.x
		
		if new_position.y < roaming_area.position.y:
			position.y = roaming_area.position.y
		elif new_position.y > roaming_area.position.y + roaming_area.size.y:
			position.y = roaming_area.position.y + roaming_area.size.y

func play_idle_animation():
	if dir.x < 0:
		$NPC.flip_h = true
	elif dir.x > 0:
		$NPC.flip_h = false

	if dir.y < 0:
		$NPC.play("Bidlemyconpc") # Up idle
	elif dir.y > 0:
		$NPC.play("Fidlemyconpc") # Down idle
	else:
		$NPC.play("Sidlemyconpc") # Side idle

func play_walk_animation():
	if dir.x < 0:
		$NPC.flip_h = true
	elif dir.x > 0:
		$NPC.flip_h = false

	if dir.y < 0:
		$NPC.play("Bwalkmyconpc") # Up walk
	elif dir.y > 0:
		$NPC.play("Fwalkmyconpc") # Down walk
	else:
		$NPC.play("Swalkmyconpc") # Side walk

func _on_chat_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("character_body_2Dplayer"):  # Make sure your player node is in this group
		character_body_2Dplayer = body
		character_body_2Dplayer_in_chat_zone = true
		print("Player entered chat zone")

func _on_chat_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("character_body_2Dplayer"):
		character_body_2Dplayer = body
		character_body_2Dplayer_in_chat_zone = false
		end_chat()  # Stop chatting if the player leaves the area
		print("Player left chat zone")

func _on_timer_timeout() -> void:
	$Timer.wait_time = choose([0.5, 1, 1.5])
	current_state = choose([IDLE, NEW_DIR, MOVE])



# Start the chat when the player presses a key
func _input(event):
	if event.is_action_pressed("ui_accept") and character_body_2Dplayer_in_chat_zone and not is_chatting:
		start_chat()

func start_chat():
	is_chatting = true
	if dialogue_label:
		dialogue_label.text = dialogue_lines[current_dialogue_index]
		dialogue_label.visible = true
	# Update dialogue index for next line
	current_dialogue_index = (current_dialogue_index + 1) % dialogue_lines.size()
	print("NPC: ", dialogue_label.text)

func end_chat():
	is_chatting = false
	if dialogue_label:
		dialogue_label.visible = false
