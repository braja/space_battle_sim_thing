extends CanvasLayer

@onready var tooltip = $Icon

func show_tooltip(info):
	print(info.ship_type)
	tooltip.show()

func hide_tooltip():
	tooltip.hide()
