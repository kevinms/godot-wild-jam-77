extends RigidBody3D


var health = 100

func _ready():
	Bus.enemy_healthbar_set_label.emit("Chrysalis")
	Bus.enemy_healthbar_set_value.emit(100)
	
	Bus.chrysalis_hit.connect(func on_chrysalis_hit(damage) -> void:
		print("Received hit")
		health -= damage
		Bus.enemy_healthbar_set_value.emit(health)
		$HitAnimation.play("hit")
		if health < 0.0:
			$DeathAnimation.play("death")
	)

func _on_death_animation_animation_finished(anim_name):
	queue_free()
	Bus.game_complete.emit()
