class_name ControlButton
extends Button

signal open_button_for_listening(ControlButton)
signal request_button_removal(ControlButton)


var held_input: InputEvent
var open_audio: AudioStreamPlayer


func _pressed():
	open_button_for_listening.emit(self)
	open_audio.play()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT:
			request_button_removal.emit(self)
