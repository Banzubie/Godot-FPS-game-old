extends Node3D

signal Weapon_Changed
signal Update_Ammo
signal Update_Weapon_Stack

@onready var Animation_Player = get_node("%AnimationPlayer")
@onready var Bullet_point = get_node("%Bullet_point")

var Debug_bullet = preload("res://bullet_debug.tscn")

var Current_Weapon = null

var Weapon_Stack = []

var Weapon_Indicator = 0

var Next_Weapon: String

var Weapon_List = {}

@export var _weapon_resources: Array[Weapon_Resource]


@export var Start_Weapons: Array[String]

enum {NULL, HITSCAN, PROJECTILE}

func _ready():
	Initialize(Start_Weapons)
	
func _input(event):
	if event.is_action_pressed("Weapon_up"):
		Weapon_Indicator = min(Weapon_Indicator + 1, Weapon_Stack.size() - 1)
		exit(Weapon_Stack[Weapon_Indicator])
		
	if event.is_action_pressed("Weapon_down"):
		Weapon_Indicator = max(Weapon_Indicator - 1, 0)
		exit(Weapon_Stack[Weapon_Indicator])
	
	if event.is_action_pressed("Shoot"):
		shoot()
		
	if event.is_action_pressed("Reload"):
		reload()

func Initialize(_start_weapons: Array):
	for weapon in _weapon_resources:
		Weapon_List[weapon.Weapon_name] = weapon
		
	for i in _start_weapons:
		Weapon_Stack.push_back(i)
		
	Current_Weapon = Weapon_List[Weapon_Stack[0]]
	emit_signal("Update_Weapon_Stack", Weapon_Stack)
	enter()
	
func enter():
	Animation_Player.queue(Current_Weapon.Activate_anim)
	emit_signal("Weapon_Changed", Current_Weapon.Weapon_name)
	emit_signal("Update_Ammo", [Current_Weapon.Current_ammo, Current_Weapon.Reserve_ammo])

func exit(_next_weapon: String):
	if _next_weapon != Current_Weapon.Weapon_name:
		if Animation_Player.get_current_animation() != Current_Weapon.Deactivate_anim:
			Animation_Player.play(Current_Weapon.Deactivate_anim)
			Next_Weapon = _next_weapon
	

func Change_Weapon(weapon_name: String):
	Current_Weapon = Weapon_List[weapon_name]
	Next_Weapon = ''
	enter()


func _on_animation_player_animation_finished(anim_name):
	if anim_name == Current_Weapon.Deactivate_anim:
		Change_Weapon(Next_Weapon)
		
	if anim_name == Current_Weapon.Shoot_anim && Current_Weapon.Auto_fire == true:
		if Input.is_action_pressed("Shoot"):
			shoot()
		
func shoot():
	if Current_Weapon.Current_ammo > 0:
		if !Animation_Player.is_playing():
			Animation_Player.play(Current_Weapon.Shoot_anim)
			Current_Weapon.Current_ammo -= 1
			emit_signal("Update_Ammo", [Current_Weapon.Current_ammo, Current_Weapon.Reserve_ammo])
			var Camera_Collision = Get_Camera_Collison()
			match Current_Weapon.Type:
				NULL:
					print("Weapon Type not chosen")
				HITSCAN: 
					Hitscan_Collision(Camera_Collision)
				PROJECTILE:
					Launch_Projectile(Camera_Collision)
	else:
		reload()
	
func reload():
	if Current_Weapon.Current_ammo == Current_Weapon.Magazine:
		return
	elif !Animation_Player.is_playing():
		if Current_Weapon.Reserve_ammo != 0:
			Animation_Player.play(Current_Weapon.Reload_anim)
			var Reload_Amount = min(Current_Weapon.Magazine - Current_Weapon.Current_ammo, Current_Weapon.Magazine,Current_Weapon.Reserve_ammo)
			Current_Weapon.Current_ammo += Reload_Amount
			Current_Weapon.Reserve_ammo -= Reload_Amount
			emit_signal("Update_Ammo", [Current_Weapon.Current_ammo, Current_Weapon.Reserve_ammo])
		else:
			Animation_Player.play(Current_Weapon.OOA_anim)
	
	
func Get_Camera_Collison()->Vector3:
	var camera = get_viewport().get_camera_3d()
	var viewport = get_viewport().get_size()
	
	var Ray_Origin = camera.project_ray_origin(viewport/2)
	var Ray_End = Ray_Origin + camera.project_ray_normal(viewport/2) * Current_Weapon.Weapon_range
	var New_Intersection = PhysicsRayQueryParameters3D.create(Ray_Origin, Ray_End)
	
	var Intersection = get_world_3d().direct_space_state.intersect_ray(New_Intersection)
	
	
	if not Intersection.is_empty():
		var Col_Point = Intersection.position
		return Col_Point
	else:
		return Ray_End
		
func Hitscan_Collision(Col_point):
	var Bullet_direction = (Col_point - Bullet_point.get_global_transform().origin).normalized()
	var New_Intersection = PhysicsRayQueryParameters3D.create(Bullet_point.get_global_transform().origin, Col_point+Bullet_direction*2)
	
	var Bullet_col = get_world_3d().direct_space_state.intersect_ray(New_Intersection)
	
	if Bullet_col:
		var Hit_indicator = Debug_bullet.instantiate()
		var world = get_tree().get_root().get_child(0)
		world.add_child(Hit_indicator)
		Hit_indicator.global_translate(Bullet_col.position)
		Hitscan_Damage(Bullet_col.collider)
		
func Hitscan_Damage(Collider):
	if Collider.is_in_group("Target") and Collider.has_method("Hit_sucessful"):
		Collider.Hit_sucessful(Current_Weapon.Damage)
		
	
func Launch_Projectile(Point: Vector3):
	var Direction = (Point - Bullet_point.get_global_transform().origin).normalized()
	var Projectile = Current_Weapon.Projectile_To_Load.instantiate()
	
	Bullet_point.add_child(Projectile)
	Projectile.Damage = Current_Weapon.Damage
	Projectile.set_linear_velocity(Direction*Current_Weapon.Projectile_Velocity)
	
	
	
	
