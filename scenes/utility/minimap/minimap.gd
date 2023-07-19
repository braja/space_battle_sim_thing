extends CanvasItem

@onready var viewport = $SubViewport
@onready var clear_blip_timer = $ClearBlipTimer

@export var green_radar_pixel : PackedScene

var ship_list = []
var circle_pos = Vector2.ZERO
var max_radar_display = 250

var available_green_dots = []
# Called when the node enters the scene tree for the first time.
func _ready():
	for i in max_radar_display:
		var new_blip = green_radar_pixel.instantiate()
		new_blip.visible = false
		viewport.add_child(new_blip)
		max_radar_display -= 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _receive_update(pos):
	if viewport != null:
		for blip in viewport.get_children():
			if not blip.visible:
				blip.position = pos / 15
				blip.visible = true
				return



func _on_timer_timeout():
	pass
#	for blip in viewport.get_children():
#		blip.visible = false
#	clear_blip_timer.start()
	
