extends Node2D

@export var pumpkin: Item  # Ensure this is of type `Item`
var is_collected = false  # Track if the seed has been picked up



func _ready():
	$Area2D.connect("body_entered", Callable(self, "_on_body_entered"))
	var area2d_node = $Area2D  
	if pumpkin == null:
		pumpkin = Item.new()
		pumpkin.name = "Pumpkin Seed"
		pumpkin.description = "A pumpkin."
		pumpkin.icon = load("res://resources/pumpkin.png")  # Correct path to your seed icon
		print("Pumpkin icon loaded: ", pumpkin.icon)



	
	# Ensure that this path is correct
func _on_body_entered(body):
	if body and body.is_in_group("Player") and not is_collected:  # Ensure the body is valid and in the Player group
		if body.has_method("add_to_inventory"):  # Ensure the player has this method
			if pumpkin != null:  # Check if pumpkin_seed is properly assigned
				body.add_to_inventory(pumpkin)  # Add the seed item to inventory
				is_collected = true
				queue_free()  # Remove the seed from the world
			else:
				print("Error: pumpkin_seed is null!")
		else:
			print("Player doesn't have an add_to_inventory method!")
	else:
		print("Invalid body or not a player")
