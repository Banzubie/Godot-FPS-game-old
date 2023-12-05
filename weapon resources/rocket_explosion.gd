extends Area3D

var Position: Vector3
var Impact = 10

@onready var _Particles = $GPUParticles3D
# Called when the node enters the scene tree for the first time.
func _ready():
	_Particles.emitting = true


func _on_timer_timeout():
	queue_free()


func _on_body_entered(body):
	Position = get_global_transform().origin
	if body.is_in_group("Target") and body.has_method("Hit_sucessful"):
		body.Hit_sucessful(Impact, Position, Vector3(0,0,0))
