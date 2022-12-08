extends Area2D

var speed : int = 1500
var movement : Vector2
var current_dmg : int = 0
var penetrate_timing : int = 0
func _ready() -> void:
	set_as_toplevel(true)
	return

func _physics_process(delta: float) -> void:
	movement = Vector2(speed, 0).rotated(rotation)
	global_position += movement * delta
	penetrate_timing += 1
	return

func _on_EnergyPulse_body_entered(body: Node) -> void:
	if body is TileMap:	queue_free()
	elif body.is_in_group("Entities"):
		body._take_damage(current_dmg)
		queue_free()
	return

func _on_EnergyPulse_area_entered(area: Area2D) -> void:
	if area.is_in_group("Entities"):
		area.get_parent()._take_damage(current_dmg)
		if penetrate_timing > 5: queue_free()
	elif area.is_in_group("Blockers"):
		area.get_parent()._take_damage(current_dmg, true)
		if penetrate_timing > 5: queue_free()
	elif area.is_in_group("Missiles"):
		area._take_damage(current_dmg)
		if penetrate_timing > 5: queue_free()
	return

func _on_DespawnTimer_timeout() -> void:
	queue_free()
	return



