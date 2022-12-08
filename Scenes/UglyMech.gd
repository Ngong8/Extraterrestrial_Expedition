extends KinematicBody2D

var state
enum{
	FLYING, CHARGE, DESTROYING, DESTROYED, FINISHED
}
# Movement variables
export var move_speed : int = 2000
export var acceleration : int = 2500
export var deacceleration : int = 4000
export var gravity : int = 2000
var current_move_speed : int
var direction : Vector2; var velocity: Vector2
# Enemy's stats
var hp : int = 3000;	var current_hp : int
var shield_capacity : int = 10000
var shield_recharge_delay : float = 5.5;	var shield_recharge_rate : float = 5.0
var current_shield_cap : int = 0
var shield_recharge_gap : int = 30;	var current_recharge_gap : int = 0
onready var health_bar = get_node("%HealthBar")
onready var shield_cap_bar = get_node("%ShieldCapBar")
var attack_gap : int = 50;	var current_attack_gap : int = 0


var charge_point : Vector2
func _ready() -> void:
	$AnimGraphic.play("flying")
	state = FLYING
	current_move_speed = move_speed
	current_hp = hp
	current_shield_cap = shield_capacity
	return

func _physics_process(delta: float) -> void:
	var player : KinematicBody2D = get_tree().root.get_node("GameWorld").find_node("Player")
	if state == FLYING:
		velocity = velocity.move_toward(Vector2() * current_move_speed, deacceleration * delta)
		if current_attack_gap < attack_gap:	current_attack_gap += 1
		else:
			_launch_missile()
			current_attack_gap = 0
		
	elif state == CHARGE:
		if global_position.distance_squared_to(charge_point) > 50 * 50:
			velocity = velocity.move_toward((charge_point - global_position).normalized() * current_move_speed, acceleration * delta)
		else:
			$ChangePathTimer.start(rand_range(4.5,5.5))
			state = FLYING
	elif state == DESTROYING:
		velocity = velocity.move_toward(Vector2() * current_move_speed, deacceleration * delta)
	elif state == DESTROYED:
		state = FINISHED
	elif state == FINISHED:
		velocity = velocity.move_toward(Vector2() * current_move_speed, deacceleration * delta)
#		collision_layer = 0
#		collision_mask = 0
		
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if $RechargeDelayTimer.is_stopped() and $InvincibilityTimer.is_stopped() and current_shield_cap < shield_capacity and state != DESTROYING and state != DESTROYED and state != FINISHED:
		if current_recharge_gap < shield_recharge_gap:	current_recharge_gap += 1
		else:
			current_shield_cap += shield_recharge_rate
			current_recharge_gap = 0
	elif current_shield_cap >= shield_capacity:
			current_shield_cap = shield_capacity
	health_bar.max_value = hp
	health_bar.value = current_hp
	shield_cap_bar.max_value = shield_capacity
	shield_cap_bar.value = current_shield_cap

	# Damages the player inside its hitbox, continuously, whenever player's invincibility time is over
	if $HitBox.monitoring:
		var bodies = $HitBox.get_overlapping_bodies()
		for b in bodies:
			if b.name == "Player":
				b._take_damage(30, global_position, 1.25)

	return

func _on_ChangePathTimer_timeout() -> void:
	var player : KinematicBody2D = get_tree().root.get_node("GameWorld").find_node("Player")
	if state == FLYING: # Charge towards player if still flying
		charge_point = player.global_position + Vector2(rand_range(-200,200), rand_range(-100,100))
		state = CHARGE
#		$ChangePathTimer.start(rand_range(1.0,1.5))
		return
	elif state == CHARGE: # Flying still if still charging toward player
		state = FLYING
		$ChangePathTimer.start(rand_range(4.5,5.5))
		return

func _on_HitBox_body_entered(body: Node) -> void:
	if body.name == "Player":
		body._take_damage(30, global_position)
	return

onready var missile_pods = $MissilePods
const MISSILE = preload("res://Scenes/Missile.tscn")
func _launch_missile() -> void:
	var missile_inst = MISSILE.instance()
	var m = missile_pods.get_children()
	m.shuffle()
	missile_inst.global_position = m[0].global_position
	get_tree().root.get_node("GameWorld").add_child(missile_inst)
	return

func _take_damage(damage : int = 0, shield_only : bool = false):
	# Have to do like, whenever is enough or not enough shield capacity to take the last hit, current_hp is always not being reduced until the current shield cap is zero, also current_hp only being reduced if current shield cap is zero and after triggered the longer invincibility timer.
#	print_debug(damage)
	if !$InvincibilityTimer.is_stopped():	return
	if damage > 0:
		var shield_damage = damage * 5
#		print_debug(shield_damage)
#		damage = damage * 10
		if current_shield_cap == 0 and !shield_only:
			if current_hp > 0:
				current_hp -= damage
#				$InvincibilityTimer.start(0.1)
				$AnimPlayer.stop()
				$AnimPlayer.play("Hurt")
			if current_hp <= 0:
				current_hp = 0
				print_debug("Destroyed")
				_destroyed()
			return
		if current_shield_cap > 0:
			current_shield_cap -= shield_damage
#			$InvincibilityTimer.start(0.025)
			$AnimPlayer.play("Shielding")
			if current_shield_cap <= 0:	current_shield_cap = 0
		if current_shield_cap < shield_capacity:
			$RechargeDelayTimer.start(shield_recharge_delay)
	return

func _destroyed() -> void:
	$AnimPlayer.play("RESET")
	$InvincibilityTimer.stop()
	$ChangePathTimer.stop()
	$RechargeDelayTimer.stop()
	$HitBox.set_deferred("monitoring", false)
	$HurtBox.set_deferred("monitorable", false)
	$Blocker.set_deferred("monitorable", false)
	$DestroyingSFX.play()
	$AnimPlayer.play("Destroyed")
	$AnimGraphic.play("idle")
	state = DESTROYING
	return

func _on_AnimPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "Destroyed":
		state = DESTROYED
		get_tree().root.get_node("GameWorld/AnimPlayer").play("BeatFinalBoss")
	return
