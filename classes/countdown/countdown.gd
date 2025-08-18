@icon("./abacus.svg")

extends Node
## A custom type for manually ticking down of time or other units.
## An alternative to the Timer where there's no explicit stopped state and no pausing.
class_name Countdown

@export_range(0.0, 100.0) var MAXIMUM_VALUE : float = 1.0
# TODO: Maybe also add a custom minimum value
@export var START_DEPLETED := false

var _current_value : float

@onready var _maximum_value := MAXIMUM_VALUE


func _ready() -> void:
	if START_DEPLETED:
		_current_value = 0.0
	else:
		_current_value = MAXIMUM_VALUE


## Use this to progress the value towards zero. Unlike the Timer node, this is an explicit action.
func progress(amount : float) -> void:
	_current_value -= amount
	_current_value = max(_current_value, 0.0)


## Change the the countdown by a certain amount towards the maximum value.
## Disable clamping to overflow the timeout past the maximum value.
func regress(amount : float, clamp_maximum := true) -> void:
	_current_value += amount
	if clamp_maximum:
		_current_value = min(_current_value, _maximum_value)


## Reset the countdown to the initial value. Optionally set a different maximum.
func reset(maximum_override := _maximum_value) -> void:
	_current_value = maximum_override


## Set the countdown to zero.
func empty() -> void:
	_current_value = 0.0


## Change the maximum value to something new. 
## Call without arguments to revert to original maximum.
func change_maximum_value(new_maximum := MAXIMUM_VALUE) -> void:
	_maximum_value = new_maximum


## Returns true if the countdown reached zero.
func is_finished() -> bool:
	return _current_value == 0.0
