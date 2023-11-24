extends StaticBody3D

var Health = 1

func Hit_sucessful(damage, _Direction:= Vector3.ZERO, _Position:= Vector3.ZERO):
	Health -= damage
	if Health <= 0:
		queue_free()
