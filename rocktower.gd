extends Node2D
@onready var rocktower_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready():
	rocktower_sprite.play()  # Start the portal animation
