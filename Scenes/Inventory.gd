extends Control

const SLOT_CLASS = preload("res://Scenes/Slot.gd")
onready var inventory_slots = $InventoryGrids
onready var equipment_slots = $EquipmentGrids
func _ready() -> void:
	var slots = inventory_slots.get_children()
	for i in range(slots.size()):
		slots[i].connect("gui_input", self, "_slot_gui_input", [slots[i]])
		slots[i].slot_index = i
		slots[i].slot_type = SLOT_CLASS.SLOT_TYPE.INVENTORY
	
	var equip_slots = equipment_slots.get_children()
	for i in range(equip_slots.size()):
		equip_slots[i].connect("gui_input", self, "_slot_gui_input", [equip_slots[i]])
		equip_slots[i].slot_index = i
		equip_slots[i].slot_type = SLOT_CLASS.SLOT_TYPE.SUIT
	_initialize_inventory()
	_initialize_suit()

func _initialize_inventory() -> void:
	var slots = inventory_slots.get_children()
	for i in range(slots.size()):
		if PlayerInventory.inventory.has(i):
#			print_debug(PlayerInventory.inventory[i][0])
			slots[i]._initialize_item(PlayerInventory.inventory[i][0], PlayerInventory.inventory[i][1])
	return

func _initialize_suit() -> void:
	var equip_slots = equipment_slots.get_children()
	for i in range(equip_slots.size()):
		if PlayerInventory.suit.has(i):
#			print_debug(PlayerInventory.inventory[i][0])
			equip_slots[i]._initialize_item(PlayerInventory.suit[i][0], PlayerInventory.suit[i][1])
	return

func _slot_gui_input(event: InputEvent, slot: SLOT_CLASS):
	var menus = find_parent("Menus")
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed:
			# Currently holding an item
			if menus.holding_item != null:
				# Empty slot
				if !slot.item:
					_left_click_empty_slot(slot)
				# Slot already contains an item
				else:
					# Different item, so swap
					if menus.holding_item.item_name != slot.item.item_name:
						_left_click_different_item(event,slot)
					# Same item, so try to merge
					else:
						_left_click_same_item(slot)
			# Not holding an item
			elif slot.item:
				_left_click_not_holding(slot)

func _input(_event: InputEvent) -> void:
	var menus = find_parent("Menus")
	if menus.holding_item:
		menus.holding_item.global_position = get_global_mouse_position()

func _able_to_put_into_slot(slot : SLOT_CLASS):
	var menus = find_parent("Menus")
	if menus.holding_item == null:
		return true
	var holding_item_category = JsonData.item_data[menus.holding_item.item_name]["ItemCategory"]
	if slot.slot_type == SLOT_CLASS.SLOT_TYPE.SUIT:
		return holding_item_category == "Suit"
	return true

func _left_click_empty_slot(slot : SLOT_CLASS) -> void:
	if _able_to_put_into_slot(slot):
		var menus = find_parent("Menus")
		PlayerInventory._add_item_to_empty_slot(menus.holding_item, slot)
		slot._put_into_slot(menus.holding_item)
		menus.holding_item = null
	return

func _left_click_different_item(_event : InputEvent, slot : SLOT_CLASS) -> void:
	if _able_to_put_into_slot(slot):
		var menus = find_parent("Menus")
		PlayerInventory._remove_item(slot)
		PlayerInventory._add_item_to_empty_slot(menus.holding_item, slot)
		var temp_item = slot.item
		slot._pick_from_slot()
		temp_item.global_position = get_global_mouse_position()
		slot._put_into_slot(menus.holding_item)
		menus.holding_item = temp_item
	return

func _left_click_same_item(slot : SLOT_CLASS) -> void:
	if _able_to_put_into_slot(slot):
		var menus = find_parent("Menus")
		var stack_size = int(JsonData.item_data[slot.item.item_name]["StackSize"])
		var able_to_add = stack_size - slot.item.item_quantity
		if able_to_add >= menus.holding_item.item_quantity:
			PlayerInventory._add_item_quantity(slot, menus.holding_item.item_quantity)
			slot.item._increase_item_quantity(menus.holding_item.item_quantity)
			menus.holding_item.queue_free()
			menus.holding_item = null
		else:
			PlayerInventory._add_item_quantity(slot, able_to_add)
			slot.item._increase_item_quantity(able_to_add)
			menus.holding_item._decrease_item_quantity(able_to_add)
	return

func _left_click_not_holding(slot : SLOT_CLASS) -> void:
	var menus = find_parent("Menus")
	PlayerInventory._remove_item(slot)
	menus.holding_item = slot.item
	slot._pick_from_slot()
	menus.holding_item.global_position = get_global_mouse_position()
	return
