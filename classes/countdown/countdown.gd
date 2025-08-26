@icon("./abacus.svg")

extends Node
class_name Countdown
## A custom type for manually ticking down of time or other units.
## An alternative to the Timer where there's no explicit stopped state and no pausing.

@export_range(0.0, 100.0) var MAXIMUM_VALUE : float = 1.0
# TODO: Maybe also add a custom minimum value
@export var START_DEPLETED := false

## The current value as a 0-1 factor towards the defined maximum value.
var current_value_factor : float
## Do not set this value directly.
## Use the methods "progress", "regress", "reset" and "empty" instead.
var current_value : float:
	set(value):
		current_value = value

		current_value_factor = remap(
			current_value,
			0.0,
			_maximum_value,
			0.0,
			1.0
		)
		current_value_factor = min(current_value_factor, 1.0)

@onready var _maximum_value := MAXIMUM_VALUE


func _ready() -> void:
	if START_DEPLETED:
		current_value = 0.0
	else:
		current_value = MAXIMUM_VALUE


## Can be called in case the node is created in code.
## This will let you set all the usual export variables.
## IMPORTANT: Call this before adding the instance to the scene, so its ready function is called after.
func init(init_maximum_value := MAXIMUM_VALUE, init_start_depleted := START_DEPLETED) -> void:	
	MAXIMUM_VALUE = init_maximum_value
	START_DEPLETED = init_start_depleted


## Use this to progress the value towards zero. Unlike the Timer node, this is an explicit action.
func progress(amount : float) -> void:
	current_value -= amount
	current_value = max(current_value, 0.0)


## Change the the countdown by a certain amount towards the maximum value.
## Disable clamping to overflow the timeout past the maximum value.
func regress(amount : float, clamp_maximum := true) -> void:
	current_value += amount
	if clamp_maximum:
		current_value = min(current_value, _maximum_value)


## Reset the countdown to the initial maximum value. Optionally set a different maximum.
func reset(maximum_override := _maximum_value) -> void:
	current_value = maximum_override


## Set the countdown to zero.
func empty() -> void:
	current_value = 0.0


## Change the maximum value to something new. 
## Call without arguments to revert to original maximum.
func change_maximum_value(new_maximum := MAXIMUM_VALUE) -> void:
	_maximum_value = new_maximum


## Returns true if the countdown reached zero.
func is_finished() -> bool:
	return current_value == 0.0
