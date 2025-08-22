## This is an example of a finite state machine that can be pasted into any script.
## I found this way of writing and calling the functions is easiest to grow and keep flexible
## with the least amount of manual writing.

## The enter, proces and exit functions are concatinated based on a naming convention:
##	"state_<state_name>_<enter/exit/process>
## If not exit or enter function is found, it will be skipped.

extends CharacterBody2D

enum states {
	IDLE = 0, 
	PREP_MOVE = 10, 
	PREP_ACT = 20, 
	MOVING = 11,
	ACTING = 21
}

var current_state := states.IDLE:
	set(new_state):
		state_exiting(current_state)
		current_state = new_state
var previous_state : states


func _physics_process(delta: float) -> void:

	state_machine()


func state_machine() -> void:

	var current_state_name : StringName = str(states.find_key(current_state))

	# Enter new state 
	# Call its entering function (if it has one)
	if current_state != previous_state:
		var entering_function : StringName = "state_" + current_state_name.to_lower() + "_enter"
		if has_method(entering_function):
			call(entering_function)
		
		# Do this at the end of this frame in case any process needs to know what state came before
		update_previous_state.call_deferred()
	
	# State process
	var process_function : StringName = "state_" + current_state_name.to_lower() + "_process"
	call(process_function)


# --- NOTE: Finite State Machine here ---


func state_idle_enter() -> void:

	print("ENTER IDLING")


func state_idle_process() -> void:
	
	print("IDLING")
    current_state = states.PREP_MOVE


func state_idle_exit() -> void:
	
	print("EXIT IDLING")


# --- NOTE: Signaled and private methods here ---


func update_previous_state() -> void:
	previous_state = current_state


func state_exiting(state : states):

	var state_name := str(states.find_key(state))
	# Enter new state and call its entering function (if it has one)
	var exiting_function : StringName = "state_" + state_name.to_lower() + "_exit"
	if has_method(exiting_function):
		call(exiting_function)
