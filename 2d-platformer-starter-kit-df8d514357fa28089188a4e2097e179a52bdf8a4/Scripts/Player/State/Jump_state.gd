extends State

func enter():
	player.player_sprite.play("Jump")
	player.jump_tween()
	
func physics_update(delta):
	# เรียกใช้ gravity และ movement
	player.movement(delta)
	
	if player.is_on_floor():
		if abs(player.velocity.x) > 0:
			change_state.emit("Walk")
		else:
			change_state.emit("Idle")
