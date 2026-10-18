class_name InGameMenu
extends Control


signal return_to_pause_menu()


enum CurrentMenu {
	CLOSED,
	PAUSE,
	SETTINGS,
}


@export var pause_menu: Control
@export var settings: SettingsMenu
@export var resume_button: Button
@export var settings_button: Button
@export var reset_button: Button
@export var open_audio: AudioStreamPlayer
@export var close_audio: AudioStreamPlayer


var state: CurrentMenu = CurrentMenu.PAUSE


func _ready() -> void:
	reset_button.pressed.connect(_handle_reset_pressed)
	resume_button.pressed.connect(_handle_resume_pressed)
	settings_button.pressed.connect(_handle_settings_pressed)
	settings.return_button.pressed.connect(_handle_return_to_pause_menu)
	ControlsManager.closed_pause_menu.connect(_handle_closed_pause_menu)
	ControlsManager.open_controls_menu.connect(_handle_open_controls_menu)
	ControlsManager.open_pause_menu.connect(_handle_opened_pause_menu)


func _handle_reset_pressed():
	ControlsManager.reset.emit()


func _handle_resume_pressed():
	ControlsManager.closed_pause_menu.emit()


func _handle_settings_pressed():
	state = CurrentMenu.SETTINGS
	settings.visible = true
	pause_menu.visible = false
	open_audio.play()


func _handle_opened_pause_menu():
	state = CurrentMenu.PAUSE
	settings.visible = false
	pause_menu.visible = true
	visible = true
	open_audio.play()


func _handle_closed_pause_menu():
	state = CurrentMenu.CLOSED
	settings.visible = false
	pause_menu.visible = false
	visible = false
	close_audio.play()


func _handle_open_controls_menu():
	if state == CurrentMenu.SETTINGS and settings.state == settings.CurrentMenu.CONTROL:
		_handle_resume_pressed()
	else:
		visible = true
		pause_menu.visible = false
		settings.visible = true
		open_audio.play()


func _handle_return_to_pause_menu():
	state = CurrentMenu.PAUSE
	settings.visible = false
	pause_menu.visible = true
	close_audio.play()
