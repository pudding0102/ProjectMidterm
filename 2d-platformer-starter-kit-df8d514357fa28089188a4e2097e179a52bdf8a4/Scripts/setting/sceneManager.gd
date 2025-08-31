extends Node
var previous_scene : String = ""

func change_to_scene(new_scene_path: String):
	previous_scene = get_tree().current_scene.filename
	get_tree().change_scene(new_scene_path)

func go_to_previous_scene() -> void:
	if previous_scene != "":
		get_tree().change_scene(previous_scene)
