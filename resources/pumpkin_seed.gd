extends Node2D

@export var pumpkin_seed: Item  # Ensure this is of type `Item`
var is_collected = false  # Track if the seed has been picked up

func _ready():
	$Area2D.connect("body_entered", Callable(self, "_on_body_entered"))
	if pumpkin_seed == null:
		pumpkin_seed = Item.new()
		pumpkin_seed.name = "Pumpkin Seed"
		pumpkin_seed.description = "A seed for growing pumpkins."
		pumpkin_seed.icon = load("res://resources/PumpkinSeed.png")  # Correct path to your seed icon
		print("Pumpkin Seed icon loaded: ", pumpkin_seed.icon)


func _on_body_entered(body):
	if body and body.is_in_group("Player") and not is_collected:  # Ensure the body is valid and in the Player group
		if body.has_method("add_to_inventory"):  # Ensure the player has this method
			if pumpkin_seed != null:  # Check if pumpkin_seed is properly assigned
				body.add_to_inventory(pumpkin_seed)  # Add the seed item to inventory
				is_collected = true
				queue_free()  # Remove the seed from the world
			else:
				print("Error: pumpkin_seed is null!")
		else:
			print("Player doesn't have an add_to_inventory method!")
	else:
		print("Invalid body or not a player")
