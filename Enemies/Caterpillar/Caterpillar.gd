extends Node3D

var actions = ["Idle","Test", "Strike", "Wiggle"]

func _ready():
	$Armature/Skeleton3D/SkeletonIK3D.start()
	$AnimationPlayer.play(actions.pick_random())

func _process(delta):
	pass



func _on_animation_player_animation_finished(anim_name):
	$Timer.start()


func _on_timer_timeout():
	var which = actions.pick_random()
	print("picked ", which)
	
	$AnimationPlayer.play(which)
