class_name ControlButton
extends Button

signal open_button_for_listening(ControlButton)


var held_input: InputEvent


func _pressed():
	open_button_for_listening.emit(self)
