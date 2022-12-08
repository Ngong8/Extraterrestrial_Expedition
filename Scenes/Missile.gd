extends Area2D

# Movement variables
export var move_speed : int = 450
export var steer_force : int = 120
var steer : Vector2
var acceleration : Vector2
var current_move_speed : int
var velocity : Vector2
# Missle's stats
var hp : int = 25;	var current_hp : int

onready var explosion_particles = $ExplosionParticles
func _ready() -> void:
	$LaunchingSFX.play()
	explosion_particles.one_shot = true
	explosion_particles.emitting = false
	current_move_speed = move_speed
	current_hp = hp
	return

func _physics_process(delta: float) -> void:
	var player : KinematicBody2D = get_tree().root.get_node("GameWorld").find_node("Player")
	var desired = (player.global_position - global_position).normalized() * current_move_speed
	steer = (desired - velocity).normalized() * steer_force
	acceleration += steer
	velocity += acceleration * delta
	velocity = velocity.clamped(current_move_speed)
	rotation = velocity.angle()
	global_position += velocity * delta
	return

func _take_damage(damage : int = 0):
	if damage > 0:
		if current_hp > 0:
			current_hp -= damage
			$AnimPlayer.play("Damaged")
		if current_hp <= 0:
			current_hp = 0
			_explode()
			return

func _explode() -> void:
	explosion_particles.emitting = true
	$Col.set_deferred("disabled", true)
	$Graphic.hide()
	$ExplosionSFX.play()
	if $ExplosionTimer.is_stopped():
		$ExplosionTimer.start()
	set_physics_process(false)
	yield($ExplosionTimer, "timeout")
	queue_free()
	return

func _on_ExplosionTimer_timeout() -> void:
	return

func _on_Missile_body_entered(body: Node) -> void:
	if body.name == "Player":
		body._take_damage(25, global_position, 2.5)
		_explode()
	return

func _on_DespawnTimer_timeout() -> void:
	_explode()
	return
