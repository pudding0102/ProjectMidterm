extends Control

signal time_up

@export var starting_time_sec: int 
@export var auto_start: bool = true
@export var warning_at: int

# ระบุโหนดผ่าน Inspector
@export_node_path("Label") var label_path: NodePath
@export_node_path("Timer") var timer_path: NodePath
@export_node_path("AudioStreamPlayer2D") var beep_path: NodePath

@export_node_path("CharacterBody2D") var player_path: NodePath
@export_node_path("Marker2D") var spawnpoint_path: NodePath

@onready var time_label: Label = null
@onready var timer: Timer = null
@onready var beep: AudioStreamPlayer2D = null

@onready var player: CharacterBody2D = null
@onready var spawnpoint: Marker2D = null

var remaining: int

func _ready() -> void:
	# resolve nodes (ไม่ใช้ ?:)
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

	if player_path != NodePath(""):
		player = get_node_or_null(player_path)
	if spawnpoint_path != NodePath(""):
		spawnpoint = get_node_or_null(spawnpoint_path)

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

	# ===== หมดเวลา =====
	if remaining <= 0:
		remaining = 0
		_update_label()
		if beep:
			beep.play()
		if timer:
			timer.stop()
		emit_signal("time_up")
		_respawn_if_needed()

		# --- เริ่มนับใหม่ถ้า auto_start ---
		if auto_start:
			start(starting_time_sec)
		return

	# ===== Warning ตอนใกล้หมดเวลา =====
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

# ===== เปลี่ยนจุดเกิดระหว่างเกม (เช่น เก็บเช็คพอยต์) =====
func set_spawnpoint(marker: Marker2D) -> void:
	if marker:
		spawnpoint = marker

# ===== ย้ายผู้เล่นกลับ SpawnPoint อย่างปลอดภัย =====
func _respawn_if_needed() -> void:
	if player and spawnpoint:
		# หยุดความเร็ว แล้วค่อยวาร์ปหลังเฟรมฟิสิกส์
		if "velocity" in player:
			player.velocity = Vector2.ZERO
			player.call_deferred("set_global_position", spawnpoint.global_position)

		# ถ้าสคริปต์ Player มีเมธอดรีเซ็ตสเตตัส ให้เรียกใช้
		if player.has_method("reset_state"):
			player.reset_state()
