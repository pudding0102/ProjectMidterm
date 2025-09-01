extends "res://Scripts/Player/State/State.gd"

func enter():
	$Death.play()
	player.death_parickes.emitting = true
	player.death_tween()
	
	#หยุดการเคลื่อนที่
	player.velocity = Vector2.ZERO
	player.set_physics_process(false)
	
func update(dealta : float):
	pass
	
func exit():
	player.set_physics_process(true)
	
	
