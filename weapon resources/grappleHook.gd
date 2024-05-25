extends RigidBody3D

@export var player_path := "/root/World/Player"
var player = null
# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node(player_path)
	player.grappleActive = true

func _on_body_entered(body):
	if body.is_in_group("Player"):
		return
	if body.is_in_group("grapplePoint"):
		player.updateGrapple(body.position)
		freeze = true
		await get_tree().create_timer(.5).timeout
		queue_free()
		player.grappleActive = false

func _on_timer_timeout():
	var Direction = (global_position - player.global_position).normalized()
	set_linear_velocity(Direction * -25.0)
	await get_tree().create_timer(.7).timeout
	queue_free()
	player.grappleActive = false
