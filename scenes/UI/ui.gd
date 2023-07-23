extends CanvasLayer

@onready var tooltip = $Tooltip
@onready var health = $Tooltip/VBoxContainer/Health
@onready var ship_type = $Tooltip/VBoxContainer/Type
@onready var ship_state = $Tooltip/VBoxContainer/State
@onready var faction = $Tooltip/VBoxContainer/Faction
@onready var kills = $PilotInfoSmall/HBoxContainer/VBoxContainer2/HBoxContainer3/Kills

@onready var pilot_info_small = $PilotInfoSmall
@onready var pilot_info_hover = $PilotInfoSmall/PilotInfoHover


func show_tooltip(info):
	ship_type.text = "Type: " + info.ship_type
	health.text = "Health: " + str(info.health)
	faction.text = "Faction: " + info.faction
	kills.text = "Kills: " + str(info.kill_count)
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


func _pilot_info_hover_hide():
	pilot_info_hover.hide()


func _on_name_mouse_entered():
	pilot_info_hover.text = "Pilot's name."
	pilot_info_hover.show()
	print("stuff")


func _on_ship_name_mouse_entered():
	pilot_info_hover.text = "Ship's name."
	pilot_info_hover.show()
	print("stuff")


func _on_traits_mouse_entered():
	pilot_info_hover.text = "Pilot's special traits; these grant bonuses"
	pilot_info_hover.show()

func _on_length_of_service_mouse_entered():
	pilot_info_hover.text = "How long this pilot has been in service"
	pilot_info_hover.show()

func _on_rank_mouse_entered():
	pilot_info_hover.text = "Pilot's military rank"
	pilot_info_hover.show()

func _on_kills_mouse_entered():
	pilot_info_hover.text = "Pilot's career kill count"
	pilot_info_hover.show()

func _on_exp_mouse_entered():
	pilot_info_hover.text = "Pilot's current experience points"
	pilot_info_hover.show()
