# Ladder.gd - This script is attached to the Ladder (Area2D) node
extends Area2D

@export var teleport_distance = -500  # Distance to teleport the player (negative value to go west)

func _ready():
	# Connect signals using Callables to ensure they're done correctly
	self.connect("body_entered", Callable(self, "_on_body_entered"))
	
func _on_body_entered(body: Node):
	if body is CharacterBody2D and body.name == "Player":
		print("Player entered the ladder area, teleporting...")
		body.global_position.x += teleport_distance  # Automatically move the player west by the teleport_distance
		print("Player teleported 500 spaces west!")
