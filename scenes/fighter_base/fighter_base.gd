extends RigidBody2D

@onready var state_label = $StateLabel
@onready var ship_sprite = $Sprite2D
@onready var projectile_spawner = $ProjectileSpawner
@onready var attack_timer = $AttackTimer

@export var faction : String
@export var ship_type : String
@export var projectile : PackedScene

enum State {
	SEEKING,
	ATTACKING,
	EVADING,
	WANDERING
}

var currentState: int = State.SEEKING
var max_speed: float = 150.0
var acceleration: float = 2.0
var target
var flee_distance: float = 200.0
var attack_range: float = 275.0
var torque: float = 3.00

var nearby_enemies : Array = []
var nearby_allies : Array = []

var attacking = false

func _ready():
	add_to_group(faction)
	ship_sprite.texture = load("res://assets/" + faction + "/" + faction + "/Base/PNGs/" + ship_type + ".png")


func _physics_process(_delta: float) -> void:
	target = find_closest_enemy()

	if target:
		var target_pos = target.global_position
		var distance_to_target = position.distance_to(target_pos)
		
		if distance_to_target <= flee_distance:
			change_state(State.EVADING)
			state_label.text = "evading"
			evade(target_pos)  # Pass true for evade
		elif distance_to_target > flee_distance and distance_to_target <= attack_range:
			change_state(State.ATTACKING)
			state_label.text = "attacking"
			move(target_pos)
			attack()
		else:
			change_state(State.SEEKING)
			state_label.text = "seeking"
			move(target_pos)
	else:
		change_state(State.WANDERING)
		state_label.text = "wandering"
		wander()

	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed


func change_state(new_state: int) -> void:
	currentState = new_state


func wander():
	var direction = Vector2(randi_range(-1, 1), randi_range(-1, 1)).normalized()
	var target_angle = atan2(direction.y, direction.x)
	rotate_to_target(target_angle)
	apply_central_impulse(transform.x * acceleration)


func move(target_position: Vector2, evade: bool = false) -> void:
	var direction = (target_position - position).normalized()
	if evade:
		var random_angle = deg_to_rad(randi_range(-90, 90)) # Change this range for more drastic evasion
		direction = Vector2(direction.x * cos(random_angle) - direction.y * sin(random_angle), direction.x * sin(random_angle) + direction.y * cos(random_angle))
	var target_angle = atan2(direction.y, direction.x)
	rotate_to_target(target_angle)
	apply_central_impulse(transform.x * acceleration)


func evade(target_position: Vector2) -> void:
	var direction = (position - target_position).normalized() 
	var random_angle = deg_to_rad(randi_range(-45, 45)) # Random angle for variation in evasion
	direction = Vector2(direction.x * cos(random_angle) - direction.y * sin(random_angle), direction.x * sin(random_angle) + direction.y * cos(random_angle))
	var target_angle = atan2(direction.y, direction.x)
	rotate_to_target(target_angle)
	apply_central_impulse(transform.x * acceleration)



func find_closest_enemy() -> Node2D:
	var closest_distance := 1e9
	var closest_enemy: Node2D = null
	for enemy in nearby_enemies:
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


func attack():
	if not projectile or not is_instance_valid(target):
		return
	if not attacking and currentState != State.EVADING:
		var proj = projectile.instantiate()
		var predicted_target_position = target.global_position + target.linear_velocity
		var direction = (predicted_target_position - position).normalized()
		proj.global_transform = Transform2D(atan2(direction.y, direction.x), projectile_spawner.global_position)
		owner.add_child(proj)
		attacking = true
		attack_timer.start()



func stop_attack():
	attacking = false
	attack_timer.stop()


func _on_detection_body_entered(body):
	if body.is_in_group(faction):
		nearby_allies.append(body)
		return
	if body.is_in_group("fleet_1") || body.is_in_group("fleet_2") || body.is_in_group("fleet_3"):
		if not nearby_enemies.has(body):
			nearby_enemies.append(body)


func _on_detection_body_exited(body):
	if nearby_enemies.has(body):
		nearby_enemies.erase(body)
		if target == body:
			target = null


func _on_attack_timer_timeout():
	attacking = false
	attack()
