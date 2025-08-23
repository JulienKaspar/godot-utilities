@icon("./pizza.svg")

extends Node
class_name StickySlices
## A Node to slice a range of values into segments. Define the range and number of slices on the node.
## When passing in a value it will return the slice index the value is on.
## An (optional) threshold and previous slice is used to determine when the slice can change to avoid flickering.

@export_category("Slicer Parameters")
@export var RANGE_START := 0.0 ## Inclusive value
@export var RANGE_END := 1.0 ## Exclusive value
@export var SLICE_COUNT := 6
@export var THRESHOLD_FACTOR := 0.1 ## Fraction of a each individual slice
@export var LOOPING_RANGE := false ## For example for rotations. In that case it's likely to use a range start and end of -PI to PI.

# Values to pre-compute on ready
@onready var RANGE_SIZE := RANGE_END - RANGE_START
@onready var INVERTED_RANGE_SIZE := 1 / RANGE_SIZE
@onready var SLICE_SIZE := RANGE_SIZE / SLICE_COUNT
@onready var THRESHOLD_VALUE := SLICE_SIZE * THRESHOLD_FACTOR


# TODO: Make the previous_slice optional.
#		If it's not passed in, then an internal 'previous_slice' variable should be used.
#		Add logic to update this internal 'previous_slice'.
# 		If the threshold value is on 0, then the previous slice shouldn't even matter.
#		Also if the node is called for the first time, the previous slice shouldn't matter.
## A function to cut a range into slices and return on which segment a current value is.
func get_snapped_slice(
		current_value: float,
		previous_slice: int,
) -> int:
	
	if LOOPING_RANGE:
		# Switch active slice based on the center of each slice.
		# Wrap any values that go outside of the range.
		
		var slice_index = _snap_value_to_slice(
			current_value + (SLICE_SIZE * 0.5),
			previous_slice
		)
		return slice_index % SLICE_COUNT
	
	else:
		# Switch active slice on the outer edge of each slice.
		# Error if value is outside of given range.
		
		assert(
			current_value >= RANGE_START or current_value <= RANGE_END,
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
	var prev_slice_middle = (previous_slice + 0.5) * SLICE_SIZE + RANGE_START
	
	if THRESHOLD_VALUE > 0.0 and abs(prev_slice_middle - current_value) < SLICE_SIZE:
		# Pull the current value towards the middle of the previous slice, but
		# only if it's "closer by" than the middle of an adjacent slice.
		current_value += THRESHOLD_VALUE * sign(prev_slice_middle - current_value)
	
	var current_normalized = (current_value - RANGE_START) * INVERTED_RANGE_SIZE
	var slice_index = SLICE_COUNT * current_normalized
	
	return floor(slice_index)
