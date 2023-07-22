extends Node2D


@export var pool_size: int = 200

var fighter_pool = []

func clear_pool():
	fighter_pool.clear()

func request_ship(faction, ship_rotation, location):
	var i = -1
	#print("fighter q: ", fighter_pool.size())
	for fighter in fighter_pool:
		i+= 1
		if fighter.faction == faction:
			var new_fighter = fighter_pool[i]
			new_fighter.global_position = location
			new_fighter.rotation -= ship_rotation
			new_fighter.clickable_area.visible = true
			new_fighter.toggle_physics()
			return fighter_pool.pop_at(i)


func return_to_pool(node):
	fighter_pool.append(node)
