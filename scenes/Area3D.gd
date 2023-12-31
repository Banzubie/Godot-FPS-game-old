extends Area3D

var zombie = load("res://temp enemy/zombie_test.tscn")

func _on_body_entered(body):
	var spawns = $"../Spawn_Points".get_children()
	for spawn in spawns:
		var newMob = zombie.instantiate()
		spawn.add_child(newMob)
	queue_free()
