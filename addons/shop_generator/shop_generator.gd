@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_tool_menu_item("generate shop",open_shop_screen)
	# Initialization of the plugin goes here.

func open_shop_screen():
	pass

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_tool_menu_item("generate shop")
