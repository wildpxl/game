extends Area2D

@onready var label = $Label  # Reference to the Label node

func _ready():
	label.visible = false  # Start with the label hidden

	# Connect the body_entered and body_exited signals if not already connected
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))

	if not is_connected("body_exited", Callable(self, "_on_body_exited")):
		connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body: Node2D) -> void:
	print("Something entered the area: ", body.name)  # Debugging statement
	if body.is_in_group("player"):
		label.visible = true  # Show the "It's locked..." text
		print("Player entered, showing label")

func _on_body_exited(body: Node2D) -> void:
	print("Something exited the area: ", body.name)  # Debugging statement
	if body.is_in_group("player"):
		label.visible = false  # Hide the text
		print("Player exited, hiding label")
