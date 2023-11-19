extends Resource

class_name Weapon_Resource

@export var Weapon_name: String
@export var Activate_anim: String
@export var Deactivate_anim: String
@export var Shoot_anim: String
@export var OOA_anim: String
@export var Reload_anim: String

@export var Current_ammo: int
@export var Reserve_ammo: int
@export var Magazine: int
@export var Max_Ammo: int

@export var Auto_fire: bool
@export var Weapon_range: int
@export var Damage: int
@export_flags("Hitscan", "Projectile") var Type
@export var Projectile_To_Load: PackedScene
@export var Projectile_Velocity: int
