extends Control

const SLOT_CLASS = preload("res://Scenes/Slot.gd")
onready var crafting_grids = $CraftGrids
func _ready() -> void:
	return


func _add_crafting_slots_on_runtime() -> void:
	var slots = crafting_grids.get_children()
	for i in range(slots.size()):
		slots[i].connect("gui_input", self, "_slot_gui_input", [slots[i]])
		slots[i].slot_index = i
		slots[i].slot_type = SLOT_CLASS.SLOT_TYPE.CRAFTING
	return

func _slot_gui_input(event: InputEvent, slot: SLOT_CLASS):
	var menus = find_parent("Menus")
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed:
			_craft_item()

func _craft_item(craftable_item : Node2D = null):
	return
