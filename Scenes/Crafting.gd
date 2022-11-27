extends Control

const SLOT_CLASS = preload("res://Scenes/Slot.gd")
onready var crafting_grids = $CraftGrids
onready var slots = crafting_grids.get_children()
func _ready() -> void:
	_initialize_crafting()
	for i in range(slots.size()):
		slots[i].connect("gui_input", self, "_slot_gui_input", [slots[i]])
		slots[i].slot_index = i
		slots[i].slot_type = SLOT_CLASS.SLOT_TYPE.CRAFTING
	return

func _initialize_crafting() -> void:
	for i in range(slots.size()):
		if PlayerInventory.crafting.has(i):
			slots[i]._initialize_item(PlayerInventory.crafting[i][0], PlayerInventory.crafting[i][1])
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
			# Currently holding an item
			if slot.item and !menus.holding_item:
				_craft_item(slot)

func _craft_item(craftable_slot : SLOT_CLASS):
	var craftable_item : ITEM = craftable_slot.item
	var a : ITEM = craftable_item.duplicate()
	a.item_name = craftable_item.item_name
	a.item_icon_name = craftable_item.item_icon_name
	a.item_quantity = craftable_item.item_quantity
	a.description = craftable_item.description
	a.category = craftable_item.category
	a.attack_mode = craftable_item.attack_mode
	a.shield_cap = craftable_item.shield_cap
	a.current_shield_cap = craftable_item.current_shield_cap
	a.shield_recharge_delay = craftable_item.shield_recharge_delay
	a.shield_recharge_rate = craftable_item.shield_recharge_rate
	a.armor_rating = craftable_item.armor_rating
	
	var menus = find_parent("Menus")
	menus.add_child(a)
	menus.holding_item = a
	menus.holding_item.global_position = get_global_mouse_position()
	return
