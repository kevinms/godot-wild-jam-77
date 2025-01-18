extends CharacterBody3D

const SPEED = 3.0
const JUMP_VELOCITY = 4.5

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY

	#var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	#var input_dir = (player.global_position - global_position).normalized()
	
	
	var player: CharacterBody3D = get_tree().get_nodes_in_group("player")[0]
	var direction = (to_local(player.global_position) - position).normalized()
	
	#position.angle_to_point(player.global_position) - deg2rad(90)
	#rotation = lerp_angle(rotation, position.angle_to_point(player.global_position) - deg2rad(90), 0.1)
	
	#var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	#else:
	#velocity.x = move_toward(velocity.x, 0, SPEED)
	#velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
