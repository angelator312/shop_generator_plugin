@tool
extends Control
@onready var tree: Tree = $Tree
const DELETE_BUTTON = preload("res://addons/shop_generator/delete_button.png")
# Vars for project settings
const project_setting_for_stats_name:="shop_generator/stats"#Name of Stat -> Mone Multiplayer
const project_setting_for_stat_types:="shop_generator/stat_types" # Vector2,float...
const project_setting_for_stat_defaults:="shop_generator/stat_defaults" # 0.0;0;Vector2(-1,-1)
# Paths:
const path_for_addon:="res://addons/shop_generator/"
const shop_path_default="shop/"
const resources_path_default="resources/"
const path_for_shop=path_for_addon+"templates/shop/"
const path_for_resources=path_for_addon+"templates/resources/"
var regex_str="res://"
const arr_of_types:Array[String]=["Vector2","float","int","String"]

func _ready() -> void:
	_on_reload_button_pressed()
	%Dropdown.clear()
	for e in arr_of_types:
		%Dropdown.add_item(e)

#Tree:
func add_stat():
	print("add_stat")
	var stats=ProjectSettings.get_setting(project_setting_for_stats_name,[])
	var stats_types=ProjectSettings.get_setting(project_setting_for_stat_types,[])
	var stats_defaults=ProjectSettings.get_setting(project_setting_for_stat_defaults,[])
	if stats.find(%StatName.text)>-1:
		%StatName.text=""
		return
	stats.push_back(%StatName.text)
	print("stats:",stats)
	stats_types.push_back(%Dropdown.selected)
	stats_defaults.push_back(%StatDefault.text)
	ProjectSettings.set_setting(project_setting_for_stats_name,stats)
	ProjectSettings.set_setting(project_setting_for_stat_types,stats_types)
	ProjectSettings.set_setting(project_setting_for_stat_defaults,stats_defaults)
	%StatName.text=""
	make_tree(stats,stats_types,stats_defaults)

func make_tree(st:Array,st2:Array,st3:Array):
	tree.clear()
	tree.create_item()
	var stats:=tree.create_item()
	stats.set_text(0,"Names:")
	stats.set_text(1,"Types:")
	stats.set_text(2,"Defaults:")
	
	var i:=0
	for e in st:
		var new=stats.create_child()
		new.set_text(0,str(e))
		new.set_editable(0,true)
		
		new.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
		new.set_text(1, ",".join(arr_of_types))
		new.set_range(1,st2[i])
		new.set_editable(1, true)
		
		new.set_text(2,str(st3[i]))
		new.set_editable(2,true)
		
		new.add_button(2,DELETE_BUTTON,i,false,"delete stat")
		i+=1
	
	tree.size.y=(st.size())*41+41
	%ReloadButton.position.y=tree.size.y+tree.position.y+25

func _on_reload_button_pressed() -> void:
	make_tree(ProjectSettings.get_setting(project_setting_for_stats_name,[]),
	ProjectSettings.get_setting(project_setting_for_stat_types,[]),
	ProjectSettings.get_setting(project_setting_for_stat_defaults,[]),
	)

func _on_tree_item_edited() -> void:
	var stats=tree.get_root().get_first_child()
	var i:=0
	var stats_arr:Array=ProjectSettings.get_setting(project_setting_for_stats_name,[])
	var stats_types:Array=ProjectSettings.get_setting(project_setting_for_stat_types,[])
	var stats_deafults:Array=ProjectSettings.get_setting(project_setting_for_stat_defaults,[])
	var find_custom=func (a:int,s:String):
		var i2=stats_arr.find(s)
		if i2==a:
			return stats_arr.find(s,a)
		return i2
	for e in stats.get_children():
		if find_custom.call(i,e.get_text(0))==-1:
			stats_arr[i]=e.get_text(0)
		else:
			e.set_text(0,stats_arr[i])
		stats_types[i]=e.get_range(1)
		stats_deafults[i]=e.get_text(2)
		i+=1

func _on_tree_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	var stats:Array=ProjectSettings.get_setting(project_setting_for_stats_name,[])
	var stats_types:Array=ProjectSettings.get_setting(project_setting_for_stat_types,[])
	var stats_defaults:Array=ProjectSettings.get_setting(project_setting_for_stat_defaults,[])
	stats.remove_at(id)
	stats_types.remove_at(id)
	stats_defaults.remove_at(id)
	ProjectSettings.set_setting(project_setting_for_stats_name,stats)
	ProjectSettings.set_setting(project_setting_for_stat_types,stats_types)
	ProjectSettings.set_setting(project_setting_for_stat_defaults,stats_defaults)
	make_tree(stats,stats_types,stats_defaults)
