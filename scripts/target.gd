extends RigidBody3D


var Health = 100

func Hit_sucessful(damage, _Direction:= Vector3.ZERO, _Position:= Vector3.ZERO):
	var Hit_Position = _Position - get_global_transform().origin
	Health -= damage
	print("Target health: " + str(Health))
	if Health <= 0:
		queue_free()
		
	if _Direction != Vector3.ZERO:
		apply_impulse(_Direction,Hit_Position*.2)
