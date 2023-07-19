extends RigidBody2D

class_name Ship


#@onready var state_label = $StateLabel
#@onready var sprite = $Sprite2D
#@onready var engine = $Engine
#@onready var weapon = $Weapon
#@onready var anim = $AnimationPlayer
#@onready var projectile_spawner = $ProjectileSpawner
#@onready var detection_area = $Detection
#@onready var detection_collision = $Detection/CollisionShape2D
#@onready var minimap_update_timer = $UpdateMinimapPosition
@onready var my_faction = self.get_groups()[0]

@export var projectile : PackedScene
@export var explosion : PackedScene
@export var health: int
@export var max_speed: float
@export var acceleration: float
@export var flee_distance: float
@export var attack_range: float
@export var torque: float
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



func change_state(new_state: int) -> void:
	currentState = new_state


func is_enemy_faction(group):
	if factions.has(group):
		return group != my_faction


func find_closest_enemy() -> Node2D:
	var closest_distance := 1e9
	var closest_enemy: Node2D = null
	for enemy in nearby_enemies:
		if is_instance_valid(enemy):
			var distance = position.distance_to(enemy.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_enemy = enemy
	return closest_enemy


func rotate_to_target(target_angle: float) -> void:
	var shortest_angle = fmod((target_angle - rotation + PI), (2 * PI)) - PI
	if abs(shortest_angle) > 0.01:
		var rotation_direction = shortest_angle / abs(shortest_angle)
		angular_velocity = rotation_direction * torque
	else:
		angular_velocity = 0


func accelerate(slow = false):
	if slow:
		apply_central_impulse(transform.x * -acceleration/5)
		return
	apply_central_impulse(transform.x * acceleration)


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
	wander_angle = fmod(wander_angle, PI * 2)


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


func take_damage(amount):
	if invincible:
		return
	if health - amount <= 0:
		die()
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", Color(5.0, 5.0, 5.0, 5.0), .125)
		health -= amount
		invincible = true
		await get_tree().create_timer(invincible_cooldown).timeout
		var tween2 = get_tree().create_tween()
		tween2.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), .125)
		invincible = false


func die():
	remove_from_group("ship")
	var new_explosion = explosion.instantiate()
	new_explosion.global_position = global_position
	get_tree().get_root().add_child(new_explosion)	
	queue_free()


func _on_invicible_timer_timeout():
	var tween = get_tree().create_tween()
