extends Resource
class_name ShopStats

@export var money:=0.0
@export var money_multiplayer:=1.0
@export var player_speed:= 300.0
@export var max_player_health:=50.0
@export var attack_damage_umn:=1.0
@export var items:Array[Item]=[]#preload(.....)
@export var items_sz=items.size()
func add_money_multiplayer(amount:float)->void:#amount is in %
	money_multiplayer+=amount/100
func add_attack_percent(amount:float):#amount is in %
	attack_damage_umn+=amount/100
## amount is in %
func add_player_speed(amount:float):
	player_speed+=player_speed*amount/100
func add_max_health(amount:float):
	max_player_health+=amount
func add_item(a:Item) -> bool:
	if items.find(a)>-1:return false
	items.push_back(a)
	items_sz+=1
	return true
func upgrade_item():
	if GlobalVariables.all_items_sz==items_sz:return
	add_item(GlobalVariables.all_items[items_sz])
