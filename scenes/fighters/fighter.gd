extends RigidBody2D

@onready var state_label = $StateLabel
@onready var sprite = $Sprite2D
@onready var engine = $Engine
@onready var weapon = $Weapon
@onready var anim = $AnimationPlayer
@onready var projectile_spawner = $ProjectileSpawner
@onready var attack_timer = $AttackTimer
@onready var invicible_timer = $InvicibleTimer
@onready var my_faction = self.get_groups()[0]
@onready var detection_area = $Detection
@onready var detection_collision = $Detection/CollisionShape2D

@export var projectile : PackedScene
@export var explosion : PackedScene
@export var health: int
@export var max_speed: float
@export var acceleration: float
@export var flee_distance: float
@export var attack_range: float
@export var torque: float

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
	engine.visible = false
	weapon.visible = false
	anim.play("engine")
	var tween = get_tree().create_tween()
	tween.tween_property(detection_collision.shape, "radius", 2600.0, 1)
	var random_z_index = randi_range(-1, 1)
	z_index = random_z_index
	wander_angle = randf() * PI * 2


func _physics_process(_delta: float) -> void:
	target = find_closest_enemy()
	if target:
		var target_pos = target.global_position
		var distance_to_target = position.distance_to(target_pos)
		
		if distance_to_target <= flee_distance:
			change_state(State.EVADING)
			state_label.text = "evading"
			evade(target_pos)
		elif distance_to_target > flee_distance and distance_to_target <= attack_range:
			change_state(State.ATTACKING)
			state_label.text = "attacking"
			flank(target_pos)
			attack()
		else:
			change_state(State.SEEKING)
			state_label.text = "seeking"
			move(target_pos)
	else:
		if mothership:
			var target_pos = mothership.global_position
			var distance_to_target = position.distance_to(target_pos)
			change_state(State.MOTHERSHIP)
			state_label.text = "mothership"
			orbit_mothership(target_pos, distance_to_target)
		else:
			change_state(State.WANDERING)
			state_label.text = "wandering"
			wander()

	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed


func change_state(new_state: int) -> void:
	currentState = new_state


func accelerate(slow = false):
	if slow:
		apply_central_impulse(transform.x * -acceleration/5)
		return
		
	apply_central_impulse(transform.x * acceleration)
	if linear_velocity.length() < 150: 
		engine.visible = false
		return
	engine.visible = true
	


func orbit_mothership(target_position: Vector2, distance):
	var direction = (target_position - position).normalized()
	var target_angle = atan2(direction.y, direction.x)
	rotate_to_target(target_angle)
	if distance > orbit_distance:
		accelerate()
	else:
		accelerate(true)



func wander():
	var direction = Vector2(cos(wander_angle), sin(wander_angle))
	var target_angle = atan2(direction.y, direction.x)
	rotate_to_target(target_angle)
	accelerate()

	# Randomly adjust the wander_angle by up to wander_range degrees per second
	wander_angle += deg_to_rad(randf_range(-wander_range, wander_range) * get_process_delta_time())

	# Keep wander_angle within the range of 0 to 2*PI
	wander_angle = fmod(wander_angle, PI * 2)


func move(target_position: Vector2) -> void:
	var direction = (target_position - position).normalized()
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


func evade(target_position: Vector2) -> void:
	var direction = (position - target_position).normalized() 
	var random_angle = deg_to_rad(randi_range(-45, 45)) # Random angle for variation in evasion
	direction = Vector2(direction.x * cos(random_angle) - direction.y * sin(random_angle), direction.x * sin(random_angle) + direction.y * cos(random_angle))
	var target_angle = atan2(direction.y, direction.x)
	rotate_to_target(target_angle)
	accelerate()



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
	if possible_obstacle and target.z_index != z_index and target.possible_obstacle == true:
		return
	if not attacking and currentState != State.EVADING:
		#weapon.visible = true
		#anim.play("weapon")
		var proj = projectile.instantiate()
		var predicted_target_position = target.global_position + target.linear_velocity
		var direction = (predicted_target_position - position).normalized()
		proj.possible_obstacle = possible_obstacle
		proj.z_index = z_index
		proj.global_transform = Transform2D(atan2(direction.y, direction.x), projectile_spawner.global_position)
		get_tree().get_root().add_child(proj)
		attacking = true
		attack_timer.start()



func stop_attack():
	attacking = false
	attack_timer.stop()


func _on_detection_body_entered(body):
	if body.is_in_group("mothership"):
		mothership = body
	if body.get_groups().any(is_enemy_faction):
		if not nearby_enemies.has(body):
			nearby_enemies.append(body)


func _on_detection_body_exited(body):
	if nearby_enemies.has(body):
		nearby_enemies.erase(body)
		if target == body:
			target = null


func is_enemy_faction(group):
	if factions.has(group):
		return group != my_faction


func _on_attack_timer_timeout():
	attacking = false
	weapon.visible = false
	attack()


func _on_los_area_entered(area):
	if area.is_in_group("line_of_sight"):
		possible_obstacle = true


func _on_los_area_exited(area):
	if area.is_in_group("line_of_sight"):
		possible_obstacle = false


func take_damage(amount):
	if invincible:
		return
	if health - amount <= 0:
		die()
	else:
		invicible_timer.start()
		var tween = get_tree().create_tween()
		tween.tween_property(sprite, "modulate", Color(5.0, 5.0, 5.0, 5.0), .125)
		health -= amount
		invincible = true		


func _on_invicible_timer_timeout():
	invincible = false
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), .125)


func _on_crash(body):
	if body.is_in_group("ship"):
		if abs(linear_velocity.x + body.linear_velocity.x) >= 275 or abs(linear_velocity.y + body.linear_velocity.y) >= 275:
			die()


func die():
	var new_explosion = explosion.instantiate()
	new_explosion.global_position = global_position
	get_tree().get_root().add_child(new_explosion)	
	queue_free()
