extends RigidBody2D

@onready var right_spawn = $RightSpawn
@onready var left_spawn = $LeftSpawn
@onready var spawn_timer = $SpawnTimer
@onready var anim = $AnimationPlayer

@export var fighter: PackedScene

var spawn_pool = 6
var spawn_right = true

# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play("engine")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	apply_central_impulse(transform.y * - 1)

func spawn():
	if spawn_pool > 0:
		var new_fighter = fighter.instantiate()
		if spawn_right:
			new_fighter.global_position = right_spawn.global_position
			spawn_right = false
		else:
			new_fighter.global_position = left_spawn.global_position
			spawn_right = true
		owner.add_child(new_fighter)
		spawn_timer.start()
		spawn_pool -= 1
		
func _on_spawn_timer_timeout():
	spawn()


func _on_detection_body_entered(body):
	pass # Replace with function body.


func _on_detection_body_exited(body):
	pass # Replace with function body.
