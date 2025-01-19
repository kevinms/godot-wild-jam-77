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
	Bus.game_complete.connect(func on_complete() -> void:
		print("boss defeated")
		Bus.game_over = true
		$CenterContainer/PanelContainer/MarginContainer/GridContainer/Label.text = "Boss Defeated!"
		pause()
	)
	Bus.game_you_died.connect(func on_died() -> void:
		print("you died")
		Bus.game_over = true
		$CenterContainer/PanelContainer/MarginContainer/GridContainer/Label.text = "You Died"
		pause()
	)

func _on_restart_button_pressed():
	get_tree().change_scene_to_file("res://main.tscn")

func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
