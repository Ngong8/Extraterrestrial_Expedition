extends KinematicBody2D
# Movement variables
export var move_speed : int = 500;	export var acceleration : int = 2000
export var jump_force : int = 1000;	export var gravity : int = 2000
var current_move_speed : int
var input_strength : float
var direction : Vector2; var velocity: Vector2
# Camera related stuff
onready var camera = get_node("Camera2D")
var des_zoom : Vector2
var zoom_spd : Vector2 = Vector2(0.5,0.5); var current_zoom_spd : Vector2 = zoom_spd
const MIN_ZOOM_LVL : Vector2 = Vector2(1.0,1.0)
const MAX_ZOOM_LVL : Vector2 = Vector2(10.0,10.0)
# Player's stats
var hp : int = 30;	var current_hp : int = hp
var durability : int = 0;	var armor_rating : int = 0;	var shield_capacity : int = 0
var shield_recharge_delay : float;	var shield_recharge_rate : float
var current_shield_cap : int = 0
var shield_recharge_gap : int = 30;	var current_recharge_gap : int = 0
onready var health_bar = get_node("%HealthBar")
onready var shield_cap_bar = get_node("%ShieldCapBar")
func _ready() -> void:
	des_zoom = camera.zoom
	current_move_speed = move_speed
	return

var a
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("restart"):
		a = get_tree().reload_current_scene()
	if event is InputEventMouseButton && event.is_pressed() :
		if event.button_index == BUTTON_WHEEL_UP && des_zoom >= MIN_ZOOM_LVL:
			des_zoom -= current_zoom_spd
		elif event.button_index == BUTTON_WHEEL_DOWN && des_zoom <= MAX_ZOOM_LVL:
			des_zoom += current_zoom_spd

var current_suit : ITEM = null
var can_move : bool = true
func _physics_process(delta: float) -> void:
	camera.zoom = lerp(camera.zoom, des_zoom, 0.25)
	if can_move:
		input_strength = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		if input_strength != 0:	velocity.x = move_toward(velocity.x, input_strength * current_move_speed, acceleration * delta)
		else: velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
	#	velocity.x = input_strength * current_move_speed
		# Jump related coding:
		if is_on_floor():
			if Input.is_action_pressed("jump_up"):
				velocity.y = -jump_force
		else:
			if Input.is_action_just_released("jump_up") and velocity.y < -jump_force / 8:
				velocity.y = -jump_force/8
	else:
		velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	# Health and Shield capacity bars displaying
	health_bar.max_value = hp
	health_bar.value = current_hp
	health_bar.get_node("Label").text = str(current_hp)
	if current_suit:
		shield_capacity = current_suit.shield_cap
		current_shield_cap = current_suit.current_shield_cap
		shield_recharge_rate = current_suit.shield_recharge_rate
		shield_recharge_delay = current_suit.shield_recharge_delay
		armor_rating = current_suit.armor_rating
		
		if $RechargeDelayTimer.is_stopped() and $InvincibilityTimer.is_stopped() and current_shield_cap < shield_capacity:
			if current_recharge_gap < shield_recharge_gap:	current_recharge_gap += 1
			else:
				current_suit.current_shield_cap += shield_recharge_rate
				current_recharge_gap = 0
		elif current_shield_cap >= shield_capacity:
			current_suit.current_shield_cap = shield_capacity
	else:
		shield_capacity = 0
		current_shield_cap = 0
		shield_recharge_rate = 0.1
		shield_recharge_delay = 0.1
		armor_rating = 0
	shield_cap_bar.max_value = shield_capacity
	shield_cap_bar.value = current_shield_cap
	shield_cap_bar.get_node("Label").text = str(current_shield_cap)
	return

func _refresh_equipped_armor(suit_item : ITEM = null) -> void:
	current_suit = suit_item
#	print_debug("Updated the suit stats")
	return

func _take_damage(damage : int = 0, knockback_pos : Vector2 = Vector2(), knockback_mod : float = 5.0):
	# Have to do like, whenever is enough or not enough shield capacity to take the last hit, current_hp is always not being reduced until the current shield cap is zero, also current_hp only being reduced if current shield cap is zero and after triggered the longer invincibility timer.
#	print_debug(damage)
	if !$InvincibilityTimer.is_stopped():	return
	if damage > 0:
		
		var shield_damage = damage * 5
#		print_debug(shield_damage)
#		damage = damage * 10
		if current_suit:
			if current_suit.current_shield_cap == 0:
				damage = damage - (damage * armor_rating / 100)
				if current_hp > 0:	current_hp -= damage
				if current_hp <= 0:
					current_hp = 0
					can_move = false
				$InvincibilityTimer.start(2.0)
				$AnimPlayer.play("Blink")
				velocity.y -= damage * knockback_mod * 15
				var dir_to_knockback_pos = (knockback_pos.x - global_position.x) * damage * knockback_mod
				if dir_to_knockback_pos > 20:	velocity.x += dir_to_knockback_pos
				else:	velocity.x -= dir_to_knockback_pos
				return
			if current_suit.current_shield_cap > 0:
				current_suit.current_shield_cap -= shield_damage
				$InvincibilityTimer.start(0.5)
				$AnimPlayer.play("Shielding")
				if current_suit.current_shield_cap <= 0:	current_suit.current_shield_cap = 0
				velocity.y -= damage * knockback_mod * 5
				var dir_to_knockback_pos = (knockback_pos.x - global_position.x) * (damage * knockback_mod) / 4
				if dir_to_knockback_pos > 20:	velocity.x += dir_to_knockback_pos
				else:	velocity.x -= dir_to_knockback_pos
			if current_suit.current_shield_cap < shield_capacity:
				$RechargeDelayTimer.start(shield_recharge_delay)
		
		else:
			damage = damage - (damage * armor_rating / 100)
			if current_hp > 0:	current_hp -= damage
			if current_hp <= 0:
				current_hp = 0
				can_move = false
			$InvincibilityTimer.start(2.0)
			$AnimPlayer.play("Blink")
			velocity.y -= damage * knockback_mod * 15
			var dir_to_knockback_pos = (knockback_pos.x - global_position.x) * damage * knockback_mod
			if dir_to_knockback_pos > 20:	velocity.x += dir_to_knockback_pos
			else:	velocity.x -= dir_to_knockback_pos
			return
#		if current_shield_cap == 0:
#			damage = damage - (damage * armor_rating / 100)
##			print_debug(damage) # incoming damage reduced by armor rating (in percentage)
#			if current_hp > 0:	current_hp -= damage
#			else: current_hp = 0
#			$InvincibilityTimer.start(2.0)
#			$AnimPlayer.play("Blink")
#			return
#		if current_shield_cap > 0:
#			current_shield_cap -= shield_damage
#			$InvincibilityTimer.start(0.5)
#			$AnimPlayer.play("Shielding")
#			if current_shield_cap <= 0:	current_shield_cap = 0
#		if current_shield_cap < shield_capacity:
#			$RechargeDelayTimer.start(shield_recharge_delay)
	return

func _on_RegenerationTimer_timeout() -> void:
	if can_move:
		if current_hp < hp:	current_hp += 1
		else: current_hp = hp
	return

func _on_InvincibilityTimer_timeout() -> void:
	$AnimPlayer.play("RESET")
	return
