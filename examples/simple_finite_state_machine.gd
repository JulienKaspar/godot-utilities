## This is an example of a finite state machine that can be pasted into any script.
## I found this way of writing and calling the functions is easiest to grow and keep flexible
## with the least amount of manual writing.
##
## The enter, proces and exit functions are concatinated based on a naming convention:
##	"state_<state_name>_<enter/exit/process>
## If not exit or enter function is found, it will be skipped.

extends CharacterBody2D

# These are used to for some error prevention while the state machine is running
enum statemachine_stages {NONE, ENTER, PROCESS, EXIT, DEFERRED}
var locked_stages := [
	statemachine_stages.NONE, 
	statemachine_stages.ENTER, 
	statemachine_stages.EXIT
]
var current_statemachine_stage := statemachine_stages.NONE

enum states {
	IDLE = 0, 
	PREP_MOVE = 10, 
	PREP_ACT = 20, 
	MOVING = 11,
	ACTING = 21
}
var current_state := states.IDLE:
	set(value):
		assert(current_statemachine_stage not in locked_stages, "To avoid bugs, only change the state while using statemachine 'process' functions!")
		current_state = value
var previous_state : states:
	set(value):
		assert(current_statemachine_stage not in locked_stages, "To avoid bugs, only change the state while using statemachine 'process' functions!")
		current_state = value


func _physics_process(_delta: float) -> void:

	state_machine()


func state_machine() -> void:

	var starting_state := current_state
	var current_state_name : StringName = str(states.find_key(current_state))
	var starting_state_name : StringName = str(states.find_key(starting_state))

	# --- STATE ENTERING ---
	if current_state != previous_state:
		current_statemachine_stage = statemachine_stages.ENTER
		var entering_function : StringName = "state_" + current_state_name.to_lower() + "_enter"
		if has_method(entering_function):
			call(entering_function)
		
		# Do this at the end of this frame in case any process needs to know what state came before
		var update_previous_state := func():
			current_statemachine_stage = statemachine_stages.DEFERRED
			previous_state = current_state
			current_statemachine_stage = statemachine_stages.NONE
		update_previous_state.call_deferred()
	
	# --- STATE PROCESS ---
	current_statemachine_stage = statemachine_stages.PROCESS
	var process_function : StringName = "state_" + current_state_name.to_lower() + "_process"
	call(process_function)

	# --- STATE EXITING --- 
	if current_state != starting_state:
		current_statemachine_stage = statemachine_stages.EXIT
		var exiting_function : StringName = "state_" + starting_state_name.to_lower() + "_exit"
		if has_method(exiting_function):
			call(exiting_function)
	
	current_statemachine_stage = statemachine_stages.NONE


# --- NOTE: Finite State Machine here ---


func state_idle_enter() -> void:

	print("ENTER IDLING")


func state_idle_process() -> void:
	
	print("IDLING")
	current_state = states.PREP_MOVE


func state_idle_exit() -> void:
	
	print("EXIT IDLING")