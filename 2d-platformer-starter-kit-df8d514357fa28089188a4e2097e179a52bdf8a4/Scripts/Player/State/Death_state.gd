extends State

func enter():
	player.player_sprite.play("Death")
	player.velocity = Vector2.ZERO
	player.death_tween()
	
	#ผู้เล่นไม่สามารถเคลื่อนไหวได้
	player.set_physics_process(false)

func exit():
	player.set_physics_process(true)
	
	
