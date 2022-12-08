extends Node2D

onready var spawn_mobs_timer = get_node("SpawnMobsTimer")
onready var intro_music_player = get_node("IntroMusicPlayer")
onready var in_game_music_player = get_node("InGameMusicPlayer")
onready var boss_music_player = get_node("BossMusicPlayer")
onready var anim_player = get_node("AnimPlayer")
const TILE_GEN_0 = preload("res://Scenes/TileGen0.tscn")

var call_once : bool = false
func _ready() -> void:
	$LostItem.global_position = Vector2(rand_range(-1500,1500), rand_range(0,1000))
	PlayerInventory.inventory = {}
	PlayerInventory.hotbar = {}
	PlayerInventory.suit = {}
	PlayerInventory.hotbar = {
	0: ["Mining Laser", 1],
	}
	PlayerInventory.suit = {
	0: ["Explorer Suit", 1]
	}
	call_once = false
#	print_debug(world_gen.get_used_cells())
	randomize()
	spawn_mobs_timer.start(rand_range(3,5))
	intro_music_player.play()
#	in_game_music_player.play()
#	var tile_gen_0_inst = TILE_GEN_0.instance()
#	add_child(tile_gen_0_inst)
	return

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("skip"):
		if anim_player.get_current_animation() == "Crashlanding":
			print_debug("Skipped")
			find_node("EscapePod").get_node("AnimPlayer").advance(11.0)
			find_node("EscapePod").global_position.y = -500
			anim_player.advance(20.0)
			
	return

func _on_IntroMusicPlayer_finished() -> void:
	in_game_music_player.play()
	return

func _on_InGameMusicPlayer_finished() -> void:
	in_game_music_player.play()
	return


func _on_AnimPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "FinalBoss":
		intro_music_player.stop()
		in_game_music_player.stop()
		boss_music_player.play()
	return

onready var world_gen = $TileMap
const SLIME = preload("res://Scenes/Slime.tscn")
var spawnpoints : Array = [-1500,1500]
func _on_SpawnMobsTimer_timeout() -> void:
	var player = get_node("Player")
	var slimes = get_tree().get_nodes_in_group("Slimes")
#	print_debug(slimes.size())
	if slimes.size() < 10:
		for i in rand_range(2,3):
			var slime_inst = SLIME.instance()
			spawnpoints.shuffle()
			slime_inst.position = player.position + Vector2(spawnpoints[0]+rand_range(-200,200), spawnpoints[1]+rand_range(-200,200))
			var a : Vector2 = world_gen.world_to_map(slime_inst.position)
			if world_gen.get_cellv(a) == TileMap.INVALID_CELL:	add_child(slime_inst)
		spawn_mobs_timer.start(rand_range(5,12))
	return

const MECH_BOSS = preload("res://Scenes/UglyMech.tscn")
func _on_CallMechBossTimer_timeout() -> void:
#	if !$AnimPlayer.is_playing():
		var player : KinematicBody2D = get_tree().root.get_node("GameWorld").find_node("Player")
		var mech_boss = MECH_BOSS.instance()
		mech_boss.position = player.position + Vector2(500,500)
		add_child(mech_boss)
	


