extends CharacterBody3D

@export_group("Movement")
## Character maximum run speed on the ground in meters per second.
@export var move_speed := 11.0
## Ground movement acceleration in meters per second squared.
@export var acceleration := 20.0
## When the player is on the ground and presses the jump button, the vertical
## velocity is set to this value.
@export var jump_impulse := 12.0
## Player model rotation speed in arbitrary units. Controls how fast the
## character skin orients to the movement or camera direction.
@export var rotation_speed := 12.0
## Minimum horizontal speed on the ground. This controls when the character skin's
## animation tree changes between the idle and running states.
@export var stopping_speed := 20.0

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export_range(0.0, 10.0) var pad_sensitivity = 4.0
@export var tilt_upper_limit := PI / 3.0
@export var tilt_lower_limit := -PI / 2.5

## Each frame, we find the height of the ground below the player and store it here.
## The camera uses this to keep a fixed height while the player jumps, for example.
var ground_height := 0.0

var _gravity := -30.0
var _was_on_floor_last_frame := true
var _camera_input_direction := Vector2.ZERO

## The last movement or aim direction input by the player. We use this to orient
## the character model.
@onready var _last_input_direction := global_basis.z
# We store the initial position of the player to reset to it when the player falls off the map.
@onready var _start_position := global_position

@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %Camera3D
@onready var _skin: MeshInstance3D = $Skin
@onready var _landing_sound: AudioStreamPlayer3D = $LandingSound
@onready var _jump_sound: AudioStreamPlayer3D = $JumpSound
@onready var _dust_particles: GPUParticles3D = $DustParticles

var health = 100
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	
	$HitSound.play()
	
	Bus.caterpillar_hit.connect(func on_player_hit(damage) -> void:
		print("Player hit")
		health -= damage
		Bus.player_healthbar_set_value.emit(health)
		$HitAnimation.play("hit")
		if health < 0.0:
			$DeathAnimation.play("death")
	)

func _on_area_3d_body_entered(body):
	if _skin.is_attacking():
		print("hit ", body)
		
		if body.is_in_group("caterpillar"):
			Bus.caterpillar_hit.emit(rng.randf_range(3.0, 10.0))
			$HitSound2.play()
		if body.is_in_group("chrysalis"):
			print("hit chrysalis")
			Bus.chrysalis_hit.emit(rng.randf_range(10.0, 20.0))
			$HitSound2.play()


func _unhandled_input(event: InputEvent) -> void:
	var player_is_using_mouse := (
		event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if player_is_using_mouse:
		_camera_input_direction.x = -event.relative.x * mouse_sensitivity
		_camera_input_direction.y = -event.relative.y * mouse_sensitivity


func _physics_process(delta: float) -> void:
	var look_input := Input.get_vector("look_left", "look_right", "look_up", "look_down", 0.3)
	#print("up:", Input.get_action_strength("look_up"), " down:", Input.get_action_strength("look_down"))
	if look_input.length() != 0.0:
		_camera_input_direction = look_input * pad_sensitivity
	
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, tilt_lower_limit, tilt_upper_limit)
	_camera_pivot.rotation.y += _camera_input_direction.x * delta

	_camera_input_direction = Vector2.ZERO

	# Calculate movement input and align it to the camera's direction.
	var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down", 0.3)
	# Should be projected onto the ground plane.
	var forward := _camera.global_basis.z
	var right := _camera.global_basis.x
	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()

	var is_just_attacked := Input.is_action_just_pressed("attack")
	if is_just_attacked and !_skin.is_attacking():
		print("attack eligible")
		_skin.attack()
	if _skin.is_attacking():
		move_direction = Vector3.ZERO
		#if is_on_floor():
		#	velocity = Vector3.ZERO

	# To not orient the character too abruptly, we filter movement inputs we
	# consider when turning the skin. This also ensures we have a normalized
	# direction for the rotation basis.
	if move_direction.length() > 0.2:
		_last_input_direction = move_direction.normalized()
	var target_angle := Vector3.BACK.signed_angle_to(_last_input_direction, Vector3.UP)
	_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta)

	# We separate out the y velocity to only interpolate the velocity in the
	# ground plane, and not affect the gravity.
	var y_velocity := velocity.y
	velocity.y = 0.0
	velocity = velocity.move_toward(move_direction * move_speed, acceleration * delta)
	if is_equal_approx(move_direction.length_squared(), 0.0) and velocity.length_squared() < stopping_speed:
		velocity = Vector3.ZERO
	velocity.y = y_velocity + _gravity * delta

	# Character animations and visual effects.
	var ground_speed := Vector2(velocity.x, velocity.z).length()
	var is_just_jumping := Input.is_action_just_pressed("jump") and is_on_floor()
	if is_just_jumping:
		velocity.y += jump_impulse
		_skin.jump()
		_jump_sound.play()
	elif not is_on_floor() and velocity.y < 0:
		_skin.fall()
	elif is_on_floor():
		if ground_speed > 0.0:
			_skin.move()
		else:
			_skin.idle()

	#_dust_particles.emitting = is_on_floor() && ground_speed > 0.0

	if is_on_floor() and not _was_on_floor_last_frame:
		_landing_sound.play()

	_was_on_floor_last_frame = is_on_floor()
	move_and_slide()
