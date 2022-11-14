extends Node2D


onready var _tool_graphic = get_node("%ToolGraphic")
onready var _atk_area = get_node("%AtkArea")
onready var _atk_cast = get_node("%AtkCast")
onready var _atk_line = get_node("%AtkLine")
onready var _atk_indicator = get_node("AtkArea/Indicator")
onready var beam_effect = get_node("BeamEffect")
export(float) var swing_time = 0.25
onready var _swing_timer = get_node("SwingTimer")
func _ready() -> void:
	beam_effect.hide()
	randomize()
	return


func _physics_process(delta: float) -> void:
	look_at(get_global_mouse_position())
	_atk_indicator.self_modulate.a = range_lerp(global_position.distance_to(get_global_mouse_position()), 0, 500, 0.75, 0.25)
	
	if global_position.distance_to(get_global_mouse_position()) <= 150:
		_atk_area.global_position = get_global_mouse_position()
		_atk_line.points = [_atk_line.position, lerp(_atk_line.position, get_local_mouse_position() + Vector2(rand_range(-25,25),rand_range(-25,25)), rand_range(0.25,0.75)), get_local_mouse_position()]
		beam_effect.global_position = get_global_mouse_position()
	else:
		_atk_area.position = _atk_cast.cast_to
		_atk_line.points = [_atk_line.position, lerp(_atk_line.position, _atk_cast.cast_to + Vector2(rand_range(-25,25),rand_range(-25,25)), rand_range(0.25,0.75)), _atk_cast.cast_to]
		beam_effect.position = _atk_cast.cast_to
	
	if Input.is_action_pressed("attack"):
		beam_effect.show()
		if _swing_timer.is_stopped():	_swing_timer.start(swing_time)
		_atk_line.show()
	else:
		beam_effect.hide()
		_swing_timer.stop()
		_atk_line.hide()
	
#	if get_global_mouse_position().distance_to(global_position) <= 500:
#		_atk_cast.cast_to = to_local(get_global_mouse_position())
#		_atk_line.points = [_atk_line.position, _atk_cast.cast_to]
#	if Input.is_action_just_pressed("attack"):
#		if _atk_cast.is_colliding():
#			if _atk_cast.get_collider() is TileMap:
#				_hit_block(_atk_cast.get_collider(), _atk_cast.get_collision_point())
#		pass
	return

const DROP_LOOT = preload("res://Scenes/DropLoot.tscn")
export var dict_tiles : Dictionary = {"grass0":"grass0", "grass1":"grass1", "grass2":"grass2"}
func _hit_block(tilemap : TileMap = null, col_point : Vector2 = Vector2()) -> void:
	var tile : Vector2 = tilemap.world_to_map(col_point)
	var tileset = tilemap.tile_set
	var id = tilemap.get_cell(int(tile.x),int(tile.y))
	var cell_name : String = tileset.tile_get_name(id) if id != -1 else ""

#	if (id != -1 and id < 5): #  we've hit a block (any full durability tile inside that array)
	if id != -1: #  we've hit a block (any full durability tile inside that array)
		if (cell_name.begins_with("dirt") or cell_name.begins_with("grass")) and cell_name.ends_with("_4"): # last block stage so delete
			tilemap.set_cell(int(tile.x),int(tile.y),-1) # -1 is nothing
			_spawn_loot(tilemap, tile.x, tile.y)
		elif cell_name.begins_with("stone") and cell_name.ends_with("_6"): # last block stage so delete
			tilemap.set_cell(int(tile.x),int(tile.y),-1) # -1 is nothing
			_spawn_loot(tilemap, tile.x, tile.y, "stone")
		elif cell_name.begins_with("milkore") and cell_name.ends_with("_7"): # last block stage so delete
			tilemap.set_cell(int(tile.x),int(tile.y),-1) # -1 is nothing
			_spawn_loot(tilemap, tile.x, tile.y, "milkore")
		else:
			tilemap.set_cell(int(tile.x),int(tile.y) ,id+1)
#	else:
#		tilemap.set_cell(int(tile.x),int(tile.y),0) # This is testing only!
		
	return

func _spawn_loot(tilemap : TileMap, tile_x : int, tile_y : int, item : String = "dirt") -> void:
	var drop_loot_inst = DROP_LOOT.instance()
	var pos : Vector2 = tilemap.map_to_world(Vector2(tile_x, tile_y))
	pos = tilemap.to_global(pos)
	drop_loot_inst.global_position = pos
	if item == "" or item == "dirt": drop_loot_inst.get_node("Graphic").texture.set("region", Rect2(0,0, 32,32))
	elif item == "stone": drop_loot_inst.get_node("Graphic").texture.set("region", Rect2(32,0,32,32))
	elif item == "milkore": drop_loot_inst.get_node("Graphic").texture.set("region", Rect2(64,0,32,32))
	
	
	
	get_tree().root.get_node("GameWorld").add_child(drop_loot_inst)
	return

func _on_SwingTimer_timeout() -> void:
#	print_debug(swing_time)
	var bodies = $AtkArea.get_overlapping_bodies()
	for i in bodies:
		_hit_block(i, $AtkArea.global_position)
