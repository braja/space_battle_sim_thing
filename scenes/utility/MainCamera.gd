extends Camera2D

signal zoom_changed

@export var zoom_speed: float = 0.01
@export var pan_speed: float = 500.0
@export var max_zoom: float = 4.0
@export var min_zoom: float = 0.25

# How quickly to move through the noise
@export var NOISE_SHAKE_SPEED: float = 30.0
# Noise returns values in the range (-1, 1)
# So this is how much to multiply the returned value by
@export var NOISE_SHAKE_STRENGTH: float = 60.0
# Multiplier for lerping the shake strength to zero
@export var SHAKE_DECAY_RATE: float = 5.0

@onready var rand = RandomNumberGenerator.new()
@onready var noise = FastNoiseLite.new()

# Used to keep track of where we are in the noise
# so that we can smoothly move through it
var noise_i: float = 0.0

var shake_strength: float = 0.0

var origin = Vector2(572, 311)

func _ready() -> void:
	zoom = Vector2(.25, .25)
	rand.randomize()
	# Randomize the generated noise
	noise.seed = rand.randi()
	# Period affects how quickly the noise changes values
	#noise.period = 2


func apply_noise_shake() -> void:
	shake_strength = NOISE_SHAKE_STRENGTH


func _process(delta: float) -> void:
	# Fade out the intensity over time
	shake_strength = lerp(shake_strength, 0.0001, SHAKE_DECAY_RATE * delta)

	# Shake by adjusting camera.offset so we can move the camera around the level via it's position
	self.offset = get_noise_offset(delta)


func get_noise_offset(delta: float) -> Vector2:
	noise_i += delta * NOISE_SHAKE_SPEED
	# Set the x values of each call to 'get_noise_2d' to a different value
	# so that our x and y vectors will be reading from unrelated areas of noise
	return Vector2(
		noise.get_noise_2d(1, noise_i) * shake_strength,
		noise.get_noise_2d(100, noise_i) * shake_strength
	)


func _physics_process(delta):
	var direction = Vector2.ZERO

	if Input.is_action_pressed("ui_left"):
		direction.x -= 5
	if Input.is_action_pressed("ui_right"):
		direction.x += 5
	if Input.is_action_pressed("ui_up"):
		direction.y -= 5
	if Input.is_action_pressed("ui_down"):
		direction.y += 5
	if Input.is_action_pressed("reset_camera"):
		position = origin
		return
		
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
		emit_signal("zoom_changed", zoom)
