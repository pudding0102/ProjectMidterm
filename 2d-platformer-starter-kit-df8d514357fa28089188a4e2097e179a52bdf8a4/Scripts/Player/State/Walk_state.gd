extends State

func enter():
	player.player_spirte.play("Walk")

func physics_update(delta):
	#gravity และ movement
	player.movement(delta)
	player.handle_jumping()
	
	#Step sound
	if player.is_on_floor():
		player.step_time += delta * 3
		if player.step_time >= 1:
			player.play_random_step_sound()
			player.step_time = 0
			
	#เปลี่ยน state
	var input_axis = Input.get_axis("Left", "Right")
	if abs(input_axis) == 0:
		change_state.emit("Idle")
	
	if !player.is_on_floor():
		change_state.emit("Jump")
