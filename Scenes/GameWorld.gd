extends Node2D

onready var spawn_mobs_timer = get_node("SpawnMobsTimer")
onready var in_game_music_player = get_node("InGameMusicPlayer")
const TILE_GEN_0 = preload("res://Scenes/TileGen0.tscn")

func _ready() -> void:
#	print_debug(world_gen.get_used_cells())
	randomize()
	spawn_mobs_timer.start(rand_range(3,5))
	in_game_music_player.play()
#	var tile_gen_0_inst = TILE_GEN_0.instance()
#	add_child(tile_gen_0_inst)
	return


func _on_IntroMusicPlayer_finished() -> void:
	in_game_music_player.play()
	return


func _on_InGameMusicPlayer_finished() -> void:
	in_game_music_player.play()
	return

onready var world_gen = $TileMap
const SLIME = preload("res://Scenes/Slime.tscn")
func _on_SpawnMobsTimer_timeout() -> void:
	var player = get_node("Player")
	var slimes = get_tree().get_nodes_in_group("Slimes")
#	print_debug(slimes.size())
	if slimes.size() < 10:
		for i in rand_range(3,5):
			var slime_inst = SLIME.instance()
			slime_inst.global_position.x = rand_range(player.global_position.x - 500, player.global_position.x + 500)
			slime_inst.global_position.y = rand_range(player.global_position.y - 500, player.global_position.y + 500)
			var a : Vector2 = world_gen.world_to_map(slime_inst.global_position)
			if world_gen.get_cellv(a) == TileMap.INVALID_CELL:	add_child(slime_inst)
		spawn_mobs_timer.start(rand_range(3,12))
	return
