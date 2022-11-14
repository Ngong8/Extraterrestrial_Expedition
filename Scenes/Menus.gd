extends CanvasLayer

onready var dirt_btn = get_node("%DirtBtn")
onready var stone_btn = get_node("%StoneBtn")
onready var milkore_btn = get_node("%MilkoreBtn")
var dirt_item : int = 0;	var stone_item : int = 0;	var milkore_item : int = 0
func _ready() -> void:
	stone_btn.icon.set("region", Rect2(32,0, 32,32))
	milkore_btn.icon.set("region", Rect2(64,0, 32,32))
	
	dirt_btn.text = str(dirt_item)
	stone_btn.text = str(stone_item)
	milkore_btn.text = str(milkore_item)
	return

func _add_item_count(item_name : String = "") -> void:
	if item_name == "" or item_name == "dirt":
		dirt_item += 1
		dirt_btn.text = str(dirt_item)
	return

