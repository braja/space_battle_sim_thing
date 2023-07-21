extends Area2D
@onready var BulletPool = get_tree().get_first_node_in_group("bullet_pool")
@onready var shape = $CollisionShape2D
@onready var timer = $Timer
#@onready var collision = $CollisionShape2D
var possible_obstacle = false
var speed = 550
var damage = 125
var faction


func toggle_physics():
	visible = !visible
	monitoring = !monitoring
	$CollisionShape2D.disabled = !$CollisionShape2D.disabled
	set_physics_process(!is_physics_processing())
	set_process(!is_processing())
	
func is_bullet():
	return true


func add_to_pool():
	toggle_physics()
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
		call_deferred("add_to_pool")


func _on_timer_timeout():
	call_deferred("add_to_pool")
