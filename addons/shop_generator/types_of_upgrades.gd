@tool
extends Control

const path_for_addon:="res://addons/shop_generator/"
const DELETE_BUTTON = preload(path_for_addon+"delete_button.png")

@onready var tree: Tree = $Tree

const project_setting_types_of_upgrades:="shop_generator/types_of_upgrades"
func get_types_of_upgrades() -> Array:return ProjectSettings.get_setting(project_setting_types_of_upgrades,["Item"]) as Array[String]
func set_types_of_upgrades(a:Array) -> void:ProjectSettings.set_setting(project_setting_types_of_upgrades,a)
func set_size_of_tree(a:Array)->void:tree.size.y=(a.size())*41
# Array[String] are types_of_upgrades
var property_info={
	"name":project_setting_types_of_upgrades,
	"type":TYPE_ARRAY,
	"hint":PROPERTY_HINT_ARRAY_TYPE,
	"hint_string":"String"
}
func _ready() -> void:
	#ProjectSettings.add_property_info(property_info)
	#ProjectSettings.save()
	#print(get_types_of_upgrades() is Array[String])
	generate_tree(get_types_of_upgrades())

func generate_tree(st:Array):
	tree.clear()
	var root:=tree.create_item()
	for e in st:
		var item=tree.create_item()
		item.set_text(0,e)
		if e=="Item":continue
		item.add_button(0,DELETE_BUTTON)
		item.set_editable(0,true)
	set_size_of_tree(st)

func _on_tree_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	var types:=get_types_of_upgrades()
	types.erase(item.get_text(0))
	set_types_of_upgrades(types)
	generate_tree(types)

func _on_add_type_pressed() -> void:
	var types:=get_types_of_upgrades()
	if types.find($TypeName.text)>-1:return
	types.push_back($TypeName.text)
	$TypeName.text=""
	generate_tree(types)
	set_types_of_upgrades(types)

func _on_tree_item_edited() -> void:
	var types:=get_types_of_upgrades()
	var root:TreeItem=tree.get_root()
	var i:=0
	var find_custom=func (a:int,s:String):
		var i2=types.find(s)
		if i2==a:
			return types.find(s,a)
		return i2
	for e in root.get_children():
		if find_custom.call(i,e.get_text(0))==-1:
			types[i]=e.get_text(0)
		else:
			e.set_text(0,types[i])
		i+=1
	set_types_of_upgrades(types)
