@tool
extends Control
@onready var tree: Tree = %Tree
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
	var path_for_new_shop_script:=path_for_new_shop+"shop.gd"
	var path_to_button_script:=path_for_new_shop+"button/button.gd"
	var path_to_shop_objects:=path_for_new_resources+"shop_objects.gd"
	var path_to_shop_resource:=path_for_new_resources+"shop_resource.gd"
	var path_to_shop_resource_child:=path_for_new_resources+"shop_resource_child.gd"
	var path_to_item:=path_for_new_resources+"Item.gd"
	
	DirAccess.make_dir_recursive_absolute("res://"+shop_path_now)
	DirAccess.make_dir_recursive_absolute(path_for_new_resources)
	DirAccess.remove_absolute(new_shop_stats_path)
	copy_dir_recursively(path_for_shop,"res://"+shop_path_now)
	copy_dir_recursively(path_for_resources,path_for_new_resources)
	
	#Small templates:
	use_template_on(path_to_item,{})
	use_template_on(path_to_button_script,{})
	use_template_on(path_to_shop_objects,{})
	use_template_on(path_to_shop_resource,{})
	use_template_on(path_to_shop_resource_child,{})
	
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

func _on_toggled_stats_or_upgrade_types(toggled_on: bool) -> void:
	if toggled_on:
		#TODO:Switch to upgrade types
		return
	#TODO: Switch to stats 
