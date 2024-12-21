extends Node
# Assuming each item is stored as a dictionary with "item" and "quantity"
var inventory_items = []  # Stores inventory items as [{item, quantity}, ...]

func add_item(item: Item):
	# Check if the item is already in the inventory
	for inv_item in inventory_items:
		if inv_item["item"].name == item.name:
			inv_item["quantity"] += 1  # Increment quantity if item already exists
			print("Increased quantity of: ", item.name, " to ", inv_item["quantity"])
			return
	
	# Otherwise, add the new item to the inventory
	inventory_items.append({"item": item, "quantity": 1})
	print("Added new item to inventory: ", item.name)

func remove_item(item: Item):
	for i in range(inventory_items.size()):
		if inventory_items[i]["item"].name == item.name:
			if inventory_items[i]["quantity"] > 1:
				inventory_items[i]["quantity"] -= 1  # Reduce quantity
				print("Reduced quantity of: ", item.name, " to ", inventory_items[i]["quantity"])
			else:
				inventory_items.remove_at(i)  # Remove the item from inventory if quantity is 0
				print("Removed item: ", item.name)
			break  # Exit the loop once the item is found and removed

# Get current inventory items
func get_items():
	return inventory_items

# Display current inventory items in the console (for debugging)
func display_inventory_items():
	if inventory_items.size() == 0:
		print("Inventory is empty.")
	else:
		print("Current Inventory:")
		for entry in inventory_items:
			print(entry["item"].name, "x", entry["quantity"])
