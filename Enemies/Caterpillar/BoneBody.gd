extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _physics_process(delta):
	
	var p = $"..".get_bone_pose_position(0)
	
	#transform.basis = p
