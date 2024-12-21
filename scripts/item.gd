# Item.gd
extends Resource
class_name Item  # This allows the Item class to be globally accessible

@export var name: String = "Unnamed Item"
@export var description: String = "No description"
@export var icon: Texture  # Optional: an icon image for the item
@export var value: int = 0
