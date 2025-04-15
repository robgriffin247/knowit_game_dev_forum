class_name PlayerStateMachine extends Node


var states: Array[State]
var previous_state: State 
var current_state: State 


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED



# All three of these will change the state if needed
func _process(delta: float) -> void:
	change_state(current_state.process(delta))
	

func _physics_process(delta: float) -> void:
	change_state(current_state.physics(delta))
	

func _unhandled_input(event: InputEvent) -> void:
	change_state(current_state.handle_input(event))




# Will look for the available states
func initialise(_player: Player) -> void:
	states = []
	
	for child in get_children():
		if child is State:
			states.append(child)
	
	if states.size() > 0:
		states[0].player = _player
		change_state(states[0])
		process_mode = Node.PROCESS_MODE_INHERIT



# This is fundamental to state machine
func change_state(new_state: State) -> void:
	# If state does not change
	if new_state == null || current_state == new_state:
		return
	
	if current_state:
		current_state.exit()
	
	previous_state = current_state
	current_state = new_state
	
	current_state.enter()
	
