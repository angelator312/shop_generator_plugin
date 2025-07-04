@tool
extends EditorPlugin

var popup=preload("res://addons/shop_generator/popup.tscn").instantiate()
var tool_menu_name="Generate shop"
func _enter_tree() -> void:
	add_tool_menu_item(tool_menu_name,open_shop_screen)
	# Initialization of the plugin goes here.

func open_shop_screen():
	if not popup.get_parent():
		add_child(popup)
	popup.popup_centered(Vector2i(1000,600))
func _exit_tree() -> void:
	if popup.get_parent():
		popup.get_parent().remove_child(popup)
	# Clean-up of the plugin goes here.
	remove_tool_menu_item(tool_menu_name)
