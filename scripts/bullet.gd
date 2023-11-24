extends RigidBody3D

var Damage: int = 0
var Debug_bullet = preload("res://scenes/bullet_debug.tscn")


func _on_body_entered(body):
	var Hit_indicator = Debug_bullet.instantiate()
	var world = get_tree().get_root().get_child(0)
	world.add_child(Hit_indicator)
	Hit_indicator.global_translate(body.position)
	if body.is_in_group("Target") and body.has_method("Hit_sucessful"):
		body.Hit_sucessful(Damage)
		queue_free()
	queue_free()


func _on_timer_timeout():
	queue_free()
