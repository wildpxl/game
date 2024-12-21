extends Area2D

@export var message_label: Label

# Called when the node enters the scene tree for the first time.
func _ready():
	if message_label:
		message_label.visible = false
	else:
		print("Error: message_label is not assigned.")

func _on_Area2D_body_entered(_body):
	if _body.is_in_group("player"):
		if message_label:
			message_label.text = "It looks dark down there.."
			message_label.visible = true
		else:
			print("Error: message_label is not assigned.")

func _on_Area2D_body_exited(_body):
	if _body.is_in_group("player"):
		if message_label:
			message_label.text = "It looks dark down there.."
			message_label.visible = false
		else:
			print("Error: message_label is not assigned.")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
