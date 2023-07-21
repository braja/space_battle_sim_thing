extends Node2D


@export var pool_size: int = 200

var fighter_pool = []


func request_ship(faction, location):
	var i = -1
	#print("fighter q: ", fighter_pool.size())
	for fighter in fighter_pool:
		i+= 1
		if fighter.faction == faction:
			var new_fighter = fighter_pool[i]
			new_fighter.global_position = location
			new_fighter.toggle_physics()
			return fighter_pool.pop_at(i)


func return_to_pool(node):
	fighter_pool.append(node)
