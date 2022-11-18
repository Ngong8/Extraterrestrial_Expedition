extends KinematicBody2D

export var move_speed : int = 500;	export var acceleration : int = 1000
export var jump_force : int = 1000;	export var gravity : int = 2000
var current_move_speed : int
var input_strength : float
var direction : Vector2; var velocity: Vector2

onready var camera = get_node("Camera2D")
var des_zoom : Vector2
var zoom_spd : Vector2 = Vector2(0.5,0.5); var current_zoom_spd : Vector2 = zoom_spd
const MIN_ZOOM_LVL : Vector2 = Vector2(1.0,1.0)
const MAX_ZOOM_LVL : Vector2 = Vector2(5.0,5.0)
func _ready() -> void:
	des_zoom = camera.zoom
	current_move_speed = move_speed
	return


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	if event is InputEventMouseButton && event.is_pressed() :
		if event.button_index == BUTTON_WHEEL_UP && des_zoom >= MIN_ZOOM_LVL:
			des_zoom -= current_zoom_spd
		elif event.button_index == BUTTON_WHEEL_DOWN && des_zoom <= MAX_ZOOM_LVL:
			des_zoom += current_zoom_spd

func _physics_process(delta: float) -> void:
	camera.zoom = lerp(camera.zoom, des_zoom, 0.25)
	input_strength = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	velocity.x = input_strength * current_move_speed
	velocity.y += gravity * delta
	# Jump related coding:
	if is_on_floor():
		if Input.is_action_pressed("jump_up"):
			velocity.y = -jump_force
	else:
		if Input.is_action_just_released("jump_up") and velocity.y < -jump_force / 8:
			velocity.y = -jump_force/8
	
	velocity = move_and_slide(velocity, Vector2.UP)
	return
