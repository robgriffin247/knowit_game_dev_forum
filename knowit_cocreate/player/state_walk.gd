class_name StateWalk extends State

var move_speed: float = 90.0
@onready var idle: State = $"../Idle"

func enter() -> void:
	player.update_animation("walk")

	
func exit() -> void:
	pass


# What happens with process update in the state
func process(_detla: float) -> State:
	if player.direction == Vector2.ZERO:
		return idle

	player.velocity = player.direction * move_speed

	if player.set_direction():
		player.update_animation("walk")
		
	return null


# What happens with physi>cs process update in the state
func physics(_detla: float) -> State:
	return null


# What happens with input events in this state
func handle_input(_event: InputEvent) -> State:
	return null
