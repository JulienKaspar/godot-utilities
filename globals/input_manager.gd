## A global script responsible for listening to and processing inputs.
## These are then accessible to any script in the game that needs them.
## It keeps track of multiple input devices and can swap between them any time.
extends Node

enum input_devices {MOUSE, CONTROLLER}
enum mouse_states {PRESSED, HELD, RELEASED, NONE}

signal input_mode_changed(mode: input_devices)
var current_input_device := input_devices.MOUSE:
	set(value):
		if value == current_input_device:
			return
		current_input_device = value
		input_mode_changed.emit(value)

# Input settings
var mouse_sensitivity 		:= 1.0

# Mouse movement
# TODO: Is this centered mouse position recalculated if the screen resolution adjsusts?
var mouse_position_centered	:= Vector2.ZERO ## The mouse position based on the screen center as the zero point
var mouse_position_change	:= Vector2.ZERO
var mouse_velocity 			:= Vector2.ZERO
# Mouse input
var mouse_left_state 		:= mouse_states.NONE
var mouse_left_held_time 	:= 0.0
var mouse_left_pressed 	:= false

var bypass_controls := false

# For touch controls
var dragging := false

# Mapped Inputs
var movement_vector	:= Vector2.ZERO

# Get screen resolution info (for mosue movement)
# TODO: This should be somewhere else once the resoltion can be dynamically changed
@onready var window_size 	: Vector2 	= get_viewport().size
@onready var window_width 	: float 	= window_size[0]
@onready var window_height 	: float 	= window_size[1]
@onready var window_shortest_length : float

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
		current_input_device = input_devices.MOUSE
	elif event.get_class() in ["InputEventJoypadButton", "InputEventJoypadMotion"]:
		current_input_device = input_devices.CONTROLLER
	
	if bypass_controls:
		return
	
	# Mouse motion
	if event is InputEventMouseMotion:
		mouse_velocity = event.screen_velocity
		mouse_position_change = event.screen_relative
	
	# Mouse button
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			mouse_left_pressed = true
		elif event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
			mouse_left_pressed = false
			
	elif event is InputEventScreenTouch:
		if event.is_pressed():
			dragging = true
		else:
			dragging = false

	elif event is InputEventScreenDrag and dragging:
		mouse_velocity = event.screen_velocity
		mouse_position_change = event.screen_relative


# TODO: All of this should probably move to the _input function.
#		Add two sub-functions: One for listening to the input and the next one for processing it.
#		This should happen during _input() to have all of this done before any other process starts.
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
			if mouse_left_pressed:
				mouse_left_state = mouse_states.PRESSED
		mouse_states.PRESSED:
			if mouse_left_pressed:
				mouse_left_state = mouse_states.HELD
			else:
				mouse_left_state = mouse_states.RELEASED
		mouse_states.HELD:
			if mouse_left_pressed:
				mouse_left_held_time += get_process_delta_time()
			else:
				mouse_left_held_time = 0.0
				mouse_left_state = mouse_states.RELEASED
		mouse_states.RELEASED:
			if mouse_left_pressed:
				mouse_left_state = mouse_states.PRESSED
			else:
				mouse_left_state = mouse_states.NONE
	
	# Generic Action button example
	# if Input.is_action_just_pressed("Action"):
	# 	action_pressed = true
	# else:
	# 	action_pressed = false
	
	var mouse_position_change_factor : Vector2
	# TODO: Shouldn't this be relative to the actual resolution?
	var width_factor := window_width/1920.0
	var height_factor := window_height/1080.0
	# Get relative movement changes based on current resolution
	mouse_position_change_factor.x = mouse_position_change.x / (window_width / width_factor) * mouse_sensitivity
	mouse_position_change_factor.y = mouse_position_change.y / (window_height / height_factor) * mouse_sensitivity
	
	mouse_position_centered += mouse_position_change_factor
	
	# Apply deadzone on movemetn vector
	var movement_vector_mouse = mouse_position_centered.normalized()
	# Keyboard/Joystick Movement Vector
	var movement_vector_stick := Input.get_vector("Move Left", "Move Right", "Move Up", "Move Down")
	
	# TODO: Probably needs a setting instead of automatic detection?
	if current_input_device == input_devices.CONTROLLER:
		movement_vector = movement_vector_stick
	elif current_input_device == input_devices.MOUSE:
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
	mouse_position_centered = Vector2.ZERO
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
