extends ParallaxBackground

var base_scale = Vector2(1, 1)
var base_mirror = Vector2(2049, 2049)

@onready var layer1 = $ParallaxLayer
@onready var layer2 = $ParallaxLayer2
@onready var layer3 = $ParallaxLayer3

@onready var layers = [layer1, layer2, layer3]
# Called every frame. 'delta' is the elapsed time since the previous frame.
