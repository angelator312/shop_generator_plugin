@tool
extends Control
const DELETE_BUTTON = preload("res://addons/shop_generator/delete_button.png")
# Vars for project settings
const project_setting_for_stats_name:="shop_generator/stats"#Name of Stat -> Mone Multiplayer
const project_setting_for_stat_types:="shop_generator/stat_types" # Vector2,float...
const project_setting_for_stat_defaults:="shop_generator/stat_defaults" # 0.0;0;Vector2(-1,-1)
const project_setting_for_upgrade_types:="shop_generator/types_of_upgrades"
const project_setting_for_items_stats_or_upgrades:="shop_generator/stats_or_upgrade_types_or_items" 
# Paths:
const path_for_addon:="res://addons/shop_generator/"
const shop_path_default="shop/"
const resources_path_default="resources/"
const path_for_shop=path_for_addon+"templates/shop/"
const path_for_resources=path_for_addon+"templates/resources/"
var regex_str="res://"
const arr_of_types:Array[String]=["Vector2","float","int","String"]
var stats_or_upgrade_types_or_items:=0
func _toggle_stats():
	toggle_stats_upgrade_and_items(0)
func _toggle_types():
	toggle_stats_upgrade_and_items(1)

@export_tool_button("Toggle to types") var toggle_types:Callable=_toggle_types
@export_tool_button("Toggle to stats") var toggle_stats:Callable=_toggle_stats
#Functions for Godot tree

func _ready() -> void:
	stats_or_upgrade_types_or_items=ProjectSettings.get_setting(project_setting_for_items_stats_or_upgrades,0)
	toggle_stats_upgrade_and_items(stats_or_upgrade_types_or_items)
	

func _exit_tree() -> void:
	ProjectSettings.set_setting(project_setting_for_items_stats_or_upgrades,stats_or_upgrade_types_or_items)

#For Line edit:
func _on_line_edit_editing_toggled(toggled_on: bool) -> void:
	if toggled_on:return
	$ShopPath.text=$ShopPath.text.replace(regex_str,"")
	print($ShopPath.text)

#Generate shop:
func _on_generate_pressed() -> void:
	var shop_path_now=$ShopPath.text if $ShopPath.text else shop_path_default
	var resources_path_now:String=$ResourcePath.text if $ResourcePath.text else resources_path_default
	var path_for_new_shop:String="res://"+shop_path_now
	var path_for_new_resources:String="res://"+resources_path_now
	var new_shop_stats_path=path_for_new_resources+"shop_stats.gd"
	#Resource things:
	var path_to_shop_objects:=path_for_new_resources+"shop_objects.gd"
	var path_to_shop_resource:=path_for_new_resources+"shop_resource.gd"
	var path_to_shop_resource_child:=path_for_new_resources+"shop_resource_child.gd"
	var path_to_item:=path_for_new_resources+"Item.gd"
	var path_to_global_types:=path_for_new_resources+"GlobalTypes.gd"
	#Shop things:
	var path_for_new_shop_script:=path_for_new_shop+"shop.gd"
	var path_to_button_script:=path_for_new_shop+"button/button.gd"
	
	DirAccess.make_dir_recursive_absolute("res://"+shop_path_now)
	DirAccess.make_dir_recursive_absolute(path_for_new_resources)
	DirAccess.remove_absolute(new_shop_stats_path)
	copy_dir_recursively(path_for_shop,"res://"+shop_path_now)
	copy_dir_recursively(path_for_resources,path_for_new_resources)
	
	#GlobalTypes:
	var types_of_upgrades:Array=ProjectSettings.get_setting(project_setting_for_upgrade_types,["Item"])
	types_of_upgrades=types_of_upgrades.map(func(a:String):return a.replace(" ","_").to_upper())
	use_template_on(path_to_global_types,{
		"TYPES_OF_UPGRADES":",".join(types_of_upgrades)
	})
	
	#Small templates:
	use_template_on(path_to_shop_resource_child,{})
	use_template_on(path_to_shop_resource,{})
	use_template_on(path_to_shop_objects,{})
	use_template_on(path_to_button_script,{})
	use_template_on(path_to_item,{})
	#Shop.gd:
	var stats_names:Array=ProjectSettings.get_setting(project_setting_for_stats_name,[])
	var stats_types:Array=ProjectSettings.get_setting(project_setting_for_stat_types,[])
	var stats_defaults=ProjectSettings.get_setting(project_setting_for_stat_defaults,[])
	var stats_variable_names:Array=stats_names.map(func(el:String):return el.replace(" ","_").to_lower())
	var shop_vars:Dictionary[String,String]={
		"STATS_KEYS":'=["'+'","'.join(stats_names)+'"]',
		"STATS_VALUES":'=["'+'","'.join(stats_variable_names)+'"]',
		#"IS_DEBUG_ADD_MONEY":"", - is there add 1000 money button
		#"CHANGE_SCENE":'SceneManager.change_scene' - change the scene
		#"ON_QUIT":"GlobalFunctions.save_shop_resource(shop_resources)", - things before scene changing, there us shop_resources variable with everything for the shop
		"FILENAME_OF_SHOP_SAVE":"shopsave.tres"
	}
	if $CheckBox.button_pressed:
		shop_vars.get_or_add("IS_DEBUG_ADD_MONEY","")
	use_template_on(path_for_new_shop_script,shop_vars)
	
	#ShopStats.gd:
	var variable_arr:=[]
	
	for idx in stats_names.size():
		var a:=Templater.VariableTemplater.new()
		a.fill_template(stats_names[idx],arr_of_types[stats_types[idx]],stats_defaults[idx])
		variable_arr.push_back(a.filled_template)
	use_template_on(new_shop_stats_path,{
		#"ITEMS_SZ":"" - turn items on
		#"ITEMS":"=[''...]" - set start items for player
		#"FUNCTIONS":"func()..." - add functions in shop_stats
		#"VARIABLES":"@export var var_name:type_of_var=default_var\n"
		"VARIABLES":"\n".join(variable_arr)
	})

func copy_dir_recursively(source: String, destination: String):
	DirAccess.make_dir_recursive_absolute(destination)
	
	var source_dir = DirAccess.open(source);
	
	for filename in source_dir.get_files():
		if filename.ends_with(".uid"):continue
		if filename=="shop_configuration.tscn":
			if FileAccess.file_exists(destination+filename):
				print("shop configuration is reused")
				continue
		source_dir.copy(source + filename, destination + filename)
		
	for dir in source_dir.get_directories():
		self.copy_dir_recursively(source + dir + "/", destination + dir + "/")

func use_template_on(path_to_file:String,template_vars:Dictionary[String,String])->void:
	var template:GDScript=ResourceLoader.load(path_to_file,"",ResourceLoader.CACHE_MODE_IGNORE)
	var shop_template:=Templater.new(template.source_code,template_vars)
	template.source_code=shop_template.fill_template()
	ResourceSaver.save(template,path_to_file)
	print("path:",path_to_file)

#Delete Shop:
func _on_delete_pressed() -> void:
	var shop_path_now=$ShopPath.text if $ShopPath.text else shop_path_default
	var resources_path_now:String=$ResourcePath.text if $ResourcePath.text else resources_path_default
	remove_dir_recursively("res://"+shop_path_now)
	remove_dir_recursively("res://"+resources_path_now)

func remove_dir_recursively(path:String)->void:
	var source_dir:=DirAccess.open(path)
	for filename in source_dir.get_files():
		source_dir.remove(path + filename)
	
	for dir in source_dir.get_directories():
		remove_dir_recursively(path + dir + "/")
	
	source_dir.remove("")

func toggle_stats_upgrade_and_items(toggled_on: int) -> void:
	stats_or_upgrade_types_or_items=toggled_on
	%StatsOrUpgradeTypes.selected=toggled_on
	match toggled_on:
		0:
			$Stats.visible=true
			$TypesOfUpgrades.visible=false
			$Stats._ready()
		1:
			$Stats.visible=false
			$TypesOfUpgrades.visible=true
			$TypesOfUpgrades._ready()
		2:
			#TODO:Switch to items tab 
			pass

func _on_stats_or_upgrade_types_item_selected(index: int) -> void:
	toggle_stats_upgrade_and_items(index)
