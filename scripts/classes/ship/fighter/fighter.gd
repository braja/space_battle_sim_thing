extends Ship
class_name Fighter

# Called when the node enters the scene tree for the first time.
func _init():
	var random_z_index = randi_range(-1, 1)
	z_index = random_z_index
	wander_angle = randf() * PI * 2


#func _physics_process(_delta: float) -> void:
#	target = find_closest_enemy()
#	if target:
#		var target_pos = target.global_position
#		var distance_to_target = position.distance_to(target_pos)
#
#		if distance_to_target <= flee_distance:
#			change_state(State.EVADING)
#			evade(target_pos)
#		elif distance_to_target > flee_distance and distance_to_target <= attack_range:
#			change_state(State.ATTACKING)
#			flank(target_pos)
#			attack()
#		else:
#			change_state(State.SEEKING)
#			move(target_pos)
#	else:
#		if mothership:
#			var target_pos = mothership.global_position
#			var distance_to_target = position.distance_to(target_pos)
#			change_state(State.MOTHERSHIP)
#			orbit_mothership(target_pos, distance_to_target)
#		else:
#			change_state(State.WANDERING)
#			wander()
func _physics_process(_delta: float) -> void:
	target = find_closest_enemy()
	var my_position = position
	if target:
		var target_pos = target.global_position
		var distance_to_target = my_position.distance_to(target_pos)
		if distance_to_target <= flee_distance:
			change_state(State.EVADING)
			evade(target_pos)
		elif distance_to_target <= attack_range:
			change_state(State.ATTACKING)
			flank(target_pos)
			attack()
		else:
			change_state(State.SEEKING)
			move(target_pos)
	elif mothership:
		var target_pos = mothership.global_position
		change_state(State.MOTHERSHIP)
		orbit_mothership(target_pos, my_position.distance_to(target_pos))
	else:
		change_state(State.WANDERING)
		wander()

	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed

