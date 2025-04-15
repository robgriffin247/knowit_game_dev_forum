class_name StateIdle extends State

@onready var walk: StateWalk = $"../Walk"


func enter() -> void:
	player.update_animation("idle")

	
func exit() -> void:
	pass


# What happens with process update in the state
func process(_detla: float) -> State:
	
	if player.direction!=Vector2.ZERO:
		return walk
		
	player.velocity = Vector2.ZERO
	
	return null


# What happens with physi>cs process update in the state
func physics(_detla: float) -> State:
	return null


# What happens with input events in this state
func handle_input(_event: InputEvent) -> State:
	return null
