extends Control
@onready var containerOfButtons=%ContainerOfButtons
@onready var buttonScene=preload("button/button.tscn")
var shop_resources:shop_objects
const BROI_ON_SCREEN=3
var _stats:Dictionary[String,String]
var stats_values:Array[String]#TEMPLATE:STATS_VALUES #=_stats.values()
var stats_keys:Array[String]#TEMPLATE:STATS_KEYS  #=_stats.keys()
var stats_size:=stats_keys.size()
var all_items:Array[Item]
var all_items_sz:=all_items.size()
func set_static_labels():
	var tree:Tree=$Tree
	#print(tree.get_first_child())
	var root:TreeItem=tree.get_root()
	var stats_child:TreeItem=root.get_first_child()
	var last_child:=stats_child.get_first_child()
	for e in range(stats_size):
		last_child.set_text(0,stats_keys[e]+":"+str(GlobalVariables.shop_stats.get(stats_values[e])))
		last_child=last_child.get_next()
	stats_child.set_text(0,"Stats")
	#var money_child:TreeItem=stats_child.get_first_child()
	#var money_multiplayer_child:TreeItem=money_child.get_next()
	#var speed_child:TreeItem=money_multiplayer_child.get_next()
	#var max_health_child:TreeItem=speed_child.get_next()
	#var damage_multiplication_child:TreeItem=max_health_child.get_next()
	#stats_child.set_text(0,"Stats")
	#money_child.set_text(0,"Money:"+str(GlobalVariables.shop_stats.money))
	#money_multiplayer_child.set_text(0,"Money multiplayer:"+str(GlobalVariables.shop_stats.get("money_multiplayer")))
	#speed_child.set_text(0,"Speed:"+str(GlobalVariables.shop_stats.player_speed))
	#max_health_child.set_text(0,"Max HP:"+str(GlobalVariables.shop_stats.max_player_health))
	#damage_multiplication_child.set_text(0,"Damage Multiplication:"+str(GlobalVariables.shop_stats.attack_damage_umn))

func make_static_labels():
	var tree:Tree=$Tree
	tree.clear()
	#print(tree.get_first_child())
	var stats_child:TreeItem=tree.create_item()
	stats_child=tree.create_item(stats_child)
	stats_child.collapsed=true
	for e in stats_size:
		var child:TreeItem=tree.create_item(stats_child)
		child.set_text(0,stats_keys[e]+":"+str(GlobalVariables.shop_stats.get(stats_values[e])))
	stats_child.set_text(0,"Stats")
	#var money_child:TreeItem=tree.create_item(stats_child)
	#var money_multiplayer_child:TreeItem=tree.create_item(stats_child)
	#var speed_child:TreeItem=tree.create_item(stats_child)
	#var max_health_child:TreeItem=tree.create_item(stats_child)
	#var damage_multiplication_child:TreeItem=tree.create_item(stats_child)
	#money_child.set_text(0,"Money:"+str(GlobalVariables.shop_stats.money))
	#money_multiplayer_child.set_text(0,"Money multiplayer:"+str(GlobalVariables.shop_stats.money_multiplayer))
	#speed_child.set_text(0,"Speed:"+str(GlobalVariables.shop_stats.player_speed))
	#max_health_child.set_text(0,"Max HP:"+str(GlobalVariables.shop_stats.max_player_health))
	#damage_multiplication_child.set_text(0,"Damage Multiplication:"+str(GlobalVariables.shop_stats.attack_damage_umn))
	for e in all_items_sz:
		var weapon_resource:=all_items[e]
		var first_weapon=tree.create_item()
		first_weapon.collapsed=true
		var tmp_str=weapon_resource.name+"  "
		if GlobalVariables.shop_stats.items.find(weapon_resource)==-1:
			tmp_str+="(N/A)"
		else:tmp_str+="(Aquired)"
		first_weapon.set_text(0,tmp_str)
		first_weapon.add_button(0,weapon_resource.texture)
		var damage_weapon:=tree.create_item(first_weapon)
		damage_weapon.set_text(0,"Damage:"+str(weapon_resource.attack.damage))
		var knockback_weapon:=tree.create_item(first_weapon)
		knockback_weapon.set_text(0,"Knockback:"+str(weapon_resource.attack.knockback))

func update_buttons_of_deals():
	for e in %ContainerOfButtons.get_children():
		if e is ButtonWithResource:
			if e.type==GlobalTypes.types_of_upgrades.ITEM:
				if GlobalVariables.shop_stats.items_sz>=all_items_sz:
					shop_resources.disabled_from_final[e.resourceInd]=true
				
			#print(e.text," ",shop_resources.disabled_from_final[e.resourceInd])
			if GlobalVariables.shop_stats.money<e.res.price||shop_resources.disabled_from_final[e.resourceInd]||!depending_true(e.res):
				e.disabled=true
			else:
				e.disabled=false

func add_buttons_of_deals():
	#delete all children of the container
	for e in %ContainerOfButtons.get_children():
		%ContainerOfButtons.remove_child(e)
	#add all children
	var ind:=0
	for e in shop_resources.resources_at_screen:
		var now=buttonScene.instantiate()
		now.resource=e
		now.level=shop_resources.levels_of_upgrades[e.type]
		now.type=e.type
		now.resourceInd=ind
		now.whoSFunction=call_to_all_buttons;
		containerOfButtons.add_child(now)
		ind+=1

func _ready() -> void:
	#load shop resources
	shop_resources=load_shop_resources()
	#print
	
	#set money,multiplayer...
	make_static_labels()
	#add buttons
	add_buttons_of_deals()
	#update  buttons  
	update_buttons_of_deals()
	# add functionality for debug
	#TEMPLATE:IS_DEBUG_ADD_MONEY$"add 1000 money".visible=OS.is_debug_build()

func call_to_all_buttons(resource:shop_resource_child,type:GlobalTypes.types_of_upgrades,button_who_is_pressed:ButtonWithResource)->void: #called from button.pressed signal
	# upgrade things
	for i in range(0,resource.thingItDo.size()):
		var e=resource.thingItDo.keys()[i]
		GlobalFunctions.interpretate_thing_it_do(e,resource.thingItDo.values()[i])
	#money=money-price
	GlobalVariables.shop_stats.money-=resource.price
	#print
	#print(GlobalVariables.cpu_speed)
	#print(GlobalVariables.money_multiplayer)
	#update some labels
	set_static_labels()
	#add 1 level to the upgrade
	if resource.final:
		#print("final")
		shop_resources.disabled_from_final[button_who_is_pressed.resourceInd]=true
	elif shop_resources.levels_of_upgrades[type]<shop_resources.max_levels_of_upgrades[type]:
		#print("++Level")
		shop_resources.levels_of_upgrades[type]+=1;
		button_who_is_pressed.level+=1;
	print("lvUp:",shop_resources.levels_of_upgrades)
	print("mxLv:",shop_resources.max_levels_of_upgrades)
	button_who_is_pressed.update()
	update_buttons_of_deals()

func depending_true(res:shop_resource_child):
	var depends=res.dependencies
	for i in range(0,depends.size()):
		if shop_resources.levels_of_upgrades[depends.keys()[i]]<depends.values()[i]:
			return false
	return true

func _on_quit_pressed() -> void:
	#TEMPLATE:ON_QUIT
	#TEMPLATE:CHANGE_SCENE
	pass

#TEMPLATE:IS_DEBUG_ADD_MONEYfunc on_add_1000_money_pressed():
	#TEMPLATE:IS_DEBUG_ADD_MONEYif OS.is_debug_build():
		#TEMPLATE:IS_DEBUG_ADD_MONEYGlobalVariables.shop_stats.money+=1000
		#TEMPLATE:IS_DEBUG_ADD_MONEYupdate_buttons_of_deals()
	#TEMPLATE:IS_DEBUG_ADD_MONEYset_static_labels()

func load_shop_resources():
	var ld=GlobalFunctions.load_resource(GlobalLocalization.file_name_of_shop_save)# false or the resource
	if !ld:
		var shop_resources_tmp=shop_objects.new()
		shop_resources_tmp.resources_at_screen=preload("shop_configuration/shop_configuration.tscn").instantiate().shop_upgrades_graph
		shop_resources_tmp.init()
		return shop_resources_tmp
	else:
		return ld
