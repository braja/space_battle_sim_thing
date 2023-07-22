extends Node2D

@onready var BulletPool = $World/BulletPool
@onready var world = $World


@export var level : PackedScene

signal move_camera

var is_paused = false
var boundary_rect: Rect2

#func _ready() -> void:
	# Here we register the boundary
#	boundary_rect = Rect2(
#		get_node("TopLeft").position,
#		get_node("BottomRight").position - get_node("TopLeft").position
#	)
#	BulletPool.set_bounding_box(boundary_rect)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#camera.offset = camera.get_noise_offset(delta)
	if Input.is_action_just_pressed("pause"):
		is_paused = !is_paused
		#camera.set_physics_process_internal(t)
		get_tree().paused = is_paused
	if Input.is_action_just_pressed("reset"):
		handle_reset()
	var direction = Vector2.ZERO


func handle_reset():
	var old_level = get_node("World")
	old_level.name = "old_level"
	old_level.call_deferred("queue_free")
	var new_level = level.instantiate()
	add_child(new_level)
	new_level.name = "World"
	world = new_level
