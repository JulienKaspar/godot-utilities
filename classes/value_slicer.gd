extends Node
class_name ValueSlicer
## A Node to slice a range of values into segments. Define the range and number of slices on the node.
## When passing in a value it will return a new slice index.
## A threshold and previous slice is used to determine when the slice changes to avoid flickering.

@export_category("Slicer Parameters")
@export var _range_minimum := 0.0 ## Inclusive value
@export var _range_maximum := 1.0 ## Exclusive value
@export var _slice_numbers := 6
@export var _threshold_factor := 0.1 ## Fraction of a single slice
@export var _use_looping_range := false

# Values to pre-compute on ready
var _range_size : float
var _inverted_range_size : float
var _slice_size : float
var _threshold_value : float


# Pre-compute values and setup.
func _ready() -> void:
	
	_range_size = _range_maximum - _range_minimum
	_inverted_range_size = 1 / _range_size
	_slice_size = _range_size / _slice_numbers
	_threshold_value = _slice_size * _threshold_factor


## A function to get cut a range into slices and return on which segment a current value is.
## If used for rotations or other looping ranges, pass in looping_range (true).
func get_snapped_slice(
		current_value: float,
		previous_slice: int,
) -> int:
	
	if _use_looping_range:
		# Switch active slice based on the center of each slice.
		# Wrap any values that go outside of the range.
		
		var slice_index = _snap_value_to_slice(
			current_value + (_slice_size * 0.5),
			previous_slice
		)
		return slice_index % _slice_numbers
	
	else:
		# Switch active slice on the outer edge of each slice.
		# Error if value is outside of given range.
		
		assert(
			current_value >= _range_minimum or current_value <= _range_maximum,
			"current_value is not within the given range!"
		)
		return _snap_value_to_slice(current_value, previous_slice)


func _snap_value_to_slice(
		current_value: float,
		previous_slice: int,
) -> int:
	
	# TODO: Using the slice middle should be optional
	#		When dynamically switching between values slicers with different slice counts,
	#		it's better if the divisions are aligned!
	var prev_slice_middle = (previous_slice + 0.5) * _slice_size + _range_minimum
	
	if _threshold_value > 0.0 and abs(prev_slice_middle - current_value) < _slice_size:
		# Pull the current value towards the middle of the previous slice, but
		# only if it's "closer by" than the middle of an adjacent slice.
		current_value += _threshold_value * sign(prev_slice_middle - current_value)
	
	var current_normalized = (current_value - _range_minimum) * _inverted_range_size
	var slice_index = _slice_numbers * current_normalized
	
	return floor(slice_index)
