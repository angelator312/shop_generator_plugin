@tool
extends Control
@onready var tree: Tree = $Tree
const DOCUMENT_EDIT_ICON :Texture2D= preload("res://addons/shop_generator/e-icon.png")
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
	for e in st:
		var new=stats.create_child()
		new.set_text(0,str(e))
		new.add_button(0,DOCUMENT_EDIT_ICON)
		new.set_editable(0,true)
	tree.size.y=(st.size()+1)*160/5


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
	pass # Replace with function body.
