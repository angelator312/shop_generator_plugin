@tool
extends EditorPlugin
const SHOP_TAB = preload("res://addons/shop_generator/shop_tab.tscn")
#const MainPanel = preload("res://addons/main_screen/main_panel.tscn")

var main_panel_instance


func _enter_tree():
	main_panel_instance = SHOP_TAB.instantiate()
	# Add the main panel to the editor's main viewport.
	EditorInterface.get_editor_main_screen().add_child(main_panel_instance)
	# Hide the main panel. Very much required.
	_make_visible(false)


func _exit_tree():
	EditorInterface.get_editor_main_screen().remove_child(main_panel_instance)
	


func _has_main_screen():
	return true


func _make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible


func _get_plugin_name():
	return "Shop Configuration"


func _get_plugin_icon():
	# Must return some kind of Texture for the icon.
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
