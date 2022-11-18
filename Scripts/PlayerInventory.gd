extends Node

signal active_item_updated
const SLOT_CLASS = preload("res://Scenes/Slot.gd")
const ITEM_CLASS = preload("res://Scenes/Item.gd")
const NUM_INVENTORY_SLOTS : int = 24
const NUM_HOTBAR_SLOTS : int = 8
var inventory : Dictionary = {
	0: ["Dirt", 80],
	1: ["Stone", 16],
	2: ["Milkore", 34],
}
var hotbar : Dictionary = {
	0: ["Dirt", 20]
}
var suit : Dictionary = {
	
}
var active_item_slot : int = 0

func _add_item(item_name : String, item_quantity : int) -> void:
	for item in inventory:
		if inventory[item][0] == item_name:
			var stack_size = int(JsonData.item_data[item_name]["StackSize"])
			var able_to_add = stack_size - inventory[item][1]
			if able_to_add >= item_quantity:
				inventory[item][1] += item_quantity
				return
			else:
				inventory[item][1] += able_to_add
				item_quantity = item_quantity - able_to_add
			
	# item doesn't exist in inventory yet, so add it to an empty slot
	for i in range(NUM_INVENTORY_SLOTS):
		if inventory.has(i) == false:
			inventory[i] = [item_name, item_quantity]
			return

func _add_item_to_empty_slot(item : ITEM_CLASS, slot : SLOT_CLASS) -> void:
	if slot.slot_type == SLOT_CLASS.SLOT_TYPE.HOTBAR:
		hotbar[slot.slot_index] = [item.item_name, item.item_quantity]
	elif slot.slot_type == SLOT_CLASS.SLOT_TYPE.INVENTORY:
		inventory[slot.slot_index] = [item.item_name, item.item_quantity]
	else:
		suit[slot.slot_index] = [item.item_name, item.item_quantity]
	return

func _add_item_quantity(slot : SLOT_CLASS, quantity_to_add : int) -> void:
	if slot.slot_type == SLOT_CLASS.SLOT_TYPE.HOTBAR:
		hotbar[slot.slot_index][1] += quantity_to_add
	elif slot.slot_type == SLOT_CLASS.SLOT_TYPE.INVENTORY:
		inventory[slot.slot_index][1] += quantity_to_add
	else:
		suit[slot.slot_index][1] += quantity_to_add
	return

func _reduce_item_quantity(slot : SLOT_CLASS, quantity_to_reduce : int) -> void:
	if slot.slot_type == SLOT_CLASS.SLOT_TYPE.HOTBAR:
		hotbar[slot.slot_index][1] -= quantity_to_reduce
	elif slot.slot_type == SLOT_CLASS.SLOT_TYPE.INVENTORY:
		inventory[slot.slot_index][1] -= quantity_to_reduce
	else:
		suit[slot.slot_index][1] -= quantity_to_reduce
	return

func _remove_item(slot : SLOT_CLASS) -> void:
	if slot.slot_type == SLOT_CLASS.SLOT_TYPE.HOTBAR:
		hotbar.erase(slot.slot_index)
	elif slot.slot_type == SLOT_CLASS.SLOT_TYPE.INVENTORY:
		inventory.erase(slot.slot_index)
	else:
		suit.erase(slot.slot_index)
	return

func _active_item_scroll_up() -> void:
	if active_item_slot == 0:
		active_item_slot = NUM_HOTBAR_SLOTS - 1
	else:
		active_item_slot -= 1
	emit_signal("active_item_updated")
	return

func _active_item_scroll_down() -> void:
	active_item_slot = (active_item_slot + 1) % NUM_HOTBAR_SLOTS
	emit_signal("active_item_updated")
	return

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		for i in range(1,9):
			if event.is_action_pressed(str(i)):
				active_item_slot = i - 1
				emit_signal("active_item_updated")
	return

