extends Node


signal action_pressed(action_name)
var input_history : Array = []

var actions = [
	"move_forward",
	"move_backward",
	"turn_left",
	"turn_right",
	"strafe_left",
	"strafe_right",
	"menu_toggle"
]

func _process(_delta):
	for action in actions:
		if Input.is_action_just_pressed(action):
			input_history.append(action)
			if input_history.size() > 10:
				input_history.pop_front()
			emit_signal("action_pressed", action)
