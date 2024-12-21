extends Node

# Store items as an array of dictionaries (each dictionary has an item and its quantity)
var items = []

func add_item(item, quantity = 1):
	if item == null:
		print("Error: Attempted to add a null item to inventory.")
		return
	
	# Check if the item is actually an `Item` resource
	if not item is Item:
		print("Error: Attempted to add a non-Item resource to inventory.")
		return
	
	# Check if the item already exists
	for existing_item in items:
		if existing_item["item"].name == item.name:
			# If it exists, increase the quantity
			existing_item["quantity"] += quantity
			print("Increased quantity of", item.name, "to", existing_item["quantity"])
			display_inventory_items()
			return
	
	# If the item doesn't exist, add it with the given quantity
	items.append({"item": item, "quantity": quantity})
	print("Added item to inventory: ", item.name, "x", quantity)
	display_inventory_items()

func remove_item(item, quantity = 1):
	for existing_item in items:
		if existing_item["item"] == item:
			# Decrease the quantity or remove it if it's the last one
			existing_item["quantity"] -= quantity
			if existing_item["quantity"] <= 0:
				items.erase(existing_item)
				print("Removed item: ", item.name)
			else:
				print("Decreased quantity of", item.name, "to", existing_item["quantity"])
			display_inventory_items()
			return
	
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
		for entry in items:
			print(entry["item"].name, "-", entry["item"].description, "x", entry["quantity"])
