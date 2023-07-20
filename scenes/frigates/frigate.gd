extends Ship


# Called when the node enters the scene tree for the first time.
func _ready():
	var tween = get_tree().create_tween()
	tween.tween_property(detection_collision.shape, "radius", 2600.0, 1)

 
func _physics_process(_delta: float) -> void:
	target = find_closest_enemy()
	if target:
		var target_pos = target.global_position
		var distance_to_target = position.distance_to(target_pos)
		
		if distance_to_target <= flee_distance:
			change_state(State.EVADING)
			evade(target_pos)
		elif distance_to_target > flee_distance and distance_to_target <= attack_range:
			change_state(State.ATTACKING)
			flank(target_pos)
			attack()
		else:
			change_state(State.SEEKING)
			move(target_pos)
	else:
		if mothership:
			var target_pos = mothership.global_position
			var distance_to_target = position.distance_to(target_pos)
			change_state(State.MOTHERSHIP)
			orbit_mothership(target_pos, distance_to_target)
		else:
			change_state(State.WANDERING)
			wander()

	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed


func attack():
	if not projectile or not is_instance_valid(target):
		return
	if possible_obstacle and target.z_index != z_index and target.possible_obstacle == true:
		return
	if not attacking and currentState != State.EVADING:
		var proj = projectile.instantiate()
		var predicted_target_position = target.global_position + target.linear_velocity
		var direction = (predicted_target_position - position).normalized()
		proj._target = target
		proj.possible_obstacle = possible_obstacle
		proj.z_index = z_index
		proj.global_transform = Transform2D(atan2(direction.y, direction.x), global_position)
		add_child(proj)
		attacking = true
		attack_timer.start()
