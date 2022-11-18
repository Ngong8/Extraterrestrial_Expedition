extends Control

const SLOT_CLASS = preload("res://Scenes/Slot.gd")
onready var hotbar_slots = $HotbarGrids
onready var active_item_label = $ActiveItemLbl
onready var slots = hotbar_slots.get_children()
func _ready() -> void:
	PlayerInventory.connect("active_item_updated", self, "_update_active_item_label")
	for i in range(slots.size()):
		slots[i].connect("gui_input", self, "_slot_gui_input", [slots[i]])
		PlayerInventory.connect("active_item_updated", slots[i], "_refresh_style")
		slots[i].slot_index = i
		slots[i].slot_type = SLOT_CLASS.SLOT_TYPE.HOTBAR
	_initialize_hotbar()
	_update_active_item_label()
	return

func _update_active_item_label() -> void:
	var item : ITEM = slots[PlayerInventory.active_item_slot].item
	if item != null:
		active_item_label.text = item.item_name
		find_parent("Player").get_node("%ToolGraphic").texture = load("res://Assets/items/" + item.item_icon_name + "_item.png")
	else:
		find_parent("Player").get_node("%ToolGraphic").texture = null
		active_item_label.text = ""
	return

func _initialize_hotbar() -> void:
	for i in range(slots.size()):
		if PlayerInventory.hotbar.has(i):
			slots[i]._initialize_item(PlayerInventory.hotbar[i][0], PlayerInventory.hotbar[i][1])
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
			_update_active_item_label()

func _input(event: InputEvent) -> void:
	var menus = find_parent("Menus")
	if menus.holding_item:
		menus.holding_item.global_position = get_global_mouse_position()

func _left_click_empty_slot(slot : SLOT_CLASS) -> void:
	var menus = find_parent("Menus")
	PlayerInventory._add_item_to_empty_slot(menus.holding_item, slot)
	slot._put_into_slot(menus.holding_item)
	menus.holding_item = null
	return

func _left_click_different_item(event : InputEvent, slot : SLOT_CLASS) -> void:
	var menus = find_parent("Menus")
	PlayerInventory._remove_item(slot)
	PlayerInventory._add_item_to_empty_slot(menus.holding_item, slot)
	var temp_item = slot.item
	slot._pick_from_slot()
	temp_item.global_position = event.global_position
	slot._put_into_slot(menus.holding_item)
	menus.holding_item = temp_item
	return

func _left_click_same_item(slot : SLOT_CLASS) -> void:
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

func _use_item(slot : SLOT_CLASS, amount_to_use : int = 1) -> void:
	if slot.item.item_quantity > 1:
		PlayerInventory._reduce_item_quantity(slot, amount_to_use)
		slot.item._decrease_item_quantity(amount_to_use)
	else:
		slot.item.queue_free()
		slot.item = null
		_update_active_item_label()
	return
