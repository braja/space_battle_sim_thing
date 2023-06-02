extends Camera2D

@export var zoom_speed: float = 0.07
@export var pan_speed: float = 500.0
@export var max_zoom: float = 3.0
@export var min_zoom: float = 0.25

func _physics_process(delta):
	var direction = Vector2.ZERO

	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1

	position += direction.normalized() * pan_speed * delta

func _input(event):
	if event is InputEventMouseButton:
		var old_zoom = zoom
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and zoom.x > min_zoom and zoom.y > min_zoom:
			zoom -= Vector2.ONE * zoom_speed
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and zoom.x < max_zoom and zoom.y < max_zoom:
			zoom += Vector2.ONE * zoom_speed

		# get the mouse position in the world
		var mouse_pos = get_global_mouse_position()

		# calculate the difference in zoom
		var zoom_diff = old_zoom - zoom

		# move the camera
		global_position += (global_position - mouse_pos) * zoom_diff

		# clamp zoom levels
		zoom.x = clamp(zoom.x, min_zoom, max_zoom)
		zoom.y = clamp(zoom.y, min_zoom, max_zoom)
