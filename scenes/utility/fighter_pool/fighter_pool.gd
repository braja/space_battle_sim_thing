extends Node2D


@export var pool_size: int = 100

var fighter_pool = []


func request_ship(faction, location):
	var i = -1
	for fighter in fighter_pool:
		i+= 1
		if fighter.faction == faction:
			var new_fighter = fighter_pool[i]
			new_fighter.global_position = location
			new_fighter.visible = true
			new_fighter.set_process(true)
			new_fighter.set_physics_process(true)
			new_fighter.collision.disabled = false
			return fighter_pool.pop_at(i)


func return_to_pool(node):
	fighter_pool.append(node)
