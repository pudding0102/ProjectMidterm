extends Node

signal graphics_changed(preset)

enum GraphicsQuality {
	LOW,
	MEDIUM,
	HIGH
}

# ตั้งค่ากราฟิก 2D สำหรับแต่ละระดับ
const GRAPHICS_SETTINGS_2D = {
	GraphicsQuality.LOW: {
		"msaa_2d": 0,
		"texture_filter": Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST,
		"use_pixel_snap": true,
		"antialiasing": false,
	},
	GraphicsQuality.MEDIUM: {
		"msaa_2d": 1,
		"texture_filter": Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR,
		"use_pixel_snap": false,
		"antialiasing": true,
	},
	GraphicsQuality.HIGH: {
		"msaa_2d": 2,
		"texture_filter": Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR_WITH_MIPMAPS,
		"use_pixel_snap": false,
		"antialiasing": true,
	}
}

const CONFIG_PATH = "user://graphics_2d_settings.cfg"
var current_graphics: GraphicsQuality = GraphicsQuality.HIGH

func _ready():
	load_settings()
	apply_graphics(current_graphics)

func set_graphics_quality(quality: GraphicsQuality):
	current_graphics = quality
	apply_graphics(quality)
	save_settings()
	emit_signal("graphics_changed", quality)

func get_graphics_quality() -> GraphicsQuality:
	return current_graphics

func get_graphics_quality_name() -> String:
	match current_graphics:
		GraphicsQuality.LOW: return "Low"
		GraphicsQuality.MEDIUM: return "Medium"
		GraphicsQuality.HIGH: return "High"
		_: return "Unknown"

#ใช้งานภายใน
func apply_graphics(quality: GraphicsQuality):
	if Engine.is_editor_hint():
		return
	
	var settings = GRAPHICS_SETTINGS_2D[quality]
	var viewport := get_viewport()
	
	#ตั้งค่า texture filter ผ่าน ProjectSettings
	match settings["texture_filter"]:
		0:
			ProjectSettings.set_setting("rendering/2d/default_filters/use_nearest_filter", true)
		1, 2:
			ProjectSettings.set_setting("rendering/2d/default_filters/use_nearest_filter", false)
	
	#ตั้งค่า MSAA
	if has_method("get_viewport"):
		get_viewport().msaa_2d = settings["msaa_2d"]
	
	ProjectSettings.save()

func save_settings():
	var config = ConfigFile.new()
	config.set_value("graphics_2d", "quality", current_graphics)
	var error = config.save(CONFIG_PATH)
	if error != OK:
		print("Error saving 2D graphics settings: ", error)

func load_settings():
	var config = ConfigFile.new()
	if config.load(CONFIG_PATH) == OK:
		current_graphics = config.get_value("graphics_2d", "quality", GraphicsQuality.HIGH)
		print("Loaded 2D graphics settings: ", get_graphics_quality_name())
	else:
		print("Using default 2D graphics settings: High")

# ฟังก์ชันช่วยเหลือ
static func get_quality_name(quality: GraphicsQuality) -> String:
	match quality:
		GraphicsQuality.LOW: return "Low"
		GraphicsQuality.MEDIUM: return "Medium"
		GraphicsQuality.HIGH: return "High"
		_: return "Unknown"

static func get_quality_description(quality: GraphicsQuality) -> String:
	match quality:
		GraphicsQuality.LOW: 
			return "เหมาะสำหรับเกม pixel art\nประสิทธิภาพสูงสุด"
		GraphicsQuality.MEDIUM: 
			return "สมดุลระหว่างคุณภาพและประสิทธิภาพ\nเหมาะสำหรับเกมทั่วไป"
		GraphicsQuality.HIGH: 
			return "คุณภาพภาพที่ดีที่สุด\nใช้เอฟเฟกต์ทั้งหมด"
		_: return ""

static func get_all_qualities() -> Array:
	return [GraphicsQuality.LOW, GraphicsQuality.MEDIUM, GraphicsQuality.HIGH]

# ตรวจสอบการรองรับ
static func is_high_quality_supported() -> bool:
	return true
