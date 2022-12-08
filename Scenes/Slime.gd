extends KinematicBody2D

var direction : Vector2; var velocity: Vector2
export var move_speed : int = 500;	export var acceleration : int = 1000
export var jump_force : int = 600;	export var gravity : int = 1500
var hp : int = 50;	var current_hp : int
var atk_damage : int = 5
func _ready() -> void:
	randomize()
	current_hp = hp
	return

onready var anim_graphic = $AnimGraphic
onready var jump_timer = $JumpTimer
func _physics_process(delta: float) -> void:
#	# Jump related coding:
#	if is_on_floor():
#		velocity.y = -jump_force
	if $StoppingTimer.is_stopped():	velocity.x = move_toward(velocity.x, 0.0, acceleration*delta)
	if is_on_floor():
		if anim_graphic.animation != "jump_ready":	anim_graphic.set_animation("idle")
		if jump_timer.is_stopped():
			jump_timer.start(rand_range(1.0,1.8))
	else:
		jump_timer.stop()
		anim_graphic.animation = "on_air"
		velocity.y += gravity * delta
		if $LeftRay.is_colliding():	velocity.x += 64
		elif $RightRay.is_colliding():	velocity.x -= 64
	
	velocity = move_and_slide(velocity, Vector2.UP)
	# Damages the player inside its hitbox, continuously, whenever player's invincibility time is over
	var bodies = $Hitbox.get_overlapping_bodies()
	for b in bodies:
		if b.name == "Player":
			b._take_damage(atk_damage, global_position)
	
	var player : KinematicBody2D = get_tree().root.get_node("GameWorld").find_node("Player")
	if global_position.distance_squared_to(player.global_position) > 2500*2500:
		queue_free()
	return


func _on_JumpTimer_timeout() -> void:
	anim_graphic.set_animation("jump_ready")
	return

func _on_AnimGraphic_animation_finished() -> void:
	var player : KinematicBody2D = get_tree().root.get_node("GameWorld").find_node("Player")
	if anim_graphic.animation == "jump_ready":
		var dir_to_player : float = player.global_position.x - global_position.x
		if dir_to_player > 0:
			if dir_to_player > 500:
				velocity.x = move_speed
			else:
				velocity.x = dir_to_player
		else:
			if dir_to_player < -500:
				velocity.x = -move_speed
			else:
				velocity.x = dir_to_player
		if is_on_floor():
#			velocity.x = (player.global_position.x - global_position.x)
			velocity.y = -jump_force
		$StoppingTimer.start(0.5)
	return

func _take_damage(damage : int = 0):
	if damage > 0:
		current_hp -= damage
		get_node("AnimPlayer").play("Hurt")
		if current_hp <= 0:
			queue_free()
	return


func _on_Hitbox_body_entered(body: Node) -> void:
#	if body.name == "Player":
#		body._take_damage(atk_damage)
	return


