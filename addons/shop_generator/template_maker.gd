class_name Templater
var template:String
## TEMPLATE:"NAME"=VALUE
var template_variables:Dictionary[String,String]
var filled_template:String
## template,template_variables
func _init(a:String,temp:Dictionary[String,String]) -> void:
	template=a
	template_variables=temp

func fill_template()->String:
	filled_template=template
	for e in template_variables:
		print(e,"->",template_variables[e])
		filled_template=filled_template.replace("#TEMPLATE:"+e,template_variables[e])
	return filled_template

class VariableTemplater:
	var template:="@onready var name:type=default"
	var filled_template:String
	func fill_template(var_name:String,default_var,type_of_var:="")->String:
		filled_template=template.replace("name",var_name)
		filled_template=template.replace("default",str(default_var))
		filled_template=template.replace("type",type_of_var)
		return filled_template
