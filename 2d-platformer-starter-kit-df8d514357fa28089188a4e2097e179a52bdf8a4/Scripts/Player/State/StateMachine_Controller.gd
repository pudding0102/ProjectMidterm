extends Node
class_name StateMachine

@export var initial_state : State

var current_state: State
var states: Dictionary = {}

func _ready():
	# เก็บ state ทั้งหมด
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.change_state.connect(change_state)
	
	#ตั้งค่า state เริ่มต้น
	if initial_state:
		change_state(initial_state.name)
		
func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)

func change_state(state_name):
	#ออกจาก state ปัจจุบัน
	if current_state:
		current_state.exit()
	
	#เปลี่ยนไป state ใหม่
	current_state = states.get(state_name)
	if current_state:
		current_state.enter()
