extends CharacterBody3D

var health = 100

const SPEED = 3.0
const JUMP_VELOCITY = 4.5

var chrysalisScene = preload("res://Enemies/Chrysalis/ChrysalisController.tscn")

func _ready():
	Bus.enemy_healthbar_set_label.emit("Caterpillar")
	Bus.enemy_healthbar_set_value.emit(100)
	
	Bus.caterpillar_hit.connect(func on_caterpillar_hit(damage) -> void:
		print("Received hit")
		health -= damage
		Bus.enemy_healthbar_set_value.emit(health)
		$HitAnimation.play("hit")
		if health < 0.0:
			$DeathAnimation.play("death")
	)
	
	#$DeathAnimation.connect("animation_finished")
	
func _on_death_animation_animation_finished(anim_name):
	queue_free()
	
	var chrysalis = chrysalisScene.instantiate()
	get_parent().add_child(chrysalis)
	chrysalis.global_position = global_position


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
