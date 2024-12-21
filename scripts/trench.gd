extends Node2D

@onready var trench_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready():
	trench_sprite.play()  # Start the portal animation
