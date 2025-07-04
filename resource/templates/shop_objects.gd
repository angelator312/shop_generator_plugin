extends Resource
class_name shop_objects
@export var resources_at_screen:Array[shop_resource]=[]

@export var levels_of_upgrades:Dictionary[GlobalTypes.types_of_upgrades,int]
# max level that you can make ˅˅˅
@export var max_levels_of_upgrades:Dictionary[GlobalTypes.types_of_upgrades,int]={}
@export var disabled_from_final:Array[bool]

func init():
	for e in resources_at_screen:
		disabled_from_final.push_back(false)
	for e in resources_at_screen:
		#print(e.type," ",e.children.size())
		max_levels_of_upgrades.set(e.type,e.children.size()-1)
	for e in resources_at_screen:
		levels_of_upgrades.set(e.type,0)
