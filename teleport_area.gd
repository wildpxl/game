

extends Area2D

@export var teleport_offset: Vector2 = Vector2(500, 0)  # Adjust this to control teleport distance

func _ready():
	print("TeleportArea is ready")


func _on_body_entered(body: Node):
	if body is CharacterBody2D and body.name == "Player":
		print("Player entered the teleport area")
		body.global_position += teleport_offset  # Teleport the player using teleport_offset
		print("Player teleported to: ", body.global_position)
		
func _on_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
# TeleportArea.gd - This script is attached to the TeleportArea (Area2D) node
