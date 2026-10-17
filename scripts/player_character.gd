class_name PlayerCharacter
extends CharacterBody3D

@export var fwd_movement_speed: float = 250
@export var strafe_speed: float = 200
@export var backing_speed: float = 100
@export var jump_strength: float = 200
@export var friction: float = 200

@export var default_cam_sens = 0.5
@export var default_cam_y_ratio = 1.0

@onready var camera = $Camera3D
@onready var cam_yaw = $CameraYaw
@onready var cam_pitch = $CameraYaw/CameraPitch


func _physics_process(delta: float) -> void:
	move_and_slide()
	pass


func do_forward_movement(delta: float) -> void:
	var forward_strength = ControlsManager.get_total_strength_of_action("move_forward")
	

func do_camera_movement(vec: Vector2) -> void:
	cam_yaw.rotate_y(-vec.x * ControlsManager.camera_sensitivity * default_cam_sens)
	cam_pitch.rotate_x(-vec.y * ControlsManager.camera_sensitivity * default_cam_sens)
	cam_pitch.rotation.x = clampf(cam_pitch.rotation.x, -PI/4, PI/4)
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		do_camera_movement(Vector2(event.screen_relative.x, event.screen_relative.y * default_cam_y_ratio))
