extends Area2D

@onready var _sprite := $Sprite2D
@onready var anim = $AnimationPlayer
@onready var boom_radius = $Boom

@export var explosion : PackedScene

const LAUNCH_SPEED := 800.0

var lifetime := 10.0

var max_speed := 500.0
var drag_factor := 0.55

var _target

var _current_velocity := Vector2.ZERO
var shooter

var possible_obstacle = false
var speed = 550
var damage = 1000


func _ready():
	anim.play("bullet")
	set_as_top_level(true)

	_current_velocity = max_speed * 4 * Vector2.RIGHT.rotated(rotation)

	
func _physics_process(delta: float) -> void:
	var direction := Vector2.RIGHT.rotated(rotation).normalized()
	
	if _target and is_instance_valid(_target):
		direction = global_position.direction_to(_target.global_position)

	var desired_velocity := direction * max_speed
	var previous_velocity = _current_velocity
	var change = (desired_velocity - _current_velocity) * drag_factor
	
	_current_velocity += change
	
	position += _current_velocity * delta
	look_at(global_position + _current_velocity)

	


func boom():
	MainCamera.apply_noise_shake()
	var new_explosion = explosion.instantiate()
	new_explosion.global_position = global_position
	get_tree().get_root().add_child(new_explosion)
	for ship in boom_radius.get_overlapping_bodies():
		ship.take_damage(damage, shooter)
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("fleet_2"):
		return
	if body.is_in_group("fleet_1") || body.is_in_group("fleet_3"):
		if possible_obstacle and body.possible_obstacle and body.z_index != z_index:
			return
		body.take_damage(damage, shooter)
	boom()


func _on_timer_timeout():
	boom()



func set_drag_factor(new_value: float) -> void:
	drag_factor = clamp(new_value, 0.01, 0.5)
