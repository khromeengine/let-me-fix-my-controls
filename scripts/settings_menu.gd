class_name SettingsMenu
extends Control

enum CurrentMenu {
	GAME,
	CONTROL,
	SOUND,
}


@export var game_body: Container
@export var control_body: Container
@export var sound_body: Container
@export var game_selection_button: Button
@export var control_selection_button: Button
@export var sound_selection_button: Button
@export var return_button: Button
@export var sensitivity_slider: HSlider
@export var fov_slider: HSlider
@export var master_v_slider: HSlider
@export var sfx_slider: HSlider
@export var music_slider: HSlider
@export var open_audio: AudioStreamPlayer
@export var close_audio: AudioStreamPlayer


var state: CurrentMenu = CurrentMenu.GAME


func _ready():
	game_selection_button.pressed.connect(open_game_menu)
	control_selection_button.pressed.connect(open_control_menu)
	sound_selection_button.pressed.connect(open_sound_menu)
	sensitivity_slider.value_changed.connect(sensitivity_change)
	fov_slider.value_changed.connect(fov_change)
	fov_slider.value = ControlsManager.fov
	sensitivity_slider.value = ControlsManager.camera_sensitivity
	master_v_slider.value = AudioServer.get_bus_volume_db(0)
	sfx_slider.value = AudioServer.get_bus_volume_db(2)
	music_slider.value = AudioServer.get_bus_volume_db(1)
	master_v_slider.value_changed.connect(master_change)
	sfx_slider.value_changed.connect(sfx_change)
	music_slider.value_changed.connect(music_change)


func open_game_menu():
	state = CurrentMenu.GAME
	game_body.visible = true
	sound_body.visible = false
	control_body.visible = false
	open_audio.play()


func open_control_menu():
	state = CurrentMenu.CONTROL
	game_body.visible = false
	sound_body.visible = false
	control_body.visible = true
	open_audio.play()


func open_sound_menu():
	state = CurrentMenu.SOUND
	game_body.visible = false
	sound_body.visible = true
	control_body.visible = false
	open_audio.play()


func sensitivity_change(sens):
	ControlsManager.camera_sens_change.emit(sens)


func fov_change(fov):
	ControlsManager.fov_change.emit(fov)


func music_change(vol):
	AudioServer.set_bus_volume_db(1, vol)


func sfx_change(vol):
	AudioServer.set_bus_volume_db(2, vol)


func master_change(vol):
	AudioServer.set_bus_volume_db(0, vol)
