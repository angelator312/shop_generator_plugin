extends PopupPanel
func add_stat():
	print("add_stat")
	var stats:Array=ProjectSettings.get_setting("shop_generator/stats")
	if !stats:stats=[]
	stats.push_back(%StatName.text)
	ProjectSettings.set_setting("shop_generator/stats",stats)
	var new_stat=Label.new()
	new_stat.name=%StatName.text
	new_stat.text=%StatName.text
	$Control/Stats.add_child(new_stat)
