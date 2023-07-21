extends Ship
class_name Battlecruiser

@onready var right_spawn = $battlecruiser_module/RightSpawn
@onready var left_spawn = $battlecruiser_module/LeftSpawn
@onready var spawn_timer = $battlecruiser_module/SpawnTimer

var fighter

var spawner
var spawn_pool = 8
var spawn_right = true
var laser


# Called when the node enters the scene tree for the first time.
func _ready():
	print("battlecruiser intialized")
	attack_timer.wait_time = attack_cooldown
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()
	laser = projectile.instantiate()
	laser.faction = faction
	add_child(laser)
	var tween = get_tree().create_tween()
	tween.tween_property(detection_collision.shape, "radius", 2600.0, 1)
	#anim.play("engine")


func _physics_process(_delta: float) -> void:
	target = find_closest_enemy()
	if target:
		var target_pos = target.global_position
		var distance_to_target = position.distance_to(target_pos)

		if distance_to_target <= attack_range:
			change_state(State.ATTACKING)
			flank(target_pos)
			attack()
		else:
			change_state(State.SEEKING)
			move(target_pos)
	else:
		change_state(State.WANDERING)
		wander()


func spawn():
	#if get_tree().get_nodes_in_group("ship").size() < 128:
	var n = Vector2.ZERO
	for i in spawn_pool:
		if spawn_right:
			FighterPool.request_ship(faction, right_spawn.global_position + (n * 3))
			spawn_right = false
		else:
			FighterPool.request_ship(faction, left_spawn.global_position + (n * 3))
			spawn_right = true
		n += Vector2(1, 1)
	spawn_timer.start()


func attack():
	if not projectile or not is_instance_valid(target):
		return
	if possible_obstacle and target.z_index != z_index and target.possible_obstacle == true:
		return
	if not attacking and currentState != State.EVADING:
		laser.set_is_casting(true)
		attacking = true
		attack_timer.start()



func take_damage(amount):
	pass


func _on_spawn_timer_timeout():
	spawn()
