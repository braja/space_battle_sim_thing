extends Node2D

@export var level : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("reset"):
		handle_reset()


func handle_reset():
	var old_level = get_node("World")
	old_level.name = "old_level"
	old_level.call_deferred("queue_free")
	var new_level = level.instantiate()
	add_child(new_level)
	new_level.name = "World"
