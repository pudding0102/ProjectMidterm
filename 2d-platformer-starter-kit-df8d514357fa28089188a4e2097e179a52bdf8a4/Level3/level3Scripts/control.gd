extends Control

signal time_up

@export var starting_time_sec: int = 150
@export var auto_start: bool = true
@export var warning_at: int = 10

# ระบุโหนดผ่าน Inspector
@export_node_path("Label") var label_path: NodePath
@export_node_path("Timer") var timer_path: NodePath
@export_node_path("AudioStreamPlayer2D") var beep_path: NodePath

@export var main_menu_scene: String = "res://Scenes/Levels/Level_01.tscn"  # ระบุพาธของหน้าเมนูหลัก

@onready var time_label: Label = null
@onready var timer: Timer = null
@onready var beep: AudioStreamPlayer2D = null

var remaining: int

func _ready() -> void:
	# resolve nodes
	if label_path != NodePath(""):
		time_label = get_node_or_null(label_path)
	elif has_node("TimeLabel"):
		time_label = $TimeLabel

	if timer_path != NodePath(""):
		timer = get_node_or_null(timer_path)
	elif has_node("Timer"):
		timer = $Timer

	if beep_path != NodePath(""):
		beep = get_node_or_null(beep_path)
	elif has_node("Beep"):
		beep = $Beep

	remaining = starting_time_sec
	_update_label()

	if timer:
		timer.wait_time = 1.0
		timer.one_shot = false
		if not timer.timeout.is_connected(_on_tick):
			timer.timeout.connect(_on_tick)
		if auto_start:
			timer.start()

func _on_tick() -> void:
	remaining -= 1
	if remaining <= 0:
		remaining = 0
		_update_label()
		if beep: 
			beep.play()
		if timer: 
			timer.stop()
		emit_signal("time_up")
		_return_to_main_menu()  # กลับไปที่เมนูหลัก
		return

	if remaining <= warning_at and beep and not beep.playing:
		beep.play()

	_update_label()

func _update_label() -> void:
	if time_label:
		var m: int = remaining / 60
		var s: int = remaining % 60
		time_label.text = "%02d:%02d" % [m, s]

# ===== ควบคุมจากภายนอกได้ =====
func start(seconds: int = -1) -> void:
	remaining = seconds if seconds >= 0 else starting_time_sec
	_update_label()
	if timer: 
		timer.start()

func pause() -> void:
	if timer: 
		timer.stop()

func resume() -> void:
	if timer and remaining > 0:
		timer.start()

func reset() -> void:
	pause()
	start(starting_time_sec)

func add_time(sec: int) -> void:
	remaining = max(0, remaining + sec)
	_update_label()

# ===== กลับไปที่เมนูหลัก =====
func _return_to_main_menu() -> void:
	# ใช้ SceneTree เพื่อเปลี่ยนฉาก
	if get_tree():
		# อาจเพิ่มเอฟเฟกต์ fade out หรือ delay ก่อนเปลี่ยนฉาก
		var error = get_tree().change_scene_to_file(main_menu_scene)
		if error != OK:
			print("Error changing scene: ", error)
