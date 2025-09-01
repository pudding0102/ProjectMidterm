extends "res://Scripts/Player/State/State.gd"

func enter():
	ani_player.play("Walk")
	player.particle_trails.emitting = true
	
func update(dealta : float):
	#เปลี่ยนเป็น Idle
	var input_axis = Input.get_axis("Left", "Right")
	if abs(input_axis) == 0 :
		transition_requested.emit("Idle")
		return
		
	#กระโดดเมื่อกดปุ่ม	
	if Input.is_action_pressed("Jump") and player.is_on_floor():
		transition_requested.emit("Jump")
		return
		
	if !player.is_on_floor():
		transition_requested.emit("Jump")
		return
		
	if player.is_on_floor():
		player.step_time += dealta *3
		if player.step_time >= 1:
			player.play_random_step_sound()
			player.step_time = 0
			
			
func exit():
	player.particle_trails.emittimg = false
