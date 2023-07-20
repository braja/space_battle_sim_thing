extends Node2D

@onready var Ship : PackedScene = load("res://scenes/ships/ship_base/ship.tscn")

@onready var fleet_1_fighter: Resource = load("res://resources/ships/fighters/fleet_1_fighter.tres")
@onready var fleet_2_fighter: Resource = load("res://resources/ships/fighters/fleet_2_fighter.tres")
@onready var fleet_3_fighter: Resource = load("res://resources/ships/fighters/fleet_3_fighter.tres")

@onready var fleet_1_battlecruiser: Resource = load("res://resources/ships/battlecruisers/fleet_1_battlecruiser.tres")
@onready var fleet_2_battlecruiser: Resource = load("res://resources/ships/battlecruisers/fleet_2_battlecruiser.tres")
@onready var fleet_3_battlecruiser: Resource = load("res://resources/ships/battlecruisers/fleet_3_battlecruiser.tres")

@export var world_node: Node2D

@onready var faction_to_fighter = {
	"fleet_1": fleet_1_fighter,
	"fleet_2": fleet_2_fighter,
	"fleet_3": fleet_3_fighter
}



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("1"):
		create_ship(fleet_1_battlecruiser, get_global_mouse_position())
	if Input.is_action_just_pressed("2"):
		create_ship(fleet_2_battlecruiser, get_global_mouse_position())
	if Input.is_action_just_pressed("3"):
		create_ship(fleet_3_fighter, get_global_mouse_position())

func create_ship(ship, ship_position):
	var new_ship = Ship.instantiate()
	new_ship.set_script(ship.ship_script)
	new_ship.ship_type = ship.ship_type
	new_ship.faction = ship.faction
	new_ship.mass = ship.ship_weight
	new_ship.center_of_mass_mode = 1
	new_ship.center_of_mass = ship.center_of_mass_offset
	new_ship.gravity_scale = 0
	new_ship.projectile = ship.projectile
	new_ship.explosion = ship.explosion
	new_ship.invincible_cooldown = ship.invincibility_wait_time
	new_ship.attack_cooldown = ship.attack_wait_time
	new_ship.health = ship.health
	new_ship.max_speed = ship.max_speed
	new_ship.acceleration = ship.acceleration
	new_ship.flee_distance = ship.flee_distance
	new_ship.attack_range = ship.attack_range
	new_ship.torque = ship.torque
	new_ship.engine_hide_threshold = ship.engine_hide_threshold
	new_ship.global_position = ship_position
	world_node.add_child(new_ship)
	if ship.ship_type == "Battlecruiser":
		new_ship.fighter = faction_to_fighter[ship.faction]
		new_ship.spawner = self
		new_ship.hull.scale = Vector2(7, 7)
		new_ship.engine.scale = Vector2(7, 7)
	new_ship.hull.texture = ship.hull_texture
	new_ship.engine.texture = ship.engine_texture
	new_ship.engine.hframes = ship.engine_hframes
	new_ship.animation_timer.start()
	new_ship.collision_shape.radius = ship.collision_radius
