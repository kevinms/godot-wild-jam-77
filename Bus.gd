extends Node

signal caterpillar_hit(damage)
signal chrysalis_hit(damage)

signal enemy_healthbar_set_label(name)
signal enemy_healthbar_set_value(value)

signal player_healthbar_set_label(name)
signal player_healthbar_set_value(value)

var game_over: bool = false


signal game_complete()
signal game_you_died()
