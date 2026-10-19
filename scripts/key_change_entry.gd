class_name KeyChangeEntry
extends BoxContainer

@export var label_text: String
@export var target_action: StringName
@export var open_audio: AudioStreamPlayer
@export var closed_audio: AudioStreamPlayer

var button_array: Array[ControlButton] = []

var _is_listening: bool = false
var _listening_position: int = -1
var _inited: bool = false

@onready var button_container = $ButtonContainer


func _ready() -> void:
	populate_buttons()
	$Label.text = label_text


func populate_buttons():
	if not InputMap.has_action(target_action):
		push_warning("Could not init key change entry with target action name: ", target_action)
		return
	add_new_button()
	for event in InputMap.action_get_events(target_action):
		bind_button(event, -1)
	_inited = true


func add_new_button():
	var new_button = ControlButton.new()
	new_button.text = "-"
	new_button.held_input = null
	new_button.open_audio = open_audio
	new_button.open_button_for_listening.connect(_handle_button_press)
	button_container.add_child(new_button)
	button_array.push_back(new_button)


func bind_button(input: InputEvent, pos: int):
	var pointed_button: ControlButton = button_array[pos] if pos != -1 else button_array.back()
	var new_bind = pointed_button.held_input == null
	var already_binded = false
	if input is InputEventMouseMotion:
		return
	for button in button_array:
		if button.held_input != null and button.held_input.is_match(input):
			already_binded = true
	if already_binded:
		print("Already bound")
		closed_audio.play()
		return
	ControlsManager.remove_bind.emit(target_action, pointed_button.held_input)
	pointed_button.held_input = input
	ControlsManager.add_bind.emit(target_action, input)
	pointed_button.request_button_removal.connect(_handle_button_removal_request)
	pointed_button.text = input.as_text()
	if _inited:
		open_audio.play()
	if new_bind:
		add_new_button()


func open_button_to_listen():
	pass


func delete_button(pos: int):
	if target_action == "open_menu":
		var bound_number = 0
		for button in button_array:
			if button.held_input != null:
				bound_number += 1
		if bound_number <= 1:
			push_warning("Can't unbind last pause menu")
			return
	var pointed_button = button_array.pop_at(pos)
	if pointed_button.held_input == null:
		return
	ControlsManager.remove_bind.emit(target_action, pointed_button.held_input)
	pointed_button.open_button_for_listening.disconnect(_handle_button_press)
	pointed_button.request_button_removal.disconnect(_handle_button_removal_request)
	pointed_button.queue_free()


func _input(event):
	if _is_listening:
		if event is InputEventMouseMotion:
			return
		bind_button(event, _listening_position)
		get_viewport().set_input_as_handled()
		_is_listening = false
		_listening_position = -1


func _handle_button_press(button: ControlButton):
	_is_listening = true
	_listening_position = button_array.find(button)


func _handle_button_removal_request(button: ControlButton):
	delete_button(button_array.find(button))
