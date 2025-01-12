extends Control

@onready var animator: AnimationPlayer = $AnimationPlayer

var _paused: bool = false:
	set(value):
		_paused = value
		if _paused:
			pause()
		else:
			unpause()

func unpause():
	animator.play("Unpause")
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func pause():
	animator.play("Pause")
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _ready():
	if !_paused && Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		_paused = !_paused
	if event.is_action_pressed("ui_select"):
		if !_paused && Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_resume_button_pressed():
	_paused = false

func _on_settings_button_pressed():
	pass

func _on_quit_button_pressed():
	get_tree().quit()
