extends Node

#แจ้งเตือนเมื่อขนาดเปลี่ยน
signal size_changed(new_size)

enum WindowSize{
	SMALL,
	MEDIUM,
	FULLSCREEN 
}

const SIZES = {
	WindowSize.SMALL: Vector2i(800, 600),
	WindowSize.MEDIUM: Vector2i(1280, 720)
}

const CONFIG_PATH = "user://window_settings.cfg"
var current_size: WindowSize = WindowSize.FULLSCREEN

func _ready():
	load_settings()
	apply_size(current_size)
	
#เปลี่ยนขนาด
func set_window_size(size: WindowSize):
	current_size = size
	apply_size(size)
	save_settings()
	emit_signal("size_changed", get_current_size_vector())

#ใช้งานขนาดปัจจุบัน
func apply_size(size: WindowSize):
	if Engine.is_editor_hint():
		return
	if size == WindowSize.FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		var target_size = SIZES[size]
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(target_size)
		center_window(target_size)

#จัดหน้าต่างให้อยู่กลางจอ
func center_window(size: Vector2i):
	var screen_size = DisplayServer.screen_get_size()
	var position = (screen_size - size) / 2
	DisplayServer.window_set_position(position)

#ดึงขนาดปัจจุบัน
func get_current_size_vector() -> Vector2i:
	if current_size == WindowSize.FULLSCREEN:
		return DisplayServer.screen_get_size()
	return SIZES.get(current_size, Vector2i(1280, 720))
	
#บันทึกการตั้งค่า
func save_settings():
	var config = ConfigFile.new()
	config.set_value("window", "size", current_size)
	config.save(CONFIG_PATH)

#โหลดการตั้งค่า
func load_settings():
	var config = ConfigFile.new()
	if config.load(CONFIG_PATH) == OK:
		current_size = config.get_value("window", "size", WindowSize.FULLSCREEN)	
