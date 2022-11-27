extends Node2D

onready var head_graphic = get_parent().get_node("HeadGraphic")
onready var helmet_torso_graphic = get_parent().get_node("HelmetTorsoGraphic")
onready var legs_graphic = get_parent().get_node("LegsGraphic")
onready var hands = $Hands
onready var hand_graphic = get_node("%HandGraphic")
onready var _tool_graphic = get_node("%ToolGraphic")
onready var _atk_area = get_node("%AtkArea")
onready var _atk_cast = get_node("%AtkCast")
onready var _atk_line = get_node("%AtkLine")
onready var _atk_indicator = get_node("%Indicator")
onready var atk_area = get_node("%AtkArea")
onready var beam_effect = get_node("%BeamEffect")
var swing_time = 0.25;	var atk_delay_time = 0.10
onready var _swing_timer = get_node("SwingTimer")
onready var _atk_delta_timer = get_node("AtkDelayTimer")
func _ready() -> void:
	beam_effect.hide()
	_atk_line.hide()
	randomize()
	return

var atk_range : int;	var can_fire : bool = true
var is_attack_mode : bool = true
func _physics_process(_delta: float) -> void:
	hands.look_at(get_global_mouse_position())
#	look_at(get_global_mouse_position())
	_atk_indicator.self_modulate.a = range_lerp(global_position.distance_to(get_global_mouse_position()), 0, 500, 0.75, 0.5)
	
	var hotbar = find_parent("Player").get_node("%Hotbar")
	var hotbar_item : ITEM = hotbar.slots[PlayerInventory.active_item_slot].item
	if hotbar_item:
		hand_graphic.frame = 1
		# Will flip weapon's graphic when turn into opposite direction (left or right)
		var weapon_dir = sign(get_global_mouse_position().x - global_position.x)
		if weapon_dir < 0:
			hand_graphic.position.x = -1
			_tool_graphic.set_flip_v(true)
			hand_graphic.set_flip_h(false);	hand_graphic.position.x = -1
			head_graphic.set_flip_h(false);	head_graphic.position.x = -1
			helmet_torso_graphic.set_flip_h(false);	helmet_torso_graphic.position.x = 0
			legs_graphic.set_flip_h(false); legs_graphic.position.x = 0
		elif weapon_dir >= 0:
			hand_graphic.position.x = 1
			_tool_graphic.set_flip_v(false)
			hand_graphic.set_flip_h(true);	hand_graphic.position.x = 0
			head_graphic.set_flip_h(true);	head_graphic.position.x = 0
			helmet_torso_graphic.set_flip_h(true);	helmet_torso_graphic.position.x = -1
			legs_graphic.set_flip_h(true); legs_graphic.position.x = -1
		# Here for adjusting the stats based on the thing the player holding
		if hotbar_item.category == "Tool":
			_tool_graphic.hframes = 1
			atk_range = JsonData.item_data[hotbar_item.item_name]["ItemAttackRange"]
			_atk_cast.cast_to.x = atk_range
			swing_time = JsonData.item_data[hotbar_item.item_name]["ItemAttackSpeed"]
		elif hotbar_item.category == "Weapon":
			is_attack_mode = hotbar_item.attack_mode
			_tool_graphic.hframes = 2
			# Discarded, because afraid of not enough time to do.
#			if !is_attack_mode:
#				_tool_graphic.frame = 1
#				find_parent("Player").get_node("%WeaponModeLbl").text = "Mode: Stun [F]"
#			else:
#				_tool_graphic.frame = 0
#				find_parent("Player").get_node("%WeaponModeLbl").text = "Mode: Attack [F]"
#			print_debug(hotbar_item.item_name + "Attack Mode: " + str(is_attack_mode))
			atk_range = JsonData.item_data[hotbar_item.item_name]["ItemAttackRange"]
			_atk_cast.cast_to.x = atk_range
			atk_delay_time = JsonData.item_data[hotbar_item.item_name]["ItemAttackSpeed"]
		else:
			_tool_graphic.hframes = 1
			atk_range = 150
			_atk_cast.cast_to.x = 150
		# Here for interaction/action took by the player
		if hotbar_item.category == "Tool":
			if Input.is_action_pressed("attack_place"):
				beam_effect.show()
				if _swing_timer.is_stopped():	_swing_timer.start(swing_time)
				_atk_line.show()
			else:
				beam_effect.hide()
				_swing_timer.stop()
				_atk_line.hide()
		elif hotbar_item.category == "Block":
			beam_effect.hide()
			_atk_line.hide()
			if Input.is_action_pressed("attack_place"):
				if _swing_timer.is_stopped():	_swing_timer.start(0.01)
			else:	_swing_timer.stop()
		elif hotbar_item.category == "Weapon":
			beam_effect.hide()
			_atk_line.hide()
			if Input.is_action_pressed("attack_place") and can_fire:
				_ranged_attack()
#			if Input.is_action_just_pressed("switch_mode"):
#				hotbar_item.attack_mode = !hotbar_item.attack_mode
	else:
		# Will flip weapon's graphic when turn into opposite direction (left or right)
		var face_dir = sign(get_global_mouse_position().x - global_position.x)
		if face_dir < 0:
			_tool_graphic.set_flip_v(true)
			hand_graphic.set_flip_h(false);	hand_graphic.position.x = 0
			head_graphic.set_flip_h(false);	head_graphic.position.x = -1
			helmet_torso_graphic.set_flip_h(false);	helmet_torso_graphic.position.x = 0
			legs_graphic.set_flip_h(false); legs_graphic.position.x = 0
		elif face_dir >= 0:
			_tool_graphic.set_flip_v(false)
			hand_graphic.set_flip_h(true);	hand_graphic.position.x = -1
			head_graphic.set_flip_h(true);	head_graphic.position.x = 0
			helmet_torso_graphic.set_flip_h(true);	helmet_torso_graphic.position.x = -1
			legs_graphic.set_flip_h(true); legs_graphic.position.x = -1

		
		_tool_graphic.hframes = 1
		hand_graphic.frame = 0
#		hand_graphic.position.x = 0
		beam_effect.hide()
		_swing_timer.stop()
		_atk_line.hide()
		atk_range = 150
		_atk_cast.cast_to.x = 150
	
	# Managing facing direction when aiming - LEFT, RIGHT, UP or DOWN
	var anglePerDir = TAU/8
	var angleToMouse = get_local_mouse_position().angle()
	angleToMouse = stepify(angleToMouse, anglePerDir)
	angleToMouse = fposmod(angleToMouse, TAU)
	var spriteIndex = int(round(angleToMouse / anglePerDir))
	if spriteIndex == 0 or spriteIndex == 4:	head_graphic.frame = 0
	elif spriteIndex >= 5:	head_graphic.frame = 1
	elif spriteIndex >= 1 and spriteIndex < 4:	head_graphic.frame = 2

	if hands.global_position.distance_squared_to(get_global_mouse_position()) <= atk_range * atk_range:
		_atk_area.global_position = get_global_mouse_position()
		_atk_line.points = [_tool_graphic.position, lerp(_atk_line.position, _atk_area.position + Vector2(rand_range(-25,25),rand_range(-25,25)), rand_range(0.25,0.75)), _atk_area.position]
#		beam_effect.global_position = get_global_mouse_position()
	else:
		_atk_area.position = _atk_cast.cast_to
		_atk_line.points = [_tool_graphic.position, lerp(_atk_line.position, _atk_cast.cast_to + Vector2(rand_range(-25,25),rand_range(-25,25)), rand_range(0.25,0.75)), _atk_cast.cast_to]
#		beam_effect.position = _atk_cast.cast_to


	
#	if get_global_mouse_position().distance_to(global_position) <= 500:
#		_atk_cast.cast_to = to_local(get_global_mouse_position())
#		_atk_line.points = [_atk_line.position, _atk_cast.cast_to]
#	if Input.is_action_just_pressed("attack"):
#		if _atk_cast.is_colliding():
#			if _atk_cast.get_collider() is TileMap:
#				_hit_block(_atk_cast.get_collider(), _atk_cast.get_collision_point())
#		pass
	return

func _place_block(tilemap : TileMap = null, col_point : Vector2 = Vector2(), block_name : String = "") -> void:
	var hotbar = find_parent("Player").get_node("%Hotbar")
#	var hotbar_item : ITEM = hotbar.slots[PlayerInventory.active_item_slot].item
	
	var tile : Vector2 = tilemap.world_to_map(col_point)
	var tileset = tilemap.tile_set
	var id = tilemap.get_cell(int(tile.x),int(tile.y))
	var cell_name : String = tileset.tile_get_name(id) if id != -1 else ""
	var block_id = tileset.find_tile_by_name(block_name)
	if id == -1:
		hotbar._use_item(hotbar.slots[PlayerInventory.active_item_slot])
		tilemap.set_cell(int(tile.x),int(tile.y),block_id) # Place a block when adjacent to a block
	return

const DROP_LOOT = preload("res://Scenes/DropLoot.tscn")
func _hit_block(tilemap : TileMap = null, col_point : Vector2 = Vector2()) -> void:
	var tile : Vector2 = tilemap.world_to_map(col_point)
	var tileset = tilemap.tile_set
	var id = tilemap.get_cell(int(tile.x),int(tile.y))
	var cell_name : String = tileset.tile_get_name(id) if id != -1 else ""

#	if (id != -1 and id < 5): #  we've hit a block
	if id != -1: #  we've hit a block (any full durability tile)
		if (cell_name.begins_with("dirt") or cell_name.begins_with("grass")) and cell_name.ends_with("_4"): # last block stage so delete
			tilemap.set_cell(int(tile.x),int(tile.y),-1) # -1 is nothing
			_spawn_loot(tilemap, tile.x, tile.y)
		elif (cell_name.begins_with("dark dirt") or cell_name.begins_with("cyangrass")) and cell_name.ends_with("_4"):
			tilemap.set_cell(int(tile.x),int(tile.y),-1) # -1 is nothing
			_spawn_loot(tilemap, tile.x, tile.y, "dark_dirt")
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
	if item == "" or item == "dirt":
		drop_loot_inst.item_name = "Dirt"
	elif item == "dark_dirt":
		drop_loot_inst.item_name = "Dark Dirt"
	elif item == "stone":
		drop_loot_inst.item_name = "Stone"
	elif item == "milkore":
		drop_loot_inst.item_name = "Milkore"
#	drop_loot_inst.get_node("Graphic").texture.set("region", Rect2(64,0,32,32))
	
	get_tree().root.get_node("GameWorld").add_child(drop_loot_inst)
	return

func _melee_attack(target : Node, dmg : int = 0) -> void:
	var bodies = atk_area.get_overlapping_bodies()
	for i in bodies:
		if i == target:
			target._take_damage(dmg)
	return

const ENERGY_PULSE = preload("res://Scenes/EnergyPulse.tscn")
var spread : float = 5.0;	var current_spread : float
func _ranged_attack() -> void:
	# Start the attack delay and apply the essential values such as attack damage
	can_fire = false
	_atk_delta_timer.start(atk_delay_time)
	var hotbar = find_parent("Player").get_node("%Hotbar")
	var hotbar_item : ITEM = hotbar.slots[PlayerInventory.active_item_slot].item
	var damage : int = JsonData.item_data[hotbar_item.item_name]["ItemAttackDMG"]
	var bullets : int = JsonData.item_data[hotbar_item.item_name]["Bullets"]
	spread = JsonData.item_data[hotbar_item.item_name]["Spread"]
	# Spawn a projectile
	for i in range(bullets):
		current_spread = rand_range(-spread,spread)
		var energy_pulse_inst = ENERGY_PULSE.instance()
		energy_pulse_inst.rotation_degrees += hands.rotation_degrees + i + current_spread
		energy_pulse_inst.global_position = _tool_graphic.global_position
		energy_pulse_inst.current_dmg = damage
		get_tree().root.get_node("GameWorld").add_child(energy_pulse_inst)
	return

func _on_SwingTimer_timeout() -> void:
#	print_debug(swing_time)
	var hotbar = find_parent("Player").get_node("%Hotbar")
	var hotbar_item : ITEM = hotbar.slots[PlayerInventory.active_item_slot].item
	var block_name : String;	var damage : int
	if hotbar_item:
		if hotbar_item.category == "Block":	block_name = hotbar_item.item_icon_name
		if hotbar_item.category == "Tool" or hotbar_item.category == "Weapon":
			damage = JsonData.item_data[hotbar_item.item_name]["ItemAttackDMG"]
#	if hotbar_item.category == "Weapon":
#		_ranged_attack(damage)
#		return
	
	var bodies = atk_area.get_overlapping_bodies()
	for i in bodies:
		if hotbar_item.category == "Tool":
			if i is TileMap:	_hit_block(i, atk_area.global_position)
			if i.is_in_group("Entities"):	_melee_attack(i, damage)
		elif hotbar_item.category == "Block":
			print_debug(block_name)
			_place_block(i, atk_area.global_position, block_name)

func _on_AtkDelayTimer_timeout() -> void:
	can_fire = true
	return
