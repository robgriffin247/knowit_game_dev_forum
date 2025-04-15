# Knowit Game Development Forum

### Aim

Create a 2D isometric pixel art game set in the knowit office, guiding the character from new recruit to seasoned consultant and cocreator!

### Setting up for dev

1. Download and install Godot 4.x

1. Clone the repo

    ```{bash}
    git clone git@github.com:robgriffin247/knowit_game_dev_forum.git
    ```



### New Project

1. Open Godot

1. Create new project

1. Add a Node2D scene, rename it to ``playground``

1. In project settings:
    - General / Rendering / Textures / Canvas Textures -> Nearest
    - General / Display / Window 
        - Size / Width = 480
        - Size / Height = 270
        - Stretch / Mode = Viewport
        - Size / Window Width Override = 1920
        - Size / Window Height Override = 1080


1. Add left, right, up and down to input map

1. Hit F5 to run the project




### Add a player

1. Add a ``CharacterBody2D`` called ``player`` node to ``playground`` and save as a scene in a folder called player

1. Add a ``CollisionShape2D`` as a child of ``player``, adding a circle in the inspector

1. Add a ``Sprite2D`` as a child to the ``CharacterBody2D``

1. Drag the Adam_16x16.png spritesheet into the texture

1. In Inspector / Animation
    - Hframes = 24 
    - Vframes = 7 
    - Frame = 42

1. Adjust position of sprite and collision shape


1. Add a script to the ``player`` node

    ```
    class_name Player extends CharacterBody2D


    var move_speed: float = 90.0
    var direction: Vector2 = Vector2.ZERO


    func _ready() -> void:
        pass


    func _process(delta: float) -> void:
            
        direction = Vector2(
            Input.get_axis("left", "right"),
            Input.get_axis("up", "down")
        ).normalized()
        
        velocity = move_speed * direction


    func _physics_process(delta: float) -> void:
        move_and_slide()
    ```

1. Run the project and check the player can move

1. Add an ``AnimationPlayer`` node to player

1. Add animation ``idle_down`` in the animation pane

1. Key the frame (42) in Sprite2D to create a new track

1. Skip 0.2 seconds, key next frame and repeat to frame 47

1. Set duration to 1.2, turn on autoplay and set to loop

1. Duplicate the animation and rename to 
    - ``idle_up``, setting frames to 30-35
    - ``idle_side``, setting frames to 36-41

1. Duplicate to ``walk_down`` and set duration to 0.9, spacing at 0.15, frames 66-71

1. Duplicate and rekey to 
    - ``walk_up`` frames 54-59
    - ``walk_side`` frames 60-65

1. Modify the script, adding functions to check if state and direction change and to update the animation

    ```
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

    ```


### FORUM DEMO: Refactor to a State Machine

Player has basic states of idle and walk

States add a lot of code to the player script

Alternative is to create a finite state machine, which breaks eachs state out of the main player script

The player can only be in one state at a time, e.g. cannot be both idle and walk

The state machine controls the player state


-----

1. Create a script called ``player/state.gd`` to represent the new ``State`` class, which all states will extend

    ```
    class_name State extends Node

    static var player: Player


    func _ready() -> void:
        pass


    # What happens when the player enters the state
    func enter() -> void:
        pass


    # What happens when the player exits the state
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

    ```

1. Create the ``player/player_state_machine.gd`` class; a class the will orchestrate the state of the player

    ```
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
        

    ```

1. Add `StateMachine` Node to ``player`` scene, with children `Idle` and `Walk`

1. Attach the `player_state_machine` script to ``StateMachine``


1. Modifiy player.gd 
    - Remove move_speed and state variables
    - add onready call to statemachine node
    - add ``state_machine.initialise(self)`` to ``ready()``
    - remove velocity and update animation from ``process()``
    - remove ``set_state()``
    - add ``state: String`` as a parameter in ``update_animation()``

1. Duplicate ``state`` script as ``state_idle``
    - add to Idle node
    - change class_name and extends
    - remove ``ready()`` and static ``playuer`` variable
    - add ``player.update_animation("idle")`` to ``enter()``
    - add ``player.velocity = Vector2.ZERO`` to ``process``

1. Duplicate ``state_idle`` as ``state_walk``
    - change class_name
    - add ``var move_speed: float = 90.0``
    - add reference to idle state node
    - modify ``process()``

        ```
        func process(_detla: float) -> State:
            if player.direction == Vector2.ZERO:
                return idle

            player.velocity = player.direction * move_speed

            if player.set_direction():
                player.update_animation("walk")
            
            return null
        ```
1. Add reference to walk state to idle state script, and add to process in idle state

    ```
    if player.direction!=Vector2.ZERO:
        return walk
    ```