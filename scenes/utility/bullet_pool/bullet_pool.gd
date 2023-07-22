#class_name BulletHellSpawner
#extends Node2D
#
#@onready var bullet = load("res://scenes/projectiles/fleet_1_bullet/fleet_1_bullet.tscn")
#@onready var shared_area = $SharedArea
#var max_lifetime = 1.0
#
#var frame = load("res://assets/radar/white4x4.png")
#var space
#var bullets : Array = []
#var bounding_box : Rect2
#var pool_size = 2000
#
## ================================ Lifecycle ================================ #
#
##func _ready():
#	#space = PhysicsServer2D.space_create()
#	#shared_area = PhysicsServer2D.area_create()
#	#PhysicsServer2D.area_set_space(shared_area, space)
##	for i in range(pool_size):
##		var projectile = bullet.instantiate()
##		projectile.hide()
##		projectile.set_physics_process(false)
##		projectile.set_process(false)
##		bullets.append(projectile)
##		add_child(projectile)
##		#projectile.collision.disabled = true
##		_configure_collision_for_bullet(projectile)
#
#
#func _exit_tree() -> void:
#	for bullet in bullets:
#		PhysicsServer2D.free_rid((bullet).shape_id)
#	bullets.clear()
#
#func _physics_process(delta: float) -> void:
#
#	var used_transform = Transform2D()
#	var bullets_queued_for_destruction = []
#
#	for i in range(0, bullets.size()):
#
#		var bullet = bullets[i] as Bullet
#
#		if (
#			!bounding_box.has_point(bullet.current_position) or
#			bullet.lifetime >= max_lifetime
#		):
#			bullets_queued_for_destruction.append(bullet)
#			continue
#
#		var offset : Vector2 = (
#			bullet.movement_vector.normalized() * bullet.speed * delta
#		)
#
#		# Move the bullet and the collision
#		bullet.current_position += offset
#		used_transform.origin = bullet.current_position
#		PhysicsServer2D.area_set_shape_transform(
#			shared_area, i, used_transform
#		)
#
#		bullet.animation_lifetime += delta
#		bullet.lifetime += delta
#
#	for bullet in bullets_queued_for_destruction:
#		PhysicsServer2D.free_rid(bullet.shape_id)
#		bullets.erase(bullet)
#
#	queue_redraw()
#
#
#
#func _draw() -> void:
#	for i in range(0, bullets.size()):
#		var bullet = bullets[i]
#
#		draw_texture(
#			frame, 
#			bullet.current_position
#		)
#
## ================================= Public ================================== #
#
## Bullets outside these bounds will be deleted
#func set_bounding_box(box: Rect2) -> void:
#	bounding_box = box
#
#
## Register a new bullet in the array with the optimization logic
#func spawn_bullet(faction, origin, i_movement: Vector2, speed := 600) -> void:
#	var bullet : Bullet = Bullet.new()
#	bullet.faction = faction
#	bullet.damage = 75
#	bullet.movement_vector = i_movement
#	bullet.speed = speed
#	bullet.current_position = origin
#
#	_configure_collision_for_bullet(bullet)
#
#	bullets.append(bullet)
#
#
## Adds the collision data to the bullet
#func _configure_collision_for_bullet(bullet: Bullet) -> void:
#
#	# Define the shape's position
#	var used_transform := Transform2D(0, position)
#	used_transform.origin = bullet.current_position
#
#	# Create the shape
#	var _circle_shape = PhysicsServer2D.circle_shape_create()
#	PhysicsServer2D.shape_set_data(_circle_shape, 2)
#
#	# Add the shape to the shared area
#	PhysicsServer2D.area_add_shape(
#		shared_area, _circle_shape, used_transform
#	)
#
#	# Register the generated id to the bullet
#	PhysicsServer2D.area_set_monitorable(shared_area, true) 
#	bullet.shape_id = _circle_shape

extends Node2D

@onready var bullet = load("res://scenes/projectiles/fleet_1_bullet/fleet_1_bullet.tscn")
@export var pool_size: int = 1500

var bullet_pool = []
## Called when the node enters the scene tree for the first time.
func _ready():
	clear_pool()
	for i in range(pool_size):
		var projectile = bullet.instantiate()
		#projectile.toggle_physics()
		bullet_pool.append(projectile)
		add_child(projectile)



func request_bullet():
	var new_bullet = bullet_pool.pop_front()
	return new_bullet


func return_to_pool(node):
	bullet_pool.append(node)

func clear_pool():
	bullet_pool.clear()
