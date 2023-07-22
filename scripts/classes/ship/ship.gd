extends RigidBody2D

class_name Ship
const PI_TWO: float = 2 * PI
const PI180: float = 180 / PI
@onready var UI = get_tree().get_first_node_in_group("ui")
@onready var battlecruiser_script = load("res://scripts/classes/ship/battlecruiser/battecruiser.gd")
@onready var fighter_script = load("res://scripts/classes/ship/fighter/fighter.gd")
@onready var engine = $Engine
@onready var hull = $Hull
@onready var collision = $CollisionShape2D
@onready var collision_shape = $CollisionShape2D.shape
@onready var detection_area = $Detection
@onready var detection_collision = $Detection/CollisionShape2D
@onready var los_area = $LOS
@onready var los_collision = $LOS/CollisionShape2D
@onready var anim = $AnimationPlayer
@onready var invincibility_timer = $InvicibilityTimer
@onready var attack_timer = $AttackTimer
@onready var animation_timer = $AnimationTimer
@onready var BulletPool = get_tree().get_first_node_in_group("bullet_pool")
@onready var origin = $Origin
@onready var clickable_area = $Clickable
#@onready var my_faction = self.get_groups()[0]

@export var ship_type: String
@export var faction: String

@export var hull_texture : CompressedTexture2D
@export var engine_texture : CompressedTexture2D
@export var projectile : PackedScene
@export var explosion : PackedScene
@onready var beam_color : Color
@onready var beam_width: int
@export var engine_hide_threshold : int
@export var ship_weight : float
@export var center_of_mass_offset : Vector2
@export var torque: float
@export var health: int
@export var max_speed: float
@export var acceleration: float
@export var leash_distance: float
@export var flee_distance: float
@export var attack_range: float
@export var attack_cooldown: float
@export var invincible_cooldown: float

enum State {
	SEEKING,
	ATTACKING,
	EVADING,
	WANDERING,
	MOTHERSHIP
}

var currentState: int = State.SEEKING

var factions = ["fleet_1", "fleet_2", "fleet_3"]
var nearby_enemies : Array = []
var target
var nearby_allies : Array = []
var mothership

var orbit_distance = 600

var invincible = false

var attacking = false

var wander_angle = 0.0
var wander_range = 45.0

var possible_obstacle = false

func _ready():
	attack_timer.wait_time = attack_cooldown
	var tween = get_tree().create_tween()
	tween.tween_property(detection_collision.shape, "radius", 5600.0, 1)
	_init()


func _init():
	pass


func change_state(new_state: int) -> void:
	currentState = new_state

func friendly(node):
	return node == faction

func is_enemy_faction(group):
	if factions.has(group):
		return group != faction


#func find_closest_enemy() -> Node2D:
#	var closest_distance := 1e9
#	var closest_enemy: Node2D = null
#	for enemy in nearby_enemies:
#		if is_instance_valid(enemy):
#			var distance = position.distance_to(enemy.global_position)
#			if distance < closest_distance:
#				closest_distance = distance
#				closest_enemy = enemy
#	return closest_enemy
func find_closest_enemy() -> Node2D:
	var closest_sq_distance := 1e9
	var closest_enemy: Node2D = null
	var my_position = position
	for enemy in nearby_enemies:
		var sq_distance = my_position.distance_squared_to(enemy.global_position)
		if sq_distance < closest_sq_distance:
			closest_sq_distance = sq_distance
			closest_enemy = enemy
	return closest_enemy


func rotate_to_target(target_angle: float) -> void:
	var shortest_angle = fmod((target_angle - rotation + PI), PI_TWO) - PI
	if abs(shortest_angle) > 0.01:
		angular_velocity = sign(shortest_angle) * torque
	else:
		angular_velocity = 0



func accelerate(slow = false):
	var x_transform = transform.x
	var impulse
	if slow:
		impulse = x_transform * -acceleration/5
	else:
		impulse = x_transform * acceleration
	apply_central_impulse(impulse)
	
	var should_engine_be_visible = linear_velocity.length() >= engine_hide_threshold
	if engine.visible != should_engine_be_visible:
		engine.visible = should_engine_be_visible


func move(target_position: Vector2) -> void:
	var direction = (target_position - position).normalized()
	var target_angle = atan2(direction.y, direction.x)
	rotate_to_target(target_angle)
	accelerate()


func wander():
	var direction = Vector2(cos(wander_angle), sin(wander_angle))
	var target_angle = atan2(direction.y, direction.x)
	rotate_to_target(target_angle)
	accelerate()
	# Randomly adjust the wander_angle by up to wander_range degrees per second
	wander_angle += deg_to_rad(randf_range(-wander_range, wander_range) * get_process_delta_time())
	# Keep wander_angle within the range of 0 to 2*PI
	wander_angle = fmod(wander_angle, PI_TWO)


func evade(target_position: Vector2) -> void:
	var direction = (position - target_position).normalized() 
	var random_angle = deg_to_rad(randi_range(-45, 45)) # Random angle for variation in evasion
	direction = Vector2(direction.x * cos(random_angle) - direction.y * sin(random_angle), direction.x * sin(random_angle) + direction.y * cos(random_angle))
	var target_angle = atan2(direction.y, direction.x)
	rotate_to_target(target_angle)
	accelerate()


func flank(target_position: Vector2) -> void:
	var direction = (target_position - position).normalized()
	var flanking_angle = deg_to_rad(randi_range(120, 240)) # Change this range for more drastic flanking
	direction = Vector2(direction.x * cos(flanking_angle) - direction.y * sin(flanking_angle), direction.x * sin(flanking_angle) + direction.y * cos(flanking_angle))
	var target_angle = atan2(direction.y, direction.x)
	rotate_to_target(target_angle)
	accelerate()


func orbit_mothership(target_position: Vector2, distance):
	var direction = (target_position - position).normalized()
	var target_angle = atan2(direction.y, direction.x)
	rotate_to_target(target_angle)
	if distance > orbit_distance:
		accelerate()
	else:
		accelerate(true)


#func _on_crash(body):
#	if body.is_in_group("ship"):
#		if abs(linear_velocity.x + body.linear_velocity.x) >= 275 or abs(linear_velocity.y + body.linear_velocity.y) >= 275:
#			die()


func attack() -> void:
	if not projectile or not is_instance_valid(target):
		return

	if possible_obstacle and target.z_index != z_index and target.possible_obstacle == true:
		return

	if not attacking and currentState != State.EVADING:
		# Get the ship's facing direction
		var ship_direction: Vector2 = Vector2(cos(rotation), sin(rotation))

		# Calculate the direction to the target
		var target_direction: Vector2 = (target.global_position - global_position).normalized()

		# Calculate the angle difference in degrees
		var angle_difference: float = ship_direction.angle_to(target_direction) * PI180

		# Only attack if the target is within a 35 degree angle in front of the ship
		if abs(angle_difference) <= 90:
			var proj = BulletPool.request_bullet()
			var predicted_target_position = target.global_position + target.linear_velocity
			var direction = (predicted_target_position - position).normalized()
			proj.faction = faction
			proj.possible_obstacle = possible_obstacle
			proj.z_index = z_index
			proj.global_position = global_position
			proj.global_transform = Transform2D(atan2(direction.y, direction.x), global_position)
			proj.timer.start()
			attacking = true
			attack_timer.start()



func take_damage(amount):
	if invincible:
		return
	if health - amount <= 0:
		die()
	else:
		invincibility_timer.start()
		var tween = get_tree().create_tween()
		tween.tween_property(hull, "modulate", Color(5.0, 5.0, 5.0, 5.0), .125)
		health -= amount
		invincible = true


func die():
	var new_explosion = explosion.instantiate()
	new_explosion.global_position = global_position
	get_tree().get_root().add_child(new_explosion)	
	call_deferred("toggle_physics")
	if ship_type == "Fighter":
		FighterPool.return_to_pool(self)


func toggle_physics():
	visible = !visible
	clickable_area.visible = !clickable_area.visible
	collision.disabled = !collision.disabled
	detection_area.monitoring = !detection_area.monitoring
	los_area.monitoring = !los_area.monitoring
	detection_collision.disabled = !detection_collision.disabled
	los_collision.disabled = !los_collision.disabled
	set_physics_process(!is_physics_processing())
	set_process(!is_processing())

func _on_detection_body_entered(body):
	if body.is_in_group("mothership") && not  body.get_groups().any(is_enemy_faction):
		mothership = body
	if body.get_groups().any(is_enemy_faction):
		if not nearby_enemies.has(body):
			nearby_enemies.append(body)


func _on_detection_body_exited(body):
	if nearby_enemies.has(body):
		nearby_enemies.erase(body)
		if target == body:
			target = null


func _on_los_area_entered(area):
	if area.is_in_group("line_of_sight"):
		possible_obstacle = true


func _on_los_area_exited(area):
	if area.is_in_group("line_of_sight"):
		possible_obstacle = false


func _on_invicibility_timer_timeout():
	var tween = get_tree().create_tween()
	tween.tween_property(hull, "modulate", Color(1.0, 1.0, 1.0, 1.0), .125)
	invincible = false


func _on_attack_timer_timeout():
	attacking = false
	#attack()


func _on_animation_timer_timeout():
	if engine.frame < engine.hframes - 1:
		engine.frame += 1
		animation_timer.start()
		return
	else:
		engine.frame = 0
		animation_timer.start()


func _on_texture_rect_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == 1:
			print("clicked on", self.ship_type)
			return
	#	if Input.is_action_just_pressed("left_click"):
	#		print("clicked on", self.ship_type)


func _on_clickable_mouse_entered():
	UI.show_tooltip(self)


func _on_clickable_mouse_exited():
	UI.hide_tooltip()
