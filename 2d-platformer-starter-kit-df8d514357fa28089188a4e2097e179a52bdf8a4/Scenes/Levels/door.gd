extends Area2D
@export var door : TileMapLayer

func _on_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("Player") && GameManager.key == 1 && door.enabled == true:
		$Lever3.play()
		door.enabled = false
		self.visible = false
		
