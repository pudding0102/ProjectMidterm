extends StaticBody2D

func _ready() -> void:
	await get_tree().create_timer(randf_range(2,8)).timeout
	$AnimationPlayer.play("Trap")
