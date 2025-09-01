extends State

func enter():
	player.player_spirte.play("Idle")

func physics_update(delta):
	player.movement(delta)
	
	# ตรวจสอบการเคลื่อนไหว
	var input_axis = Input.get_axis("Left", "Right")
	if abs(input_axis) > 0:
		change_state.emit("Walk")
		
	#ตรวจสอบการกระโดด
	if Input.is_action_just_pressed("Jump") and player.is_on_floor():
		change_state.emit("Jump")
	
	
