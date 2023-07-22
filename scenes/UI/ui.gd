extends CanvasLayer

@onready var tooltip = $Tooltip
@onready var health = $Tooltip/VBoxContainer/Health
@onready var ship_type = $Tooltip/VBoxContainer/Type
@onready var ship_state = $Tooltip/VBoxContainer/State
@onready var faction = $Tooltip/VBoxContainer/Faction

@onready var pilot_info_small = $PilotInfoSmall


func show_tooltip(info):
	ship_type.text = "Type: " + info.ship_type
	health.text = "Health: " + str(info.health)
	faction.text = "Faction: " + info.faction
	var state = info.currentState
	ship_state.text = info.State.find_key(state)
	tooltip.show()

func hide_tooltip():
	tooltip.hide()


func show_pilot_info_small():
	pilot_info_small.show()

func hide_pilot_info_small():
	pilot_info_small.hide()

func _on_close_pressed():
	pilot_info_small.hide()
