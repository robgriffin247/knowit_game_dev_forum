class_name State extends Node


static var player: Player


func _ready() -> void:
	pass


func enter() -> void:
	pass
	
func exit() -> void:
	pass


# What happens with process update in the state
func process(_detla: float) -> State:
	return null


# What happens with physi>cs process update in the state
func physics(_detla: float) -> State:
	return null


# What happens with input events in this state
func handle_input(_event: InputEvent) -> State:
	return null
