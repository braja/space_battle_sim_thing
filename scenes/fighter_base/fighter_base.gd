extends CharacterBody2D

@onready var ship_sprite = $Ship

@export var speed : int = 100  # move speed in pixels/sec
@export var engagement_range : int = 250
var rotation_speed = 1.5  # turning speed in radians/sec
@export var faction : String
@export var ship_type : String

var escape_distance = 75
var is_escaping = false
var escape_start_pos = Vector2.ZERO

var nearby_enemies = []

var target = null
#\assets\FLEET_#\FLEET_#\Destruction\PNGs\SHIP_TYPE.png
func _ready():
	add_to_group(faction)
	match faction:
		"fleet_1":
			engagement_range = 250
		"fleet_2":
			engagement_range = 300
		"fleet_3":
			engagement_range = 75
	ship_sprite.texture = load("res://assets/" + faction + "/" + faction + "/Destruction/PNGs/" + ship_type + ".png")


func _physics_process(delta):
	if is_escaping:
		handle_escape(delta)
	if target:
		look_at(target.global_position)
		if position.distance_to(target.global_position) > engagement_range:
			position = position.move_toward(target.global_position, speed * delta)
		else:
			rotation += randf_range(-rotation_speed, rotation_speed)
			position = position.move_toward(-target.global_position, speed * delta)
	else:
		find_target()

	move_and_slide()

func _on_detection_body_entered(body):
	if body.is_in_group(faction):
		return
	if body.is_in_group("fleet_1") || body.is_in_group("fleet_2") || body.is_in_group("fleet_3"):
		if not nearby_enemies.has(body):
			nearby_enemies.append(body)
	print(nearby_enemies)

func _on_detection_body_exited(body):
	if nearby_enemies.has(body):
		nearby_enemies.erase(body)


func find_target():
	target = nearby_enemies.pop_front()


func handle_escape(delta):
	var distance = position.distance_to(target.global_position)
	if distance > escape_distance:
		velocity = -get_transform().x * speed  # Move perpendicular to the direction to the target.
	else:
		is_escaping = false
		if randf() > 0.5:
			rotation += PI / 2
		else:
			rotation -= PI / 2

	
