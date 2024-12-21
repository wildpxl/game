extends Node

# Store items as an array
var items = []

func add_item(item):
	if item == null:
		print("Error: Attempted to add a null item to inventory.")
		return
	
	# Check if the item is actually an Item resource
	if not item is Item:
		print("Error: Attempted to add a non-Item resource to inventory.")
		return
	
	# Check if the item already exists
	for existing_item in items:
		if existing_item.name == item.name:
			print("Item already exists in inventory. Not adding again.")
			return
	
	# Add the item to the inventory
	items.append(item)
	print("Added item to inventory: ", item.name)
	display_inventory_items()

func remove_item(item):
	if items.has(item):
		items.erase(item)
		print("Removed item: ", item.name)
	else:
		print("Error: Attempted to remove item that doesn't exist in inventory.")
	display_inventory_items()

func get_items():
	return items

# Function to display the current inventory items
func display_inventory_items():
	if items.size() == 0:
		print("Inventory is empty.")
	else:
		print("Current Inventory:")
		for item in items:
			print(item.name, "-", item.description)
