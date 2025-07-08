@tool
extends Control
@onready var tree: Tree = $Tree
const DELETE_BUTTON = preload("res://addons/shop_generator/delete_button.png")
#const DOCUMENT_EDIT_ICON :Texture2D= preload("res://addons/shop_generator/e-icon.png")
const path_for_addon:="res://addons/shop_generator/"
const project_setting_for_stats_name:="shop_generator/stats"
const project_setting_for_stat_types:="shop_generator/stat_types"
const shop_path_default="shop/"
const resources_path_default="resources/"
const path_for_shop=path_for_addon+"templates/shop/"
const path_for_resources=path_for_addon+"templates/resources/"
var regex_str="res://"
const arr_of_types:Array[String]=["Vector2","float","int","String"]
func add_stat():
	print("add_stat")
	var stats=ProjectSettings.get_setting(project_setting_for_stats_name,[])
	var stats_types=ProjectSettings.get_setting(project_setting_for_stat_types,[])
	if stats.find(%StatName.text)>-1:
		%StatName.text=""
		return
	stats.push_back(%StatName.text)
	print("stats:",stats)
	stats_types.push_back(%Dropdown.selected)
	print("stats:",stats)
	ProjectSettings.set_setting(project_setting_for_stats_name,stats)
	ProjectSettings.set_setting(project_setting_for_stat_types,stats_types)
	%StatName.text=""
	make_tree(stats,stats_types)

func _ready() -> void:
	_on_reload_button_pressed()
	%Dropdown.clear()
	for e in arr_of_types:
		%Dropdown.add_item(e)

#Tree:
func make_tree(st:Array,st2:Array):
	tree.clear()
	tree.create_item()
	var stats:=tree.create_item()
	stats.set_text(0,"Stats:")
	var i:=0
	for e in st:
		var new=stats.create_child()
		new.set_text(0,str(e))
		new.add_button(1,DELETE_BUTTON,i,false,"delete stat")
		new.set_editable(0,true)
		new.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
		new.set_text(1, ",".join(arr_of_types))
		new.set_range(1,st2[i])
		new.set_editable(1, true)
		i+=1
	
	tree.size.y=(st.size())*41+41
	%ReloadButton.position.y=tree.size.y+tree.position.y+25

func _on_reload_button_pressed() -> void:
	make_tree(ProjectSettings.get_setting(project_setting_for_stats_name,[]),ProjectSettings.get_setting(project_setting_for_stat_types,[]))

func _on_tree_item_edited() -> void:
	var stats=tree.get_root().get_first_child()
	var i:=0
	var stats_arr:Array=ProjectSettings.get_setting(project_setting_for_stats_name,[])
	var stats_types:Array=ProjectSettings.get_setting(project_setting_for_stat_types,[])
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
		i+=1

func _on_tree_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	var stats:Array=ProjectSettings.get_setting(project_setting_for_stats_name,[])
	var stats_types:Array=ProjectSettings.get_setting(project_setting_for_stat_types,[])
	stats.remove_at(id)
	stats_types.remove_at(id)
	ProjectSettings.set_setting(project_setting_for_stats_name,stats)
	ProjectSettings.set_setting(project_setting_for_stat_types,stats_types)
	make_tree(stats,stats_types)

#Line edit
func _on_line_edit_editing_toggled(toggled_on: bool) -> void:
	if toggled_on:return
	$ShopPath.text=$ShopPath.text.replace(regex_str,"")
	print($ShopPath.text)

#Generate:
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
	
	DirAccess.make_dir_recursive_absolute("res://"+shop_path_now)
	DirAccess.make_dir_recursive_absolute(path_for_new_resources)
	copy_dir_recursively(path_for_shop,"res://"+shop_path_now)
	copy_dir_recursively(path_for_resources,path_for_new_resources)
	
	#Small templates:
	use_template_on(path_to_button_script,{})
	use_template_on(path_to_shop_objects,{})
	use_template_on(path_to_shop_resource,{})
	use_template_on(path_to_shop_resource_child,{})
	
	#Shop.gd:
	var stats_names:Array=ProjectSettings.get_setting(project_setting_for_stats_name,[])
	var stats_types:Array=ProjectSettings.get_setting(project_setting_for_stat_types,[])
	var stats_variable_names:Array=stats_names.map(func(el:String):return el.replace(" ","_").to_lower())
	use_template_on(path_for_new_shop_script,{
		"STATS_KEYS":'=["'+'","'.join(stats_names)+'"]',"STATS_VALUES":'=["'+'","'.join(stats_variable_names)+'"]'})
	
	#ShopStats.gd:
	var variable_arr:=[]
	
	for idx in stats_names.size():
		var a:=Templater.VariableTemplater.new()
		a.fill_template(stats_names[idx],arr_of_types[stats_types[idx]])
		variable_arr.push_back(a.filled_template)
	use_template_on(new_shop_stats_path,{
		#"ITEMS_SZ":"" - turn items on
		#"ITEMS":"=[''...]" - set items
		#"FUNCTIONS":"func()..." - add functions in shop_stats
		#"VARIABLES":"@export var var_name:type_of_var=default_var\n"
		"VARIABLES":"\n".join(variable_arr)
	})
	

func copy_dir_recursively(source: String, destination: String):
	DirAccess.make_dir_recursive_absolute(destination)
	
	var source_dir = DirAccess.open(source);
	
	for filename in source_dir.get_files():
		if filename.ends_with(".uid"):continue
		source_dir.copy(source + filename, destination + filename)
		
	for dir in source_dir.get_directories():
		self.copy_dir_recursively(source + dir + "/", destination + dir + "/")

func use_template_on(path_to_file:String,template_vars:Dictionary[String,String])->void:
	var template:GDScript=load(path_to_file)
	var shop_template:=Templater.new(template.source_code,template_vars)
	template.source_code=shop_template.fill_template()
	ResourceSaver.save(template,path_to_file)
	print("path:",path_to_file)


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
