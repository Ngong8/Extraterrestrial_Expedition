extends Area2D

var speed : int = 1500
var movement : Vector2
var current_dmg : int = 0
func _ready() -> void:
	set_as_toplevel(true)
	return

func _physics_process(delta: float) -> void:
	movement = Vector2(speed, 0).rotated(rotation)
	global_position += movement * delta
	return

func _on_EnergyPulse_body_entered(body: Node) -> void:
	if body is TileMap:	queue_free()
	elif body.is_in_group("Entities"):
		body._take_damage(current_dmg)
		queue_free()
	return

func _on_DespawnTimer_timeout() -> void:
	queue_free()
	return
