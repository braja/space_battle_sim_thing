extends Resource

#ship script
@export var ship_script: Script
#ship type: Battlecruiser, Fighter, Frigate
@export var ship_type: String = "Fighter"
#ship faction: fleet_1, fleet_2, fleet_3
@export var faction: String = "fleet_1"

#rigidbody parameters
@export var ship_weight: float = 16.0
@export var collision_radius: int = 14
@export var center_of_mass_offset: Vector2 = Vector2(5, 0)
@export var gravity_scale: float = 0.0

#ship node parameters
@export var hull_texture : CompressedTexture2D
@export var engine_texture : CompressedTexture2D
@export var engine_hframes : int = 10
@export var projectile : PackedScene
@export var explosion : PackedScene
@export var beam_color: Color
@export var beam_width: int
@export var invincibility_wait_time: float = .25
@export var attack_wait_time: float = .5
@export var engine_hide_threshold: int = 125

#ship combat stats
@export var health: int = 250
@export var max_speed: float = 300.0
@export var acceleration: float = 36.0
@export var leash_distance: float = 800.0
@export var flee_distance: float = 175.0
@export var attack_range: float = 550.0
@export var torque: float = 2.8
