extends CanvasLayer

var holding_item : ITEM = null
onready var inventory_node = get_node("%Inventory")
var dirt_item : int = 0;	var stone_item : int = 0;	var milkore_item : int = 0
func _ready() -> void:
	inventory_node.hide()
	return

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("game_menu") and find_parent("Player").can_move:
		inventory_node.visible = !inventory_node.visible
		inventory_node._initialize_inventory()
		
	if event.is_action_pressed("scroll_up"):
		PlayerInventory._active_item_scroll_up()
	elif event.is_action_pressed("scroll_down"):
		PlayerInventory._active_item_scroll_down()
	return

var a
func _on_RestartBtn_pressed() -> void:
	a = get_tree().reload_current_scene()
	return

func _on_QuitBtn_pressed() -> void:
	get_tree().quit()
	return
