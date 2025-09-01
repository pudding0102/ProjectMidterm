extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Rainsound.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):  # ตรวจสอบว่าพื้นที่ชนกับตัวละคร
		var spawnpoint = get_node("SpawnPoint")  # ให้แน่ใจว่าได้ตั้งชื่อ SpawnPoint
		area.position = spawnpoint.position  # ย้ายตัวละครไปที่ SpawnPoint
