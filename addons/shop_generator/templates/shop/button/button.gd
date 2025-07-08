extends Button
class_name ButtonWithResource
var whoSFunction:=func(_x:shop_resource_child,_type,_node:ButtonWithResource):
	pass
var resource:shop_resource
var resourceInd:int=0
var res:shop_resource_child
var type:GlobalTypes.types_of_upgrades
var level:=0
func _ready() -> void:
	update()
func update() -> void:
	self.res=resource.children[level]
	self.text=res.textInMe

func _pressed():
	whoSFunction.call(res,type,self)
