extends Area2D

@onready var anim = $AnimationPlayer
var possible_obstacle = false
var speed = 550
# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play("bullet")


func _physics_process(delta):
	position += transform.x * speed * delta



func _on_body_entered(body):
	if body.is_in_group("fleet_1") || body.is_in_group("fleet_3"):
		if possible_obstacle and body.possible_obstacle and body.z_index != z_index:
			return
		body.queue_free()
	queue_free()
