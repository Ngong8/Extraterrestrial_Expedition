extends Node2D

onready var in_game_music_player = get_node("InGameMusicPlayer")
const TILE_GEN_0 = preload("res://Scenes/TileGen0.tscn")

func _ready() -> void:
	in_game_music_player.play()
	var tile_gen_0_inst = TILE_GEN_0.instance()
#	add_child(tile_gen_0_inst)
	return


func _on_IntroMusicPlayer_finished() -> void:
	in_game_music_player.play()
	return


func _on_InGameMusicPlayer_finished() -> void:
	in_game_music_player.play()
	return
