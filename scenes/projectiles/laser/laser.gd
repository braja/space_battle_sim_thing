extends RayCast2D

@onready var beam = $Line2D
@onready var timer = $Timer

@export var color: Color
@export var beam_width: int
@export var damage = 9999
var is_casting := false
var faction
var _target

func _ready():
	beam.points[1] = Vector2.ZERO
	beam.width = beam_width
	beam.default_color = color
	print(color, beam.default_color)
	set_physics_process(false)

		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var cast_point = target_position
	force_raycast_update()
	
	if is_colliding():
		cast_point = to_local(get_collision_point())
		var body = get_collider()
		if body.has_method("take_damage"):
			if body.friendly(faction):
				return
			body.take_damage(damage)
	
	beam.points[1] = cast_point


func set_is_casting(cast):
	#z_index = _target.z_index
	is_casting = cast
	timer.start()
	if is_casting:
		appear()
	else:
		dissapear()
		
	set_physics_process(is_casting)

func appear():
	#visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(beam, "width", 28.0, .2)

func dissapear():
	var tween = get_tree().create_tween()
	tween.tween_property(beam, "width", 0.0, .2)
	#visible = false


func _on_timer_timeout():
	set_is_casting(false)
