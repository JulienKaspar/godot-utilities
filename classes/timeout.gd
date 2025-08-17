@icon("res://classes/icons/abacus.svg")

extends Node
## A custom type for manually ticking down time.
## An alternative to Timer where there's no explicit stopped state and no pausing.
class_name Countdown

@export_range(0.0, 100.0) var MAXIMUM_VALUE : float = 1.0
# TODO: Integrate the minimum value in the methods
@export_range(0.0, 100.0) var MINIMUM_VALUE : float = 0.0
@export var START_DEPLETED := false

@onready var _maximum_value := MAXIMUM_VALUE
@onready var _current_value := MAXIMUM_VALUE

# TODO: Rewrite comments to not refer to time anymore

func _ready() -> void:
	if START_DEPLETED:
		_current_value = 0.0


## Use this to progress the value downwards. Unlike the Timer node, this is an explicit action.
func drain(elapsed_time : float) -> void:
	_current_value -= elapsed_time
	_current_value = max(_current_value, 0.0)


## Refill the timeout by a certain amount of seconds.
## Disable clamping to overflow the timeout past the maximum value.
func fill(added_seconds : float, clamp_maximum := true) -> void:
	_current_value += added_seconds
	if clamp_maximum:
		_current_value = min(_current_value, _maximum_value)


## Reset the timer to the initial value. Optionally set a different maximum time value.
func reset(maximum_override := _maximum_value) -> void:
	_current_value = maximum_override


## Set the timeout to 0.0.
func empty() -> void:
	_current_value = 0.0


## Change the maximum time to a new value in seconds. 
## Call without arguments to revert to original maximum time.
func change_maximum_value(new_maximum := MAXIMUM_VALUE) -> void:
	_maximum_value = new_maximum


## Returns true if the timeout has been depleted.
func is_finished() -> bool:
	return _current_value == 0.0
