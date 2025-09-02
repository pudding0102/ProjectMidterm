extends Area2D

@export var door: Sprite2D
@onready var door_collision: CollisionShape2D = $CollisionShape2D

'''
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and GameManager.key == 1 and door.visible:
		$Lever3.play()
		door.visible = false
		self.visible = false
		door_collision.disabled = true   # ปิดการชน
'''		


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and GameManager.key == 1 and door.visible:
		$Lever3.play()
		door.visible = false
		self.visible = false
		door_collision.disabled = true   # ปิดการชน
		
