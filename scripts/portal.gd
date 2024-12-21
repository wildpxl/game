extends Area2D

@onready var portal_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var destination_point: Marker2D = $DestinationPoint

func _ready():
	portal_sprite.play()  # Start the portal animation

	# Connect the body_entered signal to the function _on_body_entered
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node2D) -> void:
	print("Something entered the portal: ", body.name)  # Check if anything is detected

	# Check for the lowercase "player" group (case-sensitive)
	if body.is_in_group("player"):
		print("Player detected, attempting teleport...")
		body.velocity = Vector2.ZERO  # Stop any existing movement
		body.global_position = destination_point.global_position  # Teleport player
		print("Teleported to: ", destination_point.global_position)
	else:
		print("Entered by a non-player object.")
