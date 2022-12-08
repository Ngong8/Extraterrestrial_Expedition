extends KinematicBody2D

# Movement variables
export var move_speed : int = 200;	export var acceleration : int = 2000;	export var gravity : int = 2000
var direction : Vector2; var velocity: Vector2
var states : Dictionary = {"crash_landing": 0, "crash_landed": 1, "flying": 2}
var state : int = 0
onready var anim_gprahic = $AnimGraphic
onready var camera = $Camera2D
func _ready() -> void:
	state = states.crash_landing
	return

func _set_camera(enable : bool = false) -> void:
	camera.current = enable
	return

onready var crafting_area = $CraftingArea
func _physics_process(delta: float) -> void:
	if state == states.flying:
		anim_gprahic.play("flying")
		velocity.y = move_toward(velocity.y, -move_speed, acceleration * delta)
	elif state == states.crash_landed:
		anim_gprahic.play("crashed")
	elif state == states.crash_landing:
		if $LandingCast.is_colliding():
			anim_gprahic.play("malfunction")
			velocity.y += gravity * 0.25
		else:
			anim_gprahic.play("flying")
			velocity.y = move_toward(velocity.y, gravity, acceleration * delta)
		
	velocity = move_and_slide(velocity, Vector2.UP)
	
	# Have to do like, if the pod is crashlanded onto... well, land, it will stop being pull down.
	if is_on_floor():	state = states.crash_landed
	
	var bodies = $EscapeArea.get_overlapping_bodies()
	var ugly_mech = get_tree().root.get_node_or_null("GameWorld/UglyMech")
	for b in bodies:
		if b.name == "Player":
			if Input.is_action_just_pressed("use"):
				print_debug(b.name)
				for a in PlayerInventory.inventory:
					print_debug(PlayerInventory.inventory)
					if PlayerInventory.inventory[a][0] == "Thruster":
#					print_debug(PlayerInventory.inventory[a][0])
						if ugly_mech and ugly_mech.state == ugly_mech.FINISHED:
							state = states.flying
							get_tree().root.get_node("GameWorld/AnimPlayer").play("Escaping")
							$AnimPlayer.play("EndingText")
							get_tree().root.get_node("GameWorld/EndingMusicPlayer").play()
							return
						else:
							$AnimPlayer2.play("AlertFading")
							get_node("%AlertLbl").text = "You have not defeated the final boss yet!"
#							print_debug("You have not defeated the final boss yet!")
					else:
						$AnimPlayer2.play("AlertFading")
						get_node("%AlertLbl").text = "You have not acquired the thruster yet! Craft them to repair the ship!"
#						print_debug("You have not acquired the engine or thruster yet!")
	return


func _on_CraftingArea_body_entered(body: Node) -> void:
	if body.name == "Player":
		body.get_node("%Crafting").show()

func _on_CraftingArea_body_exited(body: Node) -> void:
	if body.name == "Player":
		body.get_node("%Crafting").hide()

func _on_EscapeArea_body_entered(body: Node) -> void:
	if body.name == "Player":
		print_debug("Entered. Escape now?")
	return

func _on_EscapeArea_body_exited(body: Node) -> void:
	if body.name == "Player":
		print_debug("Not escaping right now.")
	return
