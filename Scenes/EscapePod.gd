extends KinematicBody2D

# Movement variables
export var move_speed : int = 500;	export var acceleration : int = 2000;	export var gravity : int = 2000
var direction : Vector2; var velocity: Vector2
var states : Dictionary = {"crash_landing": 0, "idle": 1}
var state : int
onready var graphic = $Graphic
func _ready() -> void:
	state = states.crash_landing
	return

onready var crafting_area = $CraftingArea
func _physics_process(delta: float) -> void:
	if state == 0:
		velocity.y += gravity * delta
		velocity = move_and_slide(velocity, Vector2.UP)
	else:
		graphic.frame = 1
		pass
	
	# Have to do like, if the pod is crashlanded onto... well, land, it will stop being pull down.
	if is_on_floor():	state = states.idle
	
	var bodies = crafting_area.get_overlapping_bodies()
	for i in bodies:
		pass
	return
