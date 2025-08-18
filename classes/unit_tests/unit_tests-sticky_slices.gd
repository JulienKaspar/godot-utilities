extends Node
## A list of unit tests for the ValueSlicer function.

@export var value_slicer_linear: StickySlices
@export var value_slicer_linear_less_trivial: StickySlices
@export var value_slicer_looping: StickySlices


## Executed when the scene is run and initialized
func _ready() -> void:
	
	# List of unit tests
	unit_tests_linear()
	unit_tests_linear_less_trivial()
	unit_tests_looping()


## Simple tests of a non-looping range without much regard for thresholds.
func unit_tests_linear() -> void:
	
	print("Starting tests of unit_tests_linear():")
	
	var slicer = value_slicer_linear
	
	value_slicer_unit_test(slicer, 0, 0, 0) 	# First value in slice 0.
	value_slicer_unit_test(slicer, 0.5, 0, 0) 	# Mid value in slice 0.
	value_slicer_unit_test(slicer, 0.8, 1, 0) 	# Out of hyst range of slice 1.
	value_slicer_unit_test(slicer, 0.95, 1, 1) 	# Within hyst range of slice 1.
	value_slicer_unit_test(slicer, 0.95, 0, 0) 	# Within hyst range of slice 0.
	value_slicer_unit_test(slicer, 1.05, 0, 0) 	# Within hyst range of slice 0.
	value_slicer_unit_test(slicer, 1.15, 0, 1) 	# Firmly in slice 1.
	value_slicer_unit_test(slicer, 3.9999, 3, 3)
	
	print("All unit_tests_linear() tests successful!")


## A less simple range with more regard to passing thresholds.
func unit_tests_linear_less_trivial() -> void:
	
	print("Starting tests of unit_tests_linear_less_trivial():")
	
	var slicer = value_slicer_linear_less_trivial
	
	value_slicer_unit_test(slicer, -3, 0, 0) 	# First value in slice 0.
	value_slicer_unit_test(slicer, -2.75, 0, 0) # Mid value in slice 0.
	value_slicer_unit_test(slicer, -2.61, 1, 0) # Out of hyst range of slice 1.
	value_slicer_unit_test(slicer, -2.59, 1, 1) # Within hyst range of slice 1.
	value_slicer_unit_test(slicer, -2.59, 0, 0) # Within hyst range of slice 0.
	value_slicer_unit_test(slicer, -2.45, 0, 0) # Within hyst range of slice 0.
	value_slicer_unit_test(slicer, -2.30, 0, 1) # Firmly in slice 1.
	value_slicer_unit_test(slicer, 0, 0, 6) 
	value_slicer_unit_test(slicer, 2.9999, 0, 11) 
	
	print("All unit_tests_linear_less_trivial() tests successful!")


## Simple cases of slicing looping angle values.
func unit_tests_looping() -> void:
	
	print("Starting tests of unit_tests_looping():")
	
	var slicer = value_slicer_looping
	
	value_slicer_unit_test(slicer, 0, 0, 0) 	# First value in slice 0.
	value_slicer_unit_test(slicer, -22.5, 0, 0) # Stay on first slice
	value_slicer_unit_test(slicer, 22.5, 0, 0) 	# Stay on first slice
	value_slicer_unit_test(slicer, 90, 1, 1) 	# Stay on second slice
	value_slicer_unit_test(slicer, 180, 2, 2) 	# Stay on third slice
	value_slicer_unit_test(slicer, 270, 2, 3) 	# Switch from third to forth
	value_slicer_unit_test(slicer, 360, 0, 0) 	# On first slice with a full rotation
	value_slicer_unit_test(slicer, 360 + 90, 0, 1) # Loop out of bounds over to second slice
	
	print("All unit_tests_looping() tests successful!")


## The test setup for the function and their inputs.
## Most other parameters are set in the node iteself.
func value_slicer_unit_test(
	_slicer : StickySlices,
	_current_value : float,
	_previous_slice : int,
	_expected_output : int,
) -> void:
	
	var output = _slicer.get_snapped_slice(_current_value, _previous_slice)
	
	assert(
		output == _expected_output,
		str(output) + " is not the expected output of " + str(_expected_output)
	)
	
	print(str(output) + " matches expected output of " + str(_expected_output))
