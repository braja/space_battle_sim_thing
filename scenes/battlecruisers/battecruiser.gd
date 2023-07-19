extends Ship
class_name Battlecruiser

@onready var right_spawn = $RightSpawn
@onready var left_spawn = $LeftSpawn
@onready var spawn_timer = $SpawnTimer
@onready var anim = $AnimationPlayer
@onready var minimap_update_timer = $UpdateMinimapPosition

@export var fighter: PackedScene

var spawn_pool = 8
var spawn_right = true

# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play("engine")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	apply_central_impulse(transform.y * - 1)


func spawn():
	if get_tree().get_nodes_in_group("ship").size() < 48:
		for i in spawn_pool:
			var new_fighter = fighter.instantiate()
			if spawn_right:
				new_fighter.global_position = right_spawn.global_position
				spawn_right = false
			else:
				new_fighter.global_position = left_spawn.global_position
				spawn_right = true
			owner.add_child(new_fighter)
	spawn_timer.start()


func take_damage(amount):
	pass


func _on_spawn_timer_timeout():
	spawn()


func _on_detection_body_entered(body):
	pass # Replace with function body.


func _on_detection_body_exited(body):
	pass # Replace with function body.


func _on_update_minimap_position_timeout():
	pass
