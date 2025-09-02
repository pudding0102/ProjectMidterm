extends Area2D

# Load next level scene when player collide with level finish door.
func _on_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().call_group("Player", "death_tween") # death_tween is called here just to give the feeling of player entering the door.
		#AudioManager.level_complete_sfx.play()
<<<<<<< HEAD
		get_tree().change_scene_to_file("res://Scenes/Managers/gameMenu.tscn")
=======
		get_tree().change_scene_to_file("res://Level3/level3scene/level_03.tscn")
>>>>>>> 0350868eaacb61f4140a8ae02ed291ece91f5d5d
