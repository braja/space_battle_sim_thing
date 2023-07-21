extends Ship
class_name Battlecruiser

@onready var right_spawn = $battlecruiser_module/RightSpawn
@onready var left_spawn = $battlecruiser_module/LeftSpawn
@onready var spawn_timer = $battlecruiser_module/SpawnTimer

var fighter

var spawner
var spawn_pool = 8
var spawn_right = true



# Called when the node enters the scene tree for the first time.
func _ready():
	print("battlecruiser intialized")
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()
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


func take_damage(amount):
	pass


func _on_spawn_timer_timeout():
	spawn()
