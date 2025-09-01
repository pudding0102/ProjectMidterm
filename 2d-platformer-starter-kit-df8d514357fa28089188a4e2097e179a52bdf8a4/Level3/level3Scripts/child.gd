extends CharacterBody2D

@onready var area_sound: Area2D = $AreaSound
@onready var sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D
var player_in_range := false

func _ready() -> void:
	
	# ต่อสัญญาณกันพลาด (เผื่อใน Editor ต่อไว้ผิดฟังก์ชัน/ไม่ตรงชื่อ)
	if area_sound:
		if not area_sound.body_entered.is_connected(_on_area_sound_body_entered):
			area_sound.body_entered.connect(_on_area_sound_body_entered)
		if not area_sound.body_exited.is_connected(_on_area_sound_body_exited):
			area_sound.body_exited.connect(_on_area_sound_body_exited)

		# ให้แน่ใจว่า Area2D ตรวจจับได้
		area_sound.monitoring = true
		var cs: CollisionShape2D = area_sound.get_node_or_null("CollisionShape2D")
		if cs and cs.disabled:
			cs.disabled = false

		# (ถ้า Player อยู่เลเยอร์ 1) เปิด mask บิต 1 ไว้ — ปรับตามโปรเจกต์คุณได้
		area_sound.set_collision_mask_value(1, true)

	# ดีบักเสียง
	if not sfx:
		push_error("ไม่พบโหนด AudioStreamPlayer2D")
	elif sfx.stream == null:
		push_warning("AudioStreamPlayer2D ยังไม่มีไฟล์เสียงใน 'stream'")
	else:
		# ทดสอบไม่ให้ตกเสียงจากระยะ (ชั่วคราวตอนดีบัก)
		# ถ้าใช้ Godot 4: มี property attenuation ให้ตั้งเป็น 0 ได้
		if "attenuation" in sfx:
			sfx.attenuation = 0.0

func _on_area_sound_body_entered(body: Node2D) -> void:
	print("ENTER by:", body.name, " groups=", body.get_groups())
	if body.is_in_group("player"):
		player_in_range = true
		sfx.play()

func _on_area_sound_body_exited(body: Node2D) -> void:
	print("EXIT by:", body.name)
	if body.is_in_group("player"):
		player_in_range = false
		sfx.stop()


	


func _on_area_detect_area_entered(area: Area2D) -> void:
	sfx.stop()
