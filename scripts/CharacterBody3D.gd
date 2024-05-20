extends CharacterBody3D


const NORM_SPEED = 10.0
const JUMP_VELOCITY = 8
const SENSITIVITY = 0.003
const CROUCH_SPEED = 4.5
const DASH_VELOCITY = 30.0
const DASH_DURATION = 0.15
const GRAPPLE_VELOCITY = 25.0

var gravity = 20
var speed = NORM_SPEED
var dashTime : float = 0
var direction = Vector3(0,0,0)
var grapplePosition : Vector3 = Vector3(0,0,0)

var hitTime : float = 0
var hitDir : Vector3 = Vector3(0,0,0)
# Get the gravity from the project settings to be synced with RigidBody nodes.
@onready var collision_stand = $CollisionStand
@onready var collision_crouch = $CollisionCrouch
@onready var ray_cast_crouch = $RayCastCrouch
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var hit_rect = $Head/Camera3D/Control/ColorRect

@onready var Bullet_point = get_node("Head/SubViewportContainer/SubViewport/guncam/Weapons_manager/FPS_rig/Bullet_point2")

const GRAPPLE_HOOK = preload("res://weapon resources/grappleHook.tscn")


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Head/SubViewportContainer/SubViewport.size = DisplayServer.window_get_size()
	
func _input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -1.5, 1.5)

func _physics_process(delta):
	# Add the gravity.
	$Head/SubViewportContainer/SubViewport/guncam.global_transform = camera.global_transform
	if !is_on_floor():
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
	
	direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
	direction = handleGrapple(direction)
	
	if direction and is_on_floor():
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		if grapplePosition != Vector3(0,0,0):
			velocity.y = direction.y * speed
	elif !is_on_floor():
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		if grapplePosition != Vector3(0,0,0):
			velocity.y = direction.y * speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0
		#velocity.x = move_toward(velocity.x, 0, speed)
		#velocity.z = move_toward(velocity.z, 0, speed)
	
	if Input.is_action_just_pressed("dash"):
		dashTime = DASH_DURATION
		
	if dashTime > 0:
		velocity.x = direction.x * DASH_VELOCITY
		velocity.z = direction.z * DASH_VELOCITY
		dashTime -= delta
	
	if hitTime > 0:
		if is_on_floor():
			velocity.y = 2.5
		velocity.x = hitDir.x * 10.0
		velocity.z = hitDir.z * 10.0
		hitTime -= delta
		
	move_and_slide()

func _on_pickup_detection_body_entered(_body):
	$Head/SubViewportContainer/SubViewport/guncam/Weapons_manager.Add_Ammo(20)
	_body.queue_free()

func hit(dir):
	if dashTime > 0:
		return
	if hitTime < 1:
		hitDir = dir
		hitTime = .05
	hit_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	hit_rect.visible = false

func handleGrapple(dir):
	if Input.is_action_just_pressed('grapple'):
		var Camera_Collision = Get_Camera_Collison()
		fireGrapple(Camera_Collision)
		#if $Head/Camera3D/GrappleCast.is_colliding():
			#var collider = $Head/Camera3D/GrappleCast.get_collider()
			#
			#if collider.is_in_group('grapplePoint'):
				#grapplePosition = $Head/Camera3D/GrappleCast.get_collision_point()
	if Input.is_action_pressed('grapple') and grapplePosition != Vector3(0,0,0):
		dir = (grapplePosition - $Head.global_position).normalized()
		speed = GRAPPLE_VELOCITY
	else:
		grapplePosition = Vector3(0,0,0)
		speed = NORM_SPEED
	return dir
		
func updateGrapple(Point: Vector3):
	grapplePosition = Point

func fireGrapple(Point: Vector3):
	var Direction = (Point - Bullet_point.get_global_transform().origin).normalized()
	var Projectile = GRAPPLE_HOOK.instantiate()
	
	Bullet_point.add_child(Projectile)
	Projectile.set_linear_velocity(Direction*GRAPPLE_VELOCITY)

func Get_Camera_Collison()->Vector3:
	var camera = get_viewport().get_camera_3d()
	var viewport = get_viewport().get_size()
	
	var Ray_Origin = camera.project_ray_origin(viewport/2)
	var Ray_End = Ray_Origin + camera.project_ray_normal(viewport/2) * 25
	var New_Intersection = PhysicsRayQueryParameters3D.create(Ray_Origin, Ray_End)
	
	var Intersection = get_world_3d().direct_space_state.intersect_ray(New_Intersection)
	
	
	if not Intersection.is_empty():
		var Col_Point = Intersection.position
		return Col_Point
	else:
		return Ray_End
