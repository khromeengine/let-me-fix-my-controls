class_name SettingsMenu
extends Control

enum CurrentMenu {
	CONTROL,
	SOUND,
}


@export var control_body: Container
@export var sound_body: Container
@export var control_selection_button: Button
@export var sound_selection_button: Button
@export var return_button: Button


var state: CurrentMenu = CurrentMenu.CONTROL


func _ready():
	control_selection_button.pressed.connect(open_control_menu)
	sound_selection_button.pressed.connect(open_sound_menu)


func open_control_menu():
	state = CurrentMenu.CONTROL
	sound_body.visible = false
	control_body.visible = true


func open_sound_menu():
	state = CurrentMenu.SOUND
	sound_body.visible = true
	control_body.visible = false
