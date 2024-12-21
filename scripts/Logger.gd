# Logger.gd
extends Node

# Singleton instance for easy access
var messages = []

@export var max_messages = 10  # Maximum number of messages to display

# Adds a new message to the log
func log_message(message: String):
	# Add the message to the array
	messages.append(message)
	
	# Remove the oldest message if we exceed the max_messages limit
	if messages.size() > max_messages:
		messages.remove(0)
	
	# Update the label (if it exists)
	if get_tree().has_current_scene():
		var current_scene = get_tree().current_scene
		var label = current_scene.get_node_or_null("ConsoleLabel")
		if label:
			label.text = messages.join("\n")
func clear_log():
	messages.clear()
	if get_tree().has_current_scene():
		var label = get_tree().current_scene.get_node_or_null("ConsoleLabel")
		if label:
			label.text = ""
