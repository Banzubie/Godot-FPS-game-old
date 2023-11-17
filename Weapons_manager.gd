extends Node3D

signal Weapon_Changed
signal Update_Ammo
signal Update_Weapon_Stack

@onready var Animation_Player = get_node("%AnimationPlayer")

var Current_Weapon = null

var Weapon_Stack = []

var Weapon_Indicator = 0

var Next_Weapon: String

var Weapon_List = {}

@export var _weapon_resources: Array[Weapon_Resource]


@export var Start_Weapons: Array[String]

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
		
func shoot():
	Animation_Player.play(Current_Weapon.Shoot_anim)
	
func reload():
	Animation_Player.play(Current_Weapon.Reload_anim)
