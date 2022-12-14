extends KinematicBody2D

onready var graphic = get_node("%Graphic")
var item_name : String = "";	var item_icon_name : String = ""
var target : Node = null
var move_speed : int = 500;	var acceleration : int = 1000
var gravity : int = 2000
var direction : Vector2; var velocity: Vector2
func _ready() -> void:
	item_icon_name = item_name.to_lower()
	graphic.texture = load("res://Assets/items/" + item_icon_name + "_item.png")
#	print_debug(graphic.texture.get("region"))
	return

onready var loot_area = get_node("LootArea")
func _physics_process(delta: float) -> void:
	if target:
		collision_mask = 0
		direction = (target.global_position - global_position).normalized()
		velocity = velocity.move_toward(direction * move_speed, acceleration)
		if global_position.distance_to(target.global_position) <= 10:
#			print_debug(item_name)
			PlayerInventory._add_item(item_name, 1)
			target.get_node("%Inventory")._initialize_inventory()
			queue_free()
	else:
		collision_mask = 1
		velocity.y += gravity * delta
		velocity = velocity.move_toward(Vector2(), acceleration * delta)
	velocity = move_and_slide(velocity, Vector2.UP)
	return

func _on_LootArea_body_entered(body: Node) -> void:
	if body.name:	target = body

func _on_LootArea_body_exited(body: Node) -> void:
	if body.name:	target = null
