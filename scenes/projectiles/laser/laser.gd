extends RayCast2D

@onready var beam = $Line2D
@onready var timer = $Timer

var damage = 9999
var is_casting := false
var faction

func _ready():
	beam.points[1] = Vector2.ZERO
	set_physics_process(false)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		set_is_casting(event.pressed) 
		
		
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
