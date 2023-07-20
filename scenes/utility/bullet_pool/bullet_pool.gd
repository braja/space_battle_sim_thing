extends Node2D

@onready var bullet = load("res://scenes/projectiles/fleet_1_bullet/fleet_1_bullet.tscn")

@export var pool_size: int = 1500

var bullet_pool = []
# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(pool_size):
		var projectile = bullet.instantiate()
		projectile.hide()
		projectile.set_physics_process(false)
		projectile.set_process(false)
		bullet_pool.append(projectile)
		add_child(projectile)


func request_bullet():
	return bullet_pool.pop_front()


func return_to_pool(node):
	bullet_pool.append(node)
