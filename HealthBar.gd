extends Control

func _ready():
	Bus.enemy_healthbar_set_label.connect(func on_enemy_set_label(value) -> void:
		$EnemyHealthLabel.text = value
	)
	
	Bus.enemy_healthbar_set_value.connect(func on_enemy_set_value(value) -> void:
		value = clamp(value, 0, 100)
		$EnemyHealthBar.value = value
	)

	
	Bus.player_healthbar_set_value.connect(func on_player_set_value(value) -> void:
		value = clamp(value, 0, 100)
		$PlayerHealthBar.value = value
	)
