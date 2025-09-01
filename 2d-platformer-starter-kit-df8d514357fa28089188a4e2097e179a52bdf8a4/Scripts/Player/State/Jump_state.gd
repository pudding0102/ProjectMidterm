extends "res://Scripts/Player/State/State.gd"

func enter():
	ani_player.play("Jump")
	ani_player.speed_scale = 1.0
	player.jump()
	player.jump_tween()
	
func update(delta : float):
	if Input.is_action_just_released("Jump") and player.velocity.y < -200:
		player.velocity.y = -200
	
	if player.double_jump and Input.is_action_pressed("Jump") and player.jump_count > 0:
		player.jump()
		player.jump_count = -1
		$jump.play()
		
	if player.is_on_floor():
		player.jump_count = player.max_jump_count
		var input_axis = Input.get_axis("Left", "Right")
		if abs(input_axis) > 0:
			transition_requested.emit("walk")	
		else:
			transition_requested.emit("Idle")
			
func exit():
	pass
