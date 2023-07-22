extends Node2D

@onready var Ship : PackedScene = load("res://scenes/ships/ship_base/ship.tscn")
@onready var ghost_ship = $GhostShip

@onready var fleet_1_fighter: Resource = load("res://resources/ships/fighters/fleet_1_fighter.tres")
@onready var fleet_2_fighter: Resource = load("res://resources/ships/fighters/fleet_2_fighter.tres")
@onready var fleet_3_fighter: Resource = load("res://resources/ships/fighters/fleet_3_fighter.tres")

@onready var fleet_1_battlecruiser: Resource = load("res://resources/ships/battlecruisers/fleet_1_battlecruiser.tres")
@onready var fleet_2_battlecruiser: Resource = load("res://resources/ships/battlecruisers/fleet_2_battlecruiser.tres")
@onready var fleet_3_battlecruiser: Resource = load("res://resources/ships/battlecruisers/fleet_3_battlecruiser.tres")

@onready var fleet_1_frigate: Resource = load("res://resources/ships/frigates/fleet_1_frigate.tres")
@onready var fleet_2_frigate: Resource = load("res://resources/ships/frigates/fleet_2_frigate.tres")
@onready var fleet_3_frigate: Resource = load("res://resources/ships/frigates/fleet_3_frigate.tres")

@export var world_node: Node2D

@onready var faction_to_fighter = {
	"fleet_1": fleet_1_fighter,
	"fleet_2": fleet_2_fighter,
	"fleet_3": fleet_3_fighter
}

var creating_ship = false
var to_be_created
var to_be_requested = false

func _ready():
	FighterPool.clear_pool()
	for i in range(FighterPool.pool_size):
		call_deferred("create_ship", fleet_1_fighter, 0, Vector2.ZERO)
		call_deferred("create_ship", fleet_2_fighter, 0, Vector2.ZERO)
		call_deferred("create_ship", fleet_3_fighter, 0, Vector2.ZERO)


 #Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if creating_ship:
		ghost_ship.visible = true
		ghost_ship.position = get_global_mouse_position()
	else:
		ghost_ship.visible = false
		
	if Input.is_action_just_pressed("1"):
		pre_creation(fleet_1_battlecruiser, false)
	if Input.is_action_just_pressed("2"):
		pre_creation(fleet_2_battlecruiser, false)
	if Input.is_action_just_pressed("3"):
		pre_creation(fleet_3_battlecruiser, false)
	if Input.is_action_just_pressed("q"):
		pre_creation(fleet_1_frigate, false)
	if Input.is_action_just_pressed("w"):
		pre_creation(fleet_2_frigate, false)
	if Input.is_action_just_pressed("e"):
		pre_creation(fleet_3_frigate, false)
	if Input.is_action_just_pressed("a"):
		pre_creation(fleet_1_fighter, true)
	if Input.is_action_just_pressed("s"):
		pre_creation(fleet_2_fighter, true)
	if Input.is_action_just_pressed("d"):
		pre_creation(fleet_3_fighter, true)
	
	if creating_ship:
		if Input.is_action_pressed("z"):
			ghost_ship.rotation += -1 * delta
		if Input.is_action_pressed("x"):
			ghost_ship.rotation += 1 * delta
		if Input.is_action_just_pressed("left_click"):
			if to_be_requested:
				FighterPool.request_ship(to_be_created.faction, ghost_ship.rotation_degrees, get_global_mouse_position())
			else:
				print(ghost_ship.rotation, " | ", ghost_ship.rotation_degrees)
				create_ship(to_be_created, ghost_ship.rotation_degrees, get_global_mouse_position())
			#ghost_ship.set_global_rotation(90.0)
			to_be_requested = false
			to_be_created = null
			creating_ship = false
			

func pre_creation(ship, is_request):
	creating_ship = true
	ghost_ship.visible = true
	ghost_ship.scale = Vector2(1, 1)
	ghost_ship.texture = ship.hull_texture
	if ship.ship_type == "Battlecruiser":
		ghost_ship.scale = Vector2(7, 7)
	if ship.ship_type == "Frigate":
		ghost_ship.scale = Vector2(2.5, 2.5)
	to_be_created = ship
	to_be_requested = is_request


func create_ship(ship, ship_rotation, ship_position):
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
	new_ship.leash_distance = ship.leash_distance
	new_ship.flee_distance = ship.flee_distance
	new_ship.attack_range = ship.attack_range
	new_ship.torque = ship.torque
	new_ship.engine_hide_threshold = ship.engine_hide_threshold
	new_ship.global_position = ship_position
	new_ship.set_rotation_degrees(ship_rotation - 90)
	add_child(new_ship)
	if ship.ship_type == "Battlecruiser":
		new_ship.add_to_group("mothership")
		new_ship.fighter = faction_to_fighter[ship.faction]
		new_ship.spawner = self
		new_ship.hull.scale = Vector2(7, 7)
		new_ship.engine.scale = Vector2(7, 7)
		new_ship.clickable_area.size = new_ship.clickable_area.size * 7
		new_ship.clickable_area.position = -new_ship.clickable_area.size / 2
		new_ship.laser.beam.width = ship.beam_width
		new_ship.laser.beam.default_color = ship.beam_color
		print(ship.beam_color)
	if ship.ship_type == "Fighter":
		new_ship.clickable_area.visible = false
		new_ship.toggle_physics()
		FighterPool.fighter_pool.append(new_ship)
	if ship.ship_type == "Frigate":
		new_ship.hull.scale = Vector2(2.5, 2.5)
		new_ship.engine.scale = Vector2(2.5, 2.5)
		new_ship.clickable_area.scale = Vector2(2.5, 2.5)
	new_ship.add_to_group(ship.ship_type)
	new_ship.add_to_group(ship.faction)
	new_ship.hull.texture = ship.hull_texture
	new_ship.engine.texture = ship.engine_texture
	new_ship.engine.hframes = ship.engine_hframes
	new_ship.animation_timer.start()
	new_ship.collision_shape.radius = ship.collision_radius


