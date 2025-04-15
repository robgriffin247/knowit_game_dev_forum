class_name Player extends CharacterBody2D


var cardinal_direction: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.ZERO

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var state_machine: Node = $StateMachine


func _ready() -> void:
	state_machine.initialise(self)


func _process(_delta: float) -> void:
		
	direction = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	).normalized()
	

func _physics_process(_delta: float) -> void:
	move_and_slide()


# Returns true if direction changes
func set_direction() -> bool:
	var new_direction: Vector2 = cardinal_direction
	
	# Player not pressing a direction so direction cannot change
	if direction == Vector2.ZERO:
		return false
	
	# Direction needs to be cardinal (Up/Down/Left/Right)
	if direction.y == 0:
		new_direction = Vector2.LEFT if direction.x < 0 else Vector2.RIGHT
	elif direction.x == 0:
		new_direction = Vector2.UP if direction.y < 0 else Vector2.DOWN
	
	# Is the direction unchanged?
	if new_direction == cardinal_direction:
		return false
		
	cardinal_direction = new_direction
	sprite.scale.x = -1 if cardinal_direction == Vector2.RIGHT else 1	
	return true



func update_animation(state: String) -> void:
	animation_player.play(state + "_" + animation_direction())


func animation_direction() -> String:
	if cardinal_direction==Vector2.DOWN:
		return "down"
	elif cardinal_direction==Vector2.UP:
		return "up"
	else:
		return "side"
