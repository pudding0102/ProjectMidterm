extends "res://Scripts/Player/State/State.gd"

func enter():
	player.ani_player.play("Idle")
	ani_player.speed_scale = 1.0
	player.particle_trails.emitting = false
	
func update(delta : float):
	#เปลี่ยนเป็น walk เมื่อเคลื่อนที่
	var input_axis = Input.get_axis("Left", "Right")
	if abs(input_axis) > 0:
		transition_requested.emit("Walk")
		return
		
	#Jump
	if Input.is_action_pressed("Jump") and player.is_on_floor():
		transition_requested.emit("Jump")
		return
		
	if player.is_on_floor():
		player.ground_time += delta
		if player.ground_time == 0:
			player.play_random_step_sound()
	
	
	
