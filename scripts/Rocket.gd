extends RigidBody3D

var Damage: int = 0
var Explosion = preload("res://weapon resources/rocket_explosion.tscn")

func _on_body_entered(body):
	if body.is_in_group("Player"):
		return
	var E = Explosion.instantiate()
	var W = get_tree().get_root()
	E.set_global_transform(get_global_transform())
	W.add_child(E)
	if body.is_in_group("Target") and body.has_method("Hit_sucessful"):
		body.Hit_sucessful(Damage)
		queue_free()
	queue_free()



func _on_timer_timeout():
	queue_free()


