extends Area2D

@onready var anim = $AnimationPlayer
@onready var timer = $Timer
var possible_obstacle = false
var speed = 550
var damage = 125
var faction

# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play("bullet")

func add_to_pool():
	visible = false
	set_physics_process(false)
	set_process(false)
	BulletPool.return_to_pool(self)


func _physics_process(delta):
	position += transform.x * speed * delta


func _on_body_entered(body):
	if body.has_method("take_damage"):
		if body.friendly(faction):
			return
		if possible_obstacle and body.possible_obstacle and body.z_index != z_index:
			return
		body.take_damage(damage)
		add_to_pool()


func _on_timer_timeout():
	add_to_pool()
