extends CharacterBody3D

var Health = 10
var player = null
var state_machine

const SPEED = 4.0
const ATTACK_RANGE = 2.5

@export var player_path := "/root/World/Player"
var ammo = load("res://scenes/ammo_box.tscn")
@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree

func _ready():
	player = get_node(player_path)
	state_machine = anim_tree.get('parameters/playback')
	
func _process(delta):
	velocity = Vector3.ZERO
	
	match state_machine.get_current_node():
		"zombieRun":
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			look_at(Vector3(global_position.x + velocity.x, global_position.y, global_position.z + velocity.z), Vector3.UP)
		"zombieAttack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	
	anim_tree.set('parameters/conditions/attack', _target_in_range())
	anim_tree.set('parameters/conditions/run', !_target_in_range())
	
	anim_tree.get('parameters/playback')
	
	move_and_slide()
	
func _target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE
	
func _hit_finished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.0:
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir)

func Hit_sucessful(damage, _Direction:= Vector3.ZERO, _Position:= Vector3.ZERO):
	var Hit_Position = _Position - get_global_transform().origin
	Health -= damage
	if Health <= 0:
		anim_tree.set('parameters/conditions/die', true)
		await get_tree().create_timer(1.5).timeout
		var newAmmo = ammo.instantiate()
		newAmmo.position = position
		get_parent_node_3d().add_child(newAmmo)
		queue_free()
