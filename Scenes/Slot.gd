extends Panel

const DEFAULT_TEX = preload("res://Assets/ItemSlot.stylebox")
const VACANT_TEX = preload("res://Assets/ItemSlotVacant.stylebox")
var SELECTED_TEX = preload("res://Assets/ItemSlotSelected.stylebox")

var default_style : StyleBoxFlat = null
var vacant_style : StyleBoxFlat = null
var selected_style : StyleBoxFlat = null

const ITEM_CLASS = preload("res://Scenes/Item.tscn")
var item : Node2D = null
var slot_index : int

var slot_type
enum SLOT_TYPE {
	HOTBAR, INVENTORY, SUIT, CRAFTING
}

const TOOLTIP_THEME = preload("res://Assets/TooltipHint.theme")
func _ready() -> void:
	theme = TOOLTIP_THEME
	default_style = StyleBoxFlat.new()
	vacant_style = StyleBoxFlat.new()
	selected_style = StyleBoxFlat.new()
	default_style = DEFAULT_TEX
	vacant_style = VACANT_TEX
	selected_style = SELECTED_TEX
	_refresh_style()
	return

func _refresh_style() -> void:
	if slot_type == SLOT_TYPE.HOTBAR and PlayerInventory.active_item_slot == slot_index:
		hint_tooltip = ""
		set("custom_styles/panel", selected_style)
	elif slot_type == SLOT_TYPE.CRAFTING:
		hint_tooltip = ""
		set("custom_styles/panel", default_style)
		var item_node = get_node_or_null(get_children()[-1].name)
		var recipe_text : String = ""
		for i in item_node.recipe.keys():
			var j = item_node.recipe[i]
			recipe_text += i + ": " + str(j) + "\n"
#		print_debug(recipe_text)
		hint_tooltip = item_node.item_name + "\n" + item_node.description + "\n\n" + str(recipe_text)
		return
	elif item == null:
		hint_tooltip = ""
		set("custom_styles/panel", vacant_style)
	else:
		hint_tooltip = ""
		set("custom_styles/panel", default_style)
		var item_node = get_node_or_null(get_children()[-1].name)
		hint_tooltip = item_node.item_name + "\n" + item_node.description
	
	if slot_type == SLOT_TYPE.SUIT:
		if item:
			var suit_item = get_node_or_null(get_children()[-1].name)
#			var durability = JsonData.item_data[suit_item.item_name]["ItemDurability"]
#			var armor_rating = JsonData.item_data[suit_item.item_name]["ItemDefense"]
#			var shield_capacity = JsonData.item_data[suit_item.item_name]["ItemShield"]
#			var shield_recharge_rate = JsonData.item_data[suit_item.item_name]["ItemShieldRechargeRate"]
#			var shield_recharge_delay = JsonData.item_data[suit_item.item_name]["ItemShieldRechargeDelay"]
#			find_parent("Player")._refresh_equipped_armor(durability, armor_rating, shield_capacity, shield_recharge_rate, shield_recharge_delay)
			find_parent("Player")._refresh_equipped_armor(suit_item)
		else:
			find_parent("Player")._refresh_equipped_armor()
	return

func _pick_from_slot() -> void:
#	print_debug("Picked up!")
	remove_child(item)
	var menus = find_parent("Menus")
	menus.add_child(item)
	item = null
	_refresh_style()
	return

func _put_into_slot(new_item : Node2D) -> void:
#	print_debug("Put in!")
	item = new_item
	item.position = Vector2(8,8)
	var menus = find_parent("Menus")
	menus.remove_child(item)
	add_child(item)
	_refresh_style()
	return

func _initialize_item(item_name : String, item_quantity : int) -> void:
#	print_debug(item_name)
	if item == null:
		item = ITEM_CLASS.instance()
		item.position = Vector2(8,8)
		add_child(item)
		item._set_item(item_name, item_quantity)
	else:
		item._set_item(item_name, item_quantity)
	_refresh_style()
	return
