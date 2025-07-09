extends Resource
#TEMPLATE:IS_TEMPLATEclass_name shop_resource_child
@export var textInMe:="add 1 speed"
#@export var thingItDo:Array[Dictionary[GlobalTypes.whatYouChange,int]]
@export var thingItDo:Dictionary[GlobalTypes.types_of_changes,float]={}
@export var price=0
@export var final:=false
@export var dependencies:Dictionary[GlobalTypes.types_of_upgrades,int]={}
