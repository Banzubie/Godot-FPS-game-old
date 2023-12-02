extends CharacterBody3D


const NORM_SPEED = 7.0
const JUMP_VELOCITY = 5.5
const SENSITIVITY = 0.003
const CROUCH_SPEED = 4.5

var speed = NORM_SPEED
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 10.5
@onready var collision_stand = $CollisionStand
@onready var collision_crouch = $CollisionCrouch
@onready var ray_cast_crouch = $RayCastCrouch
@onready var head = $Head
@onready var camera = $Head/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Head/SubViewportContainer/SubViewport.size = DisplayServer.window_get_size()
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -1.5, 1.5)

func _physics_process(delta):
	# Add the gravity.
	$Head/SubViewportContainer/SubViewport/guncam.global_transform = camera.global_transform
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("crouch") && is_on_floor():
		collision_stand.disabled = true
		collision_crouch.disabled = false
		head.position.y = lerp(head.position.y, .75, delta * 10)
		speed = CROUCH_SPEED
	elif !ray_cast_crouch.is_colliding():
		collision_stand.disabled = false
		collision_crouch.disabled = true
		head.position.y = lerp(head.position.y, 1.5, delta * 10)
		speed = NORM_SPEED
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()
