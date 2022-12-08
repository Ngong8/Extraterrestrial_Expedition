extends Control

const SLOT_CLASS = preload("res://Scenes/Slot.gd")
onready var crafting_grids = $CraftGrids
onready var slots = crafting_grids.get_children()
func _ready() -> void:
#	hide()
	for i in range(slots.size()):
		slots[i].connect("gui_input", self, "_slot_gui_input", [slots[i]])
		slots[i].slot_index = i
		slots[i].slot_type = SLOT_CLASS.SLOT_TYPE.CRAFTING
	_initialize_crafting()

	return

func _initialize_crafting() -> void:
	for i in range(slots.size()):
		if PlayerInventory.crafting.has(i):
			slots[i]._initialize_item(PlayerInventory.crafting[i][0], PlayerInventory.crafting[i][1])
	return

func _add_crafting_slots_on_runtime() -> void:
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

func _use_item(slot : SLOT_CLASS, amount_to_use : int = 1) -> void:
	if slot.item.item_quantity > 1:
		PlayerInventory._reduce_item_quantity(slot, amount_to_use)
		slot.item._decrease_item_quantity(amount_to_use)
	else:
		PlayerInventory._remove_item(slot)
		slot.item.queue_free()
		slot.item = null
	return

func _craft_item(craftable_slot : SLOT_CLASS):
	var inventory = find_parent("Player").get_node("%Inventory")
	var craftable_item : ITEM = craftable_slot.item
	for i in craftable_item.recipe:
		for j in PlayerInventory.inventory:
			if PlayerInventory.inventory[j][0] == i:
				PlayerInventory.inventory[j][1] -= craftable_item.recipe[i]
				# Below are for adding new crafted item after clicked.
				PlayerInventory._add_item(craftable_item.item_name, craftable_item.item_quantity)
				if PlayerInventory.inventory[j][1] <= 0:
					PlayerInventory._remove_item(inventory.inventory_slots.get_children()[j])
					inventory.inventory_slots.get_children()[j].item.queue_free()
					inventory.inventory_slots.get_children()[j].item = null
					inventory.inventory_slots.get_children()[j]._refresh_style()
					
	inventory._initialize_inventory()

#			print_debug(str(PlayerInventory.inventory[j][0]) + " " + str(PlayerInventory.inventory[j][1]))
#			print_debug(PlayerInventory.inventory[j][0])
#			print_debug(PlayerInventory.inventory[j][1])
#			print_debug(i + ": " + str(craftable_item.recipe[i]))


	
	# Below are for holding crafted item when clicked.
#	var a : ITEM = craftable_item.duplicate()
#	a.item_name = craftable_item.item_name
#	a.item_icon_name = craftable_item.item_icon_name
#	a.item_quantity = craftable_item.item_quantity
#	a.description = craftable_item.description
#	a.category = craftable_item.category
#	a.attack_mode = craftable_item.attack_mode
#	a.shield_cap = craftable_item.shield_cap
#	a.current_shield_cap = craftable_item.current_shield_cap
#	a.shield_recharge_delay = craftable_item.shield_recharge_delay
#	a.shield_recharge_rate = craftable_item.shield_recharge_rate
#	a.armor_rating = craftable_item.armor_rating
#
#	var menus = find_parent("Menus")
#	menus.add_child(a)
#	menus.holding_item = a
#	menus.holding_item.global_position = get_global_mouse_position()
	return
