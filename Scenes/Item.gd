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
func _set_item(nm : String, qt : int) -> void:
	item_name = nm
	item_icon_name = item_name.to_lower()
	item_quantity = qt
	icon.texture = load("res://Assets/items/" + item_icon_name + "_item.png")
	
	var stack_size = int(JsonData.item_data[item_name]["StackSize"])
	if stack_size == 1:
		label.visible = false
	else:
		label.visible = true
		label.text = str(item_quantity)
	description = JsonData.item_data[item_name]["Description"]
	category = JsonData.item_data[item_name]["ItemCategory"]
	return

func _increase_item_quantity(amount_to_add : int) -> void:
	item_quantity += amount_to_add
	label.text = str(item_quantity)
	return

func _decrease_item_quantity(amount_to_remove : int) -> void:
	item_quantity -= amount_to_remove
	label.text = str(item_quantity)
	return
