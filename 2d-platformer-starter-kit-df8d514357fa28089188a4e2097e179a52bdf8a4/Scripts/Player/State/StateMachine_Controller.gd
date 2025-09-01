extends Node

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.transition_requested.connect(change_state)
	
	if initial_state:
		change_state(initial_state.name)

func change_state(state_name: String):
	if current_state:
		current_state.exit()
	
	current_state = states.get(state_name)
	if current_state:
		current_state.enter()

func _physics_process(delta: float):
	if current_state:
		current_state.physics_update(delta)
