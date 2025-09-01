extends Node2D

@onready var main_menu: Panel = $Design/CanvasLayer/MainMenu
@onready var setting_menu: Panel = $Design/settingMenu

# test

func _ready() -> void:
	if main_menu:
		main_menu.visible = true
	else:
		print("Main menu not found!")
		
	if setting_menu:
		setting_menu.visible = false
	else:
		print("Setting menu not found!")
		
	SizeController.apply_size(SizeController.current_size)
	

func _on_bn_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/Level_01.tscn")


func _on_bn_setting_pressed() -> void:
	main_menu.visible = false
	setting_menu.visible = true

func _on_bn_exit_pressed() -> void:
	get_tree().quit()
