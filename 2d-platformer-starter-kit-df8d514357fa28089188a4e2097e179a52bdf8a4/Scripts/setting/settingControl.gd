extends Panel

var grap_bn: Array
var size_bn: Array

#Audio
@onready var music_slider: HSlider = $VBoxContainer/soundSet/musicContainer/musicSlider
@onready var sfx_slider: HSlider = $VBoxContainer/soundSet/gameSoundContainer/sfxSlider

#Graphic_bn
@onready var bn_high: Button = $VBoxContainer/ghapSet/ghapVboxContainer/ghapHBoxContainer/bn_high
@onready var bn_medium_grap: Button = $VBoxContainer/ghapSet/ghapVboxContainer/ghapHBoxContainer/bn_medium
@onready var bn_low: Button = $VBoxContainer/ghapSet/ghapVboxContainer/ghapHBoxContainer/bn_low

#Size_bn
@onready var bn_large: Button = $VBoxContainer/sizeSet/sizeVboxContainer/sizeHBoxContainer/bn_large
@onready var bn_mudium_size: Button = $VBoxContainer/sizeSet/sizeVboxContainer/sizeHBoxContainer/bn_mudium
@onready var bn_small: Button = $VBoxContainer/sizeSet/sizeVboxContainer/sizeHBoxContainer/bn_small

func _ready():
	#แสดงค่า volume ปัจจุบัน
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))) * 50
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))) * 50
	
	#เชื่อมต่อ signals
	music_slider.value_changed.connect(_on_music_slider_value_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)
	
	grap_bn = [bn_high, bn_medium_grap, bn_low]
	size_bn = [bn_large, bn_mudium_size, bn_small]
	
	#ตั้งค่า Size scene
	if SizeController:
		match SizeController.current_size:
			SizeController.WindowSize.FULLSCREEN:
				set_active(size_bn, bn_large)
			SizeController.WindowSize.MEDIUM:
				set_active(size_bn, bn_mudium_size)
			SizeController.WindowSize.SMALL:
				set_active(size_bn, bn_small)
	#ตั้งค่า graphic
	if GraphicController:
		match GraphicController.get_graphics_quality():
			GraphicController.GraphicsQuality.LOW:
				set_active(grap_bn, bn_low)
				# เปลี่ยนเป็นการเรียก static function ผ่าน class
				bn_low.text = GraphicController.get_quality_name(GraphicController.GraphicsQuality.LOW)
			
			GraphicController.GraphicsQuality.MEDIUM:
				set_active(grap_bn, bn_medium_grap)
				# เปลี่ยนเป็นการเรียก static function ผ่าน class
				bn_medium_grap.text = GraphicController.get_quality_name(GraphicController.GraphicsQuality.MEDIUM)
			
			GraphicController.GraphicsQuality.HIGH:
				set_active(grap_bn, bn_high)
				# เปลี่ยนเป็นการเรียก static function ผ่าน class
				bn_high.text = GraphicController.get_quality_name(GraphicController.GraphicsQuality.HIGH)

#Music
func _on_music_slider_value_changed(value: float) -> void:
	var db_value = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db_value)

#SFX
func _on_sfx_slider_value_changed(value: float) -> void:
	var db_value = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), db_value)
		
#Graphic pressed
func _on_bn_high_pressed() -> void:
	set_active(grap_bn, bn_high)
	GraphicController.set_graphics_quality(GraphicController.GraphicsQuality.HIGH)

func _on_bn_medium_grap_pressed() -> void:
	set_active(grap_bn, bn_medium_grap)
	GraphicController.set_graphics_quality(GraphicController.GraphicsQuality.MEDIUM)

func _on_bn_low_pressed() -> void:
	set_active(grap_bn, bn_low)
	GraphicController.set_graphics_quality(GraphicController.GraphicsQuality.LOW)

#Size pressed
func _on_bn_large_pressed() -> void:
	set_active(size_bn, bn_large)
	SizeController.set_window_size(SizeController.WindowSize.FULLSCREEN)
	SizeController.save_settings()

func _on_bn_mudium_size_pressed() -> void:
	set_active(size_bn, bn_mudium_size)
	SizeController.set_window_size(SizeController.WindowSize.MEDIUM)
	SizeController.save_settings()
		
func _on_bn_small_pressed() -> void:
	set_active(size_bn, bn_small)
	SizeController.set_window_size(SizeController.WindowSize.SMALL)
	SizeController.save_settings()
		
	
#จัดการปุ่มในกลุ่ม
func set_active(buttons: Array, active_button: Button):
	for btn in buttons:
		btn.button_pressed = (btn == active_button)

func _on_bn_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Managers/gameMenu.tscn")
