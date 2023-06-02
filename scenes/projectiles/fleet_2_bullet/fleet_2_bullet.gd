extends Area2D

@onready var anim = $AnimationPlayer

var speed = 550
# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play("bullet")


func _physics_process(delta):
	position += transform.x * speed * delta



func _on_body_entered(body):
	if body.is_in_group("fleet_1") || body.is_in_group("fleet_3"):
		body.queue_free()
	queue_free()
