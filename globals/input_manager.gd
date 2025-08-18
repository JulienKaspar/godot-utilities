extends Node

enum input_modes {MOUSE, CONTROLLER}
enum mouse_states {PRESSED, HELD, RELEASED, NONE}

var current_input_mode := input_modes.MOUSE:
	get():
		return current_input_mode
	set(value):
		if value == current_input_mode:
			return
		current_input_mode = value
		input_mode_changed.emit(value)
signal input_mode_changed(mode: input_modes)

# Mouse related inputs
var mouse_sensitivity 		:= 1.0
var mouse_position_change	:= Vector2.ZERO
var mouse_velocity 			:= Vector2.ZERO
var mouse_vector			:= Vector2.ZERO
var mouse_left_state 		:= mouse_states.NONE
var mouse_left_held_time 	:= 0.0
var _mouse_left_pressed 	:= false

var inner_mouse_deadzone := 0.3
var outer_mouse_deadzone := 0.75
var movement_vector_mouse : Vector2

var bypass_controls := false

var action_pressed := false

# For touch controls
var dragging := false

# Mapped Inputs
var movement_vector	:= Vector2.ZERO

# Get screen resolution info (for mosue movement)
# TODO: This should be somewhere else once the resoltion can be dynamically changed
@onready var window_size 	: Vector2 	= get_viewport().size
@onready var window_width 	: float 	= window_size[0]
@onready var window_height 	: float 	= window_size[1]
@onready var window_shortest_length : float = window_width

func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	var height_is_shortest_side : bool = window_height <= window_width
	if height_is_shortest_side:
		window_shortest_length = window_height
	else:
		window_shortest_length = window_width


# Receive raw inputs. Set input mode to mouse if used
func _input(event: InputEvent) -> void:
	
	# Check input device and set input mode
	if event.get_class() in ["InputEventMouseMotion", 'InputEventMouseButton', "InputEventKey"]:
		current_input_mode = input_modes.MOUSE
	elif event.get_class() in ["InputEventJoypadButton", "InputEventJoypadMotion"]:
		current_input_mode = input_modes.CONTROLLER
	
	if bypass_controls:
		return
	# WARNING: I set this to _input instead of _unhandled_input. Something seems to also use mouse inputs and then this function wont be called.
	
	# For debugging: When the mouse isn't capture you navigate the Godot UI
	var in_game := Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	# Mouse motion
	if event is InputEventMouseMotion and in_game:
		mouse_velocity = event.screen_velocity
		mouse_position_change = event.screen_relative
	
	# Mouse button
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			_mouse_left_pressed = true
		elif event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			_mouse_left_pressed = false
			
	elif event is InputEventScreenTouch:
		if event.is_pressed():
			dragging = true
		else:
			dragging = false

	elif event is InputEventScreenDrag and dragging:
		mouse_velocity = event.screen_velocity
		mouse_position_change = event.screen_relative


# Process inputs further
func _process(_delta: float) -> void:
	
	if bypass_controls:
		return
	
	process_gameplay_input()


func process_gameplay_input():
	
	# Don't use debug shortcuts when running a release build (as oppsed to "debug" or "editor") 
	if not OS.has_feature("release"):
		pass
	
	# Transition left mouse button state
	match mouse_left_state:
		mouse_states.NONE:
			if _mouse_left_pressed:
				mouse_left_state = mouse_states.PRESSED
		mouse_states.PRESSED:
			if _mouse_left_pressed:
				mouse_left_state = mouse_states.HELD
			else:
				mouse_left_state = mouse_states.RELEASED
		mouse_states.HELD:
			if _mouse_left_pressed:
				mouse_left_held_time += get_process_delta_time()
			else:
				mouse_left_held_time = 0.0
				mouse_left_state = mouse_states.RELEASED
		mouse_states.RELEASED:
			if _mouse_left_pressed:
				mouse_left_state = mouse_states.PRESSED
			else:
				mouse_left_state = mouse_states.NONE
	
	# Action button
	if Input.is_action_just_pressed("Action"):
		action_pressed = true
	else:
		action_pressed = false
	
	var mouse_position_change_factor : Vector2
	var sensitivity := mouse_sensitivity * 2.0
	var width_factor := window_width/1920.0
	var height_factor := window_height/1080.0
	# Get relative movement changes based on current resolution
	mouse_position_change_factor.x = mouse_position_change.x / (window_width / width_factor) * sensitivity
	mouse_position_change_factor.y = mouse_position_change.y / (window_height / height_factor) * sensitivity
	
	mouse_vector += mouse_position_change_factor
	mouse_vector = mouse_vector.limit_length(outer_mouse_deadzone)
	
	# Calculate deadzone factor
	var remap_length = remap(
			mouse_vector.length(),
			inner_mouse_deadzone,
			outer_mouse_deadzone,
			0,
			1
	)
	remap_length = clamp(remap_length, 0, 1)
	
	# Apply deadzone on movemetn vector
	movement_vector_mouse = mouse_vector.normalized() * remap_length
	
	# Keyboard/Joystick Movement Vector
	var movement_vector_stick := Input.get_vector("Move Left", "Move Right", "Move Up", "Move Down")
	
	# TODO: Probably needs a setting instead of automatic detection?
	if current_input_mode == input_modes.CONTROLLER:
		movement_vector = movement_vector_stick
	elif current_input_mode == input_modes.MOUSE:
		movement_vector = movement_vector_mouse
	
	# Reset some variables if they are not set next frame
	mouse_velocity = Vector2.ZERO
	mouse_position_change = Vector2.ZERO


func trigger_rumble(duration := 0.1, weak := false) -> void:
	
	# TODO: Add setting to disable or low rumble strength
	if weak:
		Input.start_joy_vibration(
			0,
			1.0,
			0.0,
			duration
		)
	else:
		Input.start_joy_vibration(
			0,
			0.0,
			1.0,
			duration
		)

# reset the movement input when returning to main menu
func reset_movement_input():
	mouse_vector = Vector2.ZERO
	mouse_position_change = Vector2.ZERO
	mouse_velocity = Vector2.ZERO
	movement_vector = Vector2.ZERO


func _on_viewport_size_changed():
	window_width = get_viewport().size[0]
	window_height = get_viewport().size[1]
	
	var height_is_shortest_side : bool = window_height <= window_width
	if height_is_shortest_side:
		window_shortest_length = window_height
	else:
		window_shortest_length = window_width
