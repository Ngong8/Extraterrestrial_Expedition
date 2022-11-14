extends Camera2D

var current_speed_mult = 1
var speed_mult = 2;	var normal_speed_mult = 1
var speed_x = 20
var speed_y = 20

func _physics_process(_delta):
	if current:
		if Input.is_key_pressed(KEY_R):
			get_tree().reload_current_scene()
		if Input.is_key_pressed(KEY_SHIFT):
			current_speed_mult = speed_mult
		else:	current_speed_mult = normal_speed_mult
		
		if Input.is_action_pressed("ui_up"):
			translate(Vector2(0,-speed_y * current_speed_mult))
		if Input.is_action_pressed("ui_down"):
			translate(Vector2(0,speed_y * current_speed_mult))
		if Input.is_action_pressed("ui_left"):
			translate(Vector2(-speed_x * current_speed_mult,0))
		if Input.is_action_pressed("ui_right"):
			translate(Vector2(speed_x * current_speed_mult,0))
