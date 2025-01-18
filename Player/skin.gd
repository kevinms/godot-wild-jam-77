extends MeshInstance3D

const ATTACK_SPEED = 1.3

enum Attack {SWING, RESET, NONE}

var attack_state: Attack = Attack.NONE

func fall():
	pass

func move():
	pass

func idle():
	pass

func jump():
	pass

func attack():
	attack_state = Attack.SWING
	$character/AnimationPlayer.play("Attack", -1, ATTACK_SPEED, false)

func is_attacking() -> bool:
	return attack_state != Attack.NONE

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Attack":
		if attack_state == Attack.SWING:
			attack_state = Attack.RESET
			$character/AnimationPlayer.play("Attack", -1, -ATTACK_SPEED, true)
		if attack_state == Attack.RESET:
			attack_state = Attack.NONE
