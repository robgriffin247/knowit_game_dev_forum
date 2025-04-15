class_name Player extends CharacterBody2D


var cardinal_direction: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.ZERO
var move_speed: float = 90.0
var state: String = "idle"

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	pass


func _process(delta: float) -> void:
		
	direction = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	).normalized()
	
	velocity = move_speed * direction

	# Update animation if either direction or state changes
	if set_state() || set_direction():
		update_animation()
	

func _physics_process(delta: float) -> void:
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


# Returns true if state changes
func set_state() -> bool:
	var new_state: String = "idle" if direction==Vector2.ZERO else "walk"
	
	if new_state==state:
		return false
	
	state = new_state
	return true


func update_animation() -> void:
	animation_player.play(state + "_" + animation_direction())


func animation_direction() -> String:
	if cardinal_direction==Vector2.DOWN:
		return "down"
	elif cardinal_direction==Vector2.UP:
		return "up"
	else:
		return "side"
