@tool
extends Control
@onready var tree: Tree = $Tree
const DELETE_BUTTON = preload("res://addons/shop_generator/delete_button.png")
#const DOCUMENT_EDIT_ICON :Texture2D= preload("res://addons/shop_generator/e-icon.png")
const shop_path_default="shop/"
const resources_path_default="resources/"
const path_for_addon:="res://addons/shop_generator/"
const path_for_shop=path_for_addon+"templates/shop/"
var regex_str="res://"
func add_stat():
	print("add_stat")
	var stats=ProjectSettings.get_setting("shop_generator/stats",[])
	if stats.find(%StatName.text)>-1:
		%StatName.text=""
		return
	stats.push_back(%StatName.text)
	ProjectSettings.set_setting("shop_generator/stats",stats)
	var new_stat=Label.new()
	new_stat.name=%StatName.text
	new_stat.text=%StatName.text
	%StatName.text=""
	make_tree(stats)

func _ready() -> void:
	make_tree(ProjectSettings.get_setting("shop_generator/stats",[]))

func make_tree(st:Array):
	tree.clear()
	tree.create_item()
	var stats:=tree.create_item()
	stats.set_text(0,"Stats:")
	var i:=0
	for e in st:
		var new=stats.create_child()
		new.set_text(0,str(e))
		new.add_button(0,DELETE_BUTTON,i,false,"delete stat")
		new.set_editable(0,true)
		i+=1
	
	tree.size.y=(st.size())*41+41


#func _on_tree_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	#pass # Replace with function body.
#


func _on_tree_item_edited() -> void:
	var stats=tree.get_root().get_first_child()
	var i:=0
	var stats_arr:Array=ProjectSettings.get_setting("shop_generator/stats",[])
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
		i+=1


func _on_tree_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	var stats:Array=ProjectSettings.get_setting("shop_generator/stats",[])
	stats.remove_at(id)
	ProjectSettings.set_setting("shop_generator/stats",stats)
	make_tree(stats)


func _on_line_edit_editing_toggled(toggled_on: bool) -> void:
	if toggled_on:return
	$ShopPath.text=$ShopPath.text.replace(regex_str,"")
	print($ShopPath.text)
	

func _on_generate_pressed() -> void:
	var shop_path_now=$ShopPath.text if $ShopPath.text else shop_path_default
	var resources_path_now:String=$ResourcePath.text if $ResourcePath.text else resources_path_default
	var path_for_new_shop:String="res://"+shop_path_now
	var new_shop_stats_path="res://"+resources_path_now+"shop_stats.gd"
	var path_for_new_shop_script:=path_for_new_shop+"shop.gd"
	DirAccess.make_dir_recursive_absolute("res://"+shop_path_now)
	DirAccess.make_dir_recursive_absolute(path_for_addon+"templates/resources/")
	copy_dir_recursively(path_for_shop,"res://"+shop_path_now)
	copy_dir_recursively(path_for_addon+"templates/resources/","res://"+resources_path_now)
	
	var shop_file:=FileAccess.open(path_for_new_shop_script,FileAccess.READ_WRITE)
	var stats_names:Array=ProjectSettings.get_setting("shop_generator/stats",[]) as Array[String]
	var stats_variable_names:Array=stats_names.map(func(el:String):return el.replace(" ","_").to_lower())
	var shop_template:=Templater.new(shop_file.get_as_text(),{
		"STATS_KEYS":'=["'+'","'.join(stats_names)+'"]',"STATS_VALUES":'=["'+'","'.join(stats_variable_names)+'"]'})
	shop_file.store_string(shop_template.filled_template)
	shop_file.close()
	
	var callab=func(el:String):
		var tmp:=Templater.VariableTemplater.new()
		tmp.fill_template(el,'""')
		print("var_params:",el,",","")
		print("var:",tmp.filled_template)
		return tmp.filled_template
		
	var shop_stats_file:=FileAccess.open(new_shop_stats_path,FileAccess.READ_WRITE)
	var variable_arr:Array=stats_variable_names.map(callab)
	var shop_stats_template:=Templater.new(shop_stats_file.get_as_text(),{
		#"ITEMS_SZ":"" - turn items on
		#"ITEMS":"=[''...]" - set items
		#"FUNCTIONS":"func()..." - add functions in shop_stats
		#"VARIABLES":"@export var var_name:type_of_var=default_var\n"
		"VARIABLES":"\n".join(variable_arr)
	})
	print("start:",shop_stats_file.get_as_text())
	print("filled template:\n",shop_stats_template.fill_template())
	shop_stats_file.store_string(shop_stats_template.filled_template)
	shop_stats_file.close()

func copy_dir_recursively(source: String, destination: String):
	DirAccess.make_dir_recursive_absolute(destination)
	
	var source_dir = DirAccess.open(source);
	
	for filename in source_dir.get_files():
		source_dir.copy(source + filename, destination + filename)
		
	for dir in source_dir.get_directories():
		self.copy_dir_recursively(source + dir + "/", destination + dir + "/")
