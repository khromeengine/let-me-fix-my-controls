class_name PlayerCharacter
extends CharacterBody3D


const DELTA_LERP_CONSTANT = 12

@export var fwd_movement_speed: float = 120
@export var strafe_speed: float = 90
@export var backing_speed: float = 60
@export var jump_strength: float = 20
@export var friction: float = 0.2
@export var drag: float = 0.2
@export var gravity: float = 10
@export var max_walking_speed: float = 20
@export var max_strafing_speed: float = 15
@export var max_backing_speed: float = 10
@export var min_speed: float = 0.1

@export var default_cam_sens = 0.1
@export var default_cam_y_ratio = 1.0

var _moved_last_frame: bool = true

@onready var camera = $CameraYaw/CameraPitch/Camera3D
@onready var cam_yaw = $CameraYaw
@onready var cam_pitch = $CameraYaw/CameraPitch
@onready var look_direction = $CameraYaw/CameraPitch/LookDirection


func _physics_process(delta: float) -> void:
	handle_friction(delta, _moved_last_frame)
	handle_drag(delta, _moved_last_frame)
	apply_gravity(delta)
	
	var did_forward_movement = do_forward_backward_movement(delta)
	var did_strafe = do_strafing(delta)
	
	_moved_last_frame = did_forward_movement or did_strafe
	
	move_and_slide()


func do_forward_backward_movement(delta: float) -> bool:
	var forward_strength = ControlsManager.get_total_strength_of_action("move_forward")
	var forward_direction = Vector3.FORWARD.rotated(Vector3.UP, cam_yaw.global_rotation.y)
	var backward_strength = ControlsManager.get_total_strength_of_action("move_back")
	var backward_direction = -forward_direction
	if forward_strength - backward_strength > 0:
		_do_arbitrary_directional_movement(forward_strength - backward_strength, delta, fwd_movement_speed, max_walking_speed, forward_direction)
		return true
	if backward_strength - forward_strength > 0:
		_do_arbitrary_directional_movement(backward_strength - forward_strength, delta, backing_speed, max_backing_speed, backward_direction)
		return true
	return false


func do_strafing(delta: float) -> bool:
	var right_strength = ControlsManager.get_total_strength_of_action("strafe_right")
	var right_direction = Vector3.RIGHT.rotated(Vector3.UP, cam_yaw.global_rotation.y)
	var left_strength = ControlsManager.get_total_strength_of_action("strafe_left")
	var left_direction = -right_direction
	if right_strength - left_strength > 0:
		_do_arbitrary_directional_movement(right_strength - left_strength, delta, strafe_speed, max_strafing_speed, right_direction)
		return true
	elif left_strength - right_strength > 0:
		_do_arbitrary_directional_movement(left_strength - right_strength, delta, strafe_speed, max_strafing_speed, left_direction)
		return true
	return false


func _do_arbitrary_directional_movement(button_strength: float, delta: float, movement_speed: float, max_movement_speed: float, forward_vector: Vector3) -> void:
	var max_forward_velocity = forward_vector * max_movement_speed * button_strength
	var added_forward_velocity = forward_vector * button_strength * movement_speed * delta
	if forward_vector.x > 0:
		if velocity.x <= max_forward_velocity.x:
			velocity.x = clampf(velocity.x + added_forward_velocity.x, -INF, max_forward_velocity.x)
	elif forward_vector.x < 0:
		if velocity.x >= max_forward_velocity.x:
			velocity.x = clampf(velocity.x + added_forward_velocity.x, max_forward_velocity.x, INF)
	if forward_vector.z > 0:
		if velocity.z <= max_forward_velocity.z:
			velocity.z = clampf(velocity.z + added_forward_velocity.z, -INF, max_forward_velocity.z)
	elif forward_vector.z < 0:
		if velocity.z >= max_forward_velocity.z:
			velocity.z = clampf(velocity.z + added_forward_velocity.z, max_forward_velocity.z, INF)


func do_camera_movement(vec: Vector2) -> void:
	cam_yaw.rotate_y(-vec.x * ControlsManager.camera_sensitivity * default_cam_sens)
	cam_pitch.rotate_x(-vec.y * ControlsManager.camera_sensitivity * default_cam_sens)
	cam_pitch.rotation.x = clampf(cam_pitch.rotation.x, -PI/4, PI/4)
	pass


func handle_friction(delta: float, moving: bool) -> void:
	if is_on_floor():
		var horz_velocity = Vector2(velocity.x, velocity.z)
		if horz_velocity.length() <= min_speed * max_walking_speed and not moving:
			horz_velocity = Vector2.ZERO
		else:
			horz_velocity = lerp(horz_velocity, Vector2.ZERO, 1 - friction ** (DELTA_LERP_CONSTANT * delta))
		velocity.x = horz_velocity.x
		velocity.z = horz_velocity.y


func handle_drag(delta: float, moving: bool) -> void:
	if not is_on_floor():
		var horz_velocity = Vector2(velocity.x, velocity.z)
		if horz_velocity.length() <= min_speed * max_walking_speed and not moving:
			horz_velocity = Vector2.ZERO
		else:
			horz_velocity = lerp(horz_velocity, Vector2.ZERO, 1 - drag ** (DELTA_LERP_CONSTANT * delta))
		velocity.x = horz_velocity.x
		velocity.z = horz_velocity.y


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		do_camera_movement(Vector2(event.screen_relative.x, event.screen_relative.y * default_cam_y_ratio))
		
		get_viewport().set_input_as_handled()
