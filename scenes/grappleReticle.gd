extends Node3D

var camera
@onready var reticle = $reticle
@onready var ray_cast_3d = $RayCast3D
@onready var player = $"../../../Player"

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_viewport().get_camera_3d()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	ray_cast_3d.look_at(player.position + Vector3(0, 1.5,0), Vector3.UP)
	ray_cast_3d.force_raycast_update()
	reticle.hide()
	if camera.is_position_in_frustum(global_position) and ray_cast_3d.is_colliding():
		if ray_cast_3d.get_collider().name == "Player":
			reticle.rotation += 3 * delta
			reticle.show()
			reticle.set_global_position(camera.unproject_position(global_position) - Vector2(64, 64))
