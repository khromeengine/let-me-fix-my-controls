extends Node

var camera_sensitivity: float = 0.1

signal open_pause_menu
signal open_controls_menu
signal closed_pause_menu

signal add_bind(StringName, InputEvent)
signal remove_bind(StringName, InputEvent)


var paused = false:
	set(state):
		get_tree().paused = state
		paused = state
	get:
		return paused


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_bind.connect(_handle_add_bind)
	remove_bind.connect(_handle_remove_bind)
	closed_pause_menu.connect(_on_closed_pause_menu)
	open_pause_menu.connect(_on_open_pause_menu)
	open_controls_menu.connect(_on_open_controls_menu)


func get_total_strength_of_action(action: StringName) -> float:
	return InputMap.action_get_events(action).reduce(_helper_add_action_strength, 0.0)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("open_menu"):
		if paused:
			closed_pause_menu.emit()
		else:
			open_pause_menu.emit()
	if event.is_action_pressed("force_open_controls_menu"):
		open_controls_menu.emit()


func _on_open_pause_menu():
	paused = true


func _on_closed_pause_menu():
	paused = false


func _on_open_controls_menu():
	paused = true


func _handle_add_bind(action: StringName, input: InputEvent):
	if InputMap.has_action(action):
		InputMap.action_add_event(action, input)
	else:
		push_warning("Tried to add input ", input.as_text(), " to bad action ", action)


func _handle_remove_bind(action: StringName, input: InputEvent):
	if InputMap.has_action(action):
		if input != null:
			InputMap.action_erase_event(action, input)
	else:
		push_warning("Tried to remove input ", input.as_text(), " from bad action ", action)


func _helper_add_action_strength(accum: float, a: InputEvent) -> float:
	return accum + _helper_get_action_strength_arbitrary(a)


func _helper_get_action_strength_arbitrary(input: InputEvent) -> float:
	if input is InputEventKey:
		return float(Input.is_key_pressed(input.physical_keycode))
	if input is InputEventMouseButton:
		return float(Input.is_mouse_button_pressed(input.button_index))
	else:
		return 0
