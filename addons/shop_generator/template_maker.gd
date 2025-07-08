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
		filled_template=filled_template.replace(e,template_variables[e])
	return filled_template
