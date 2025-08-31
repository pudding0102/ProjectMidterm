extends Node2D


@export var next_scene : PackedScene

func _process(delta):
	$Camera2D.offset.x += delta * 100

func _on_start_button_pressed() -> void:
	GameManager.load_next_level(next_scene)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
