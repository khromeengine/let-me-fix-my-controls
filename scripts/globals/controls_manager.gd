extends Node

var camera_sensitivity: float = 0.1

signal open_pause_menu
signal open_controls_menu
signal closed_pause_menu

signal add_bind(StringName, InputEvent)
signal remove_bind(StringName, InputEvent)


func _helper_get_action_strength_arbitrary(input: InputEvent) -> float:
	if input is InputEventKey:
		return float(Input.is_key_pressed(input.physical_keycode))
	if input is InputEventMouseButton:
		return float(Input.is_mouse_button_pressed(input.button_index))
	else:
		return 0


func _helper_add_action_strength(accum: float, a: InputEvent) -> float:
	return accum + _helper_get_action_strength_arbitrary(a)


func get_total_strength_of_action(action: StringName) -> float:
	return InputMap.action_get_events(action).reduce(_helper_add_action_strength, 0.0)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("open_menu"):
		open_pause_menu.emit()
	if event.is_action_pressed("force_open_controls_menu"):
		open_controls_menu.emit()
