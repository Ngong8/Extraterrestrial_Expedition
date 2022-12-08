extends Area2D

func _on_LostItem_body_entered(body: Node) -> void:
	if body.name == "Player":
		body.get_node("%QuestLbl").text = "Objective:\nSo it was that silly thing all along?\n(Sigh...) Now you can find a way to escape this place..."
		queue_free()
	return
