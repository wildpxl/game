extends Node2D
@onready var waterfall_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready():
	waterfall_sprite.play()  # Start the portal animation
