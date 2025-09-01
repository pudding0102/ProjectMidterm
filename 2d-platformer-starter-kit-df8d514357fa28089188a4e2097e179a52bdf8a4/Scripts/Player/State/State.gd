extends Node

signal transition_requested(new_state_name)

var player : CharacterBody2D
var ani_player : AnimatedSprite2D

func _ready() -> void:
	await get_tree().process_frame
	player = get_parent() as CharacterBody2D
	ani_player = player.get_node("AnimatedSprite2D")

func enter():
	pass
	
func exit():
	pass

func update(dealta : float):
	pass
	
func _physics_process(delta: float) -> void:
	pass
	
func handle_input(even: InputEvent):
	pass

	
