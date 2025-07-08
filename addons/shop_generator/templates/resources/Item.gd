extends Resource
#TEMPLATE:IS_TEMPLATEclass_name Item
 
@export var name : String
@export var texture : Texture2D
@export var attack : Attack=Attack.new()
@export var hitbox:String="Sword"
@export var animation : String
@export var projectile : int
 
