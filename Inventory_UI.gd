extends Control  # The root node is "Control"

var slot_count = 16
var selected_index = 0
var items = []  # Holds the current items to display in the inventory

@onready var grid = $InventoryUI/GridContainer  # Reference the GridContainer under InventoryUI
@onready var description_label = $LabelUI  # Reference the Label under Control

func _ready():
	# Debugging: Check if grid and label are valid
	if grid == null:
		printerr("Error: GridContainer is null. Please check the node path.")
		return

	if description_label == null:
		printerr("Error: LabelUI is null. Please check the node path.")
		return

	visible = false  # Hide inventory UI at the start

	# Initialize the UI with empty slots
	initialize_slots()

	description_label.text = ""  # Clear the label text

func initialize_slots():
	var slot_texture = load("res://art/slot.png")  # Load empty slot texture
	for i in range(slot_count):
		var slot_name = "TextureRect" + str(i + 1)
		if grid.has_node(slot_name):
			var slot = grid.get_node(slot_name) as TextureRect  # Access the numbered TextureRect
			if slot:
				slot.texture = slot_texture
			else:
				printerr("Error: Child at index", i, "is not a TextureRect.")
		else:
			printerr("Error: Slot node not found:", slot_name)

func set_items(new_items: Array):
	# Set the items to the new list of items from InventoryManager
	items = new_items
	update_inventory_ui()

func _process(delta):
	if Input.is_action_just_pressed("inventory"):
		visible = not visible
		if visible:
			update_inventory_ui()  # Update inventory UI when it's opened

	if visible and grid != null:
		handle_navigation()

func update_inventory_ui():
	if grid == null:
		printerr("Error: GridContainer is null.")
		return

	# Fetch items from the inventory manager
	items = InventoryManager.get_items()
	print("Updating Inventory UI with items:", items)

	var slot_texture = load("res://art/slot.png")  # Load empty slot texture
	for i in range(slot_count):
		var slot_name = "TextureRect" + str(i + 1)
		if grid.has_node(slot_name):
			var slot = grid.get_node(slot_name) as TextureRect
			if slot:
				if i < items.size():
					var item = items[i]["item"]
					if item.icon:
						slot.texture = item.icon
						print("Displaying icon for item:", item.name)
					else:
						printerr("Error: No icon for item:", item.name)
						slot.texture = slot_texture  # Fallback to empty slot texture
				else:
					slot.texture = slot_texture  # Show empty slot
			else:
				printerr("Error: Child at index", i, "is not a TextureRect.")
		else:
			printerr("Error: Slot node not found:", slot_name)

	update_selection()

func handle_navigation():
	if Input.is_action_just_pressed("ui_up"):
		selected_index = (selected_index - 4 + slot_count) % slot_count
		update_selection()
	elif Input.is_action_just_pressed("ui_down"):
		selected_index = (selected_index + 4) % slot_count
		update_selection()
	elif Input.is_action_just_pressed("ui_left"):
		selected_index = (selected_index - 1 + slot_count) % slot_count
		update_selection()
	elif Input.is_action_just_pressed("ui_right"):
		selected_index = (selected_index + 1) % slot_count
		update_selection()

func update_selection():
	if grid == null:
		printerr("Error: GridContainer is null.")
		return

	for i in range(slot_count):
		var slot_name = "TextureRect" + str(i + 1)
		if grid.has_node(slot_name):
			var slot = grid.get_node(slot_name) as TextureRect
			if slot:
				if i == selected_index:
					slot.modulate = Color(1, 1, 1, 1)  # Highlight selected slot
					if i < items.size():
						description_label.text = items[i]["item"].description
						print("Selected item:", items[i]["item"].name)
					else:
						description_label.text = "Empty"
				else:
					slot.modulate = Color(0.7, 0.7, 0.7, 1)  # Dim non-selected slots
			else:
				printerr("Error: Child at index", i, "is not a TextureRect.")
		else:
			printerr("Error: Slot node not found:", slot_name)
