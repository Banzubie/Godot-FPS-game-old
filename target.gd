extends RigidBody3D


var Health = 5

func Hit_sucessful(damage):
	Health -= damage
	print("Target health: " + str(Health))
	if Health <= 0:
		queue_free()
