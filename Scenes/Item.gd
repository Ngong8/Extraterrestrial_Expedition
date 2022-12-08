extends Node2D
class_name ITEM

var item_name : String
var item_icon_name : String
var item_quantity : int

onready var icon = get_node("%Icon")
onready var label = get_node("%Label")
func _ready() -> void:
#	icon.texture = load("res://Assets/items/" + item_icon_name + "_item.png")
#	var stack_size = int(JsonData.item_data[item_name]["StackSize"])
#	item_quantity = randi() % stack_size + 1
#
#	if stack_size == 1:
#		label.visible = false
#	else:
#		label.visible = true
#		label.text = str(item_quantity)
	return

var description : String;	var category : String;
var attack_mode : bool
var current_shield_cap : int;	var shield_cap : int
var shield_recharge_delay : float;	var shield_recharge_rate : float
var armor_rating : int
var recipe
func _set_item(nm : String, qt : int) -> void:
	item_name = nm
	item_icon_name = item_name.to_lower()
	item_quantity = qt
	description = JsonData.item_data[item_name]["Description"]
	category = JsonData.item_data[item_name]["ItemCategory"]
	if JsonData.item_data[item_name].has("Recipe"):
		recipe = JsonData.item_data[item_name]["Recipe"]
#		print_debug(recipe)
	icon.texture = load("res://Assets/items/" + item_icon_name + "_item.png")
	if category == "Weapon":
		icon.texture = load("res://Assets/items/" + item_icon_name + "_item_1.png")
		attack_mode = JsonData.item_data[item_name]["AttackMode"]
	if category == "Suit":
		shield_cap = JsonData.item_data[item_name]["ItemShield"]
		current_shield_cap = shield_cap
		shield_recharge_rate = JsonData.item_data[item_name]["ItemShieldRechargeRate"]
		shield_recharge_delay = JsonData.item_data[item_name]["ItemShieldRechargeDelay"]
		armor_rating = JsonData.item_data[item_name]["ItemDefense"]
	
	var stack_size = int(JsonData.item_data[item_name]["StackSize"])
	if stack_size == 1:
		label.visible = false
	else:
		label.visible = true
		label.text = str(item_quantity)
	return

func _increase_item_quantity(amount_to_add : int) -> void:
	item_quantity += amount_to_add
	label.text = str(item_quantity)
	return

func _decrease_item_quantity(amount_to_remove : int) -> void:
	item_quantity -= amount_to_remove
	label.text = str(item_quantity)
	return
