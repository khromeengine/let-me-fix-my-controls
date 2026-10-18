class_name PlayerCharacter
extends CharacterBody3D


const DELTA_LERP_CONSTANT = 12


@export_category("Dependencies")
@export var coyote_timer: Timer
@export var collision_box: CollisionShape3D

@export_category("Movement")
@export var fwd_movement_speed: float = 120
@export var strafe_speed: float = 90
@export var backing_speed: float = 60
@export var jump_strength: float = 5
@export var horizontal_jump_multiplier: float = 3
@export var coyote_time: float = 0.1
@export var friction: float = 0.4
@export var drag: float = 0.1
@export var gravity: float = 10
@export var max_walking_speed: float = 20
@export var max_strafing_speed: float = 15
@export var max_backing_speed: float = 10
@export var min_speed: float = 0.05
@export_range(0, 90, 1, "radians_as_degrees") var crouch_jump_angle_modifier: float = PI/12
@export_range(0, 90, 1, "radians_as_degrees") var minimum_jump_angle: float = PI/12
@export var default_height: float = 2.0
@export var crouch_height_reduction: float = 0.5

@export var default_cam_sens = 0.1
@export var default_cam_y_ratio = 1.0


var _moved_last_frame: bool = true
var _jumped_last_frame: bool = false
var _crouched_last_frame: bool = false
var _grounded_last_frame: bool = false

var jump_dir_vector: Vector3 = Vector3.UP
var extra_jumps: int = 0
var crouch_stacks: int = 0
var height: float = 2.0:
	set(x):
		if height == x:
			return
		global_position.y += (x - height) / 2
		height = x
		collision_box.shape.height = x
		camera.position.y = (height - default_height) / 2
	get:
		return height

@onready var camera = $CameraYaw/CameraPitch/Camera3D
@onready var cam_yaw = $CameraYaw
@onready var cam_pitch = $CameraYaw/CameraPitch
@onready var look_direction = $CameraYaw/CameraPitch/LookDirection


func _ready() -> void:
	ControlsManager.player_character = self
	ControlsManager.current_checkpoint = global_position
	ControlsManager.fov_change.connect(_on_fov_change)


func _physics_process(delta: float) -> void:
	handle_friction(delta, _moved_last_frame)
	handle_drag(delta, _moved_last_frame)
	apply_gravity(delta)
	
	var did_forward_movement = do_forward_backward_movement(delta)
	var did_strafe = do_strafing(delta)
	
	_moved_last_frame = did_forward_movement or did_strafe
	
	if is_on_floor() and not _jumped_last_frame:
		extra_jumps = InputMap.action_get_events(&"jump").size() - 1
	if not is_on_floor() and _grounded_last_frame:
		coyote_timer.start(coyote_time)
		_grounded_last_frame = false
	
	try_crouch()
	
	_jumped_last_frame = false
	
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



func try_crouch() -> void:
	var crouch_strength = ControlsManager.get_total_strength_of_action("crouch")
	if crouch_strength >= 0:
		crouch_stacks = int(crouch_strength)
		height = default_height * (crouch_height_reduction ** crouch_stacks)
		_crouched_last_frame = true
	else:
		crouch_stacks = 0
		height = default_height
		_crouched_last_frame = false


func try_jump():
	print(is_on_floor())
	if not is_on_floor() and coyote_timer.is_stopped():
		if extra_jumps <= 0:
			return
		else:
			extra_jumps -= 1
	_jumped_last_frame = true
	coyote_timer.stop()
	var jump_velocity = jump_strength * jump_dir_vector
	if crouch_stacks > 0:
		jump_velocity = jump_velocity.rotated(Vector3.LEFT, clampf(crouch_jump_angle_modifier * crouch_stacks, -PI/4 + minimum_jump_angle, PI/4 - minimum_jump_angle))
		jump_velocity = jump_velocity.rotated(Vector3.UP, cam_yaw.global_rotation.y)
		jump_velocity *= crouch_stacks
		jump_velocity.x *= horizontal_jump_multiplier
		jump_velocity.z *= horizontal_jump_multiplier
	if sign(jump_velocity.x) != sign(velocity.x) and jump_velocity.x != 0:
		velocity.x = jump_velocity.x
	else:
		velocity.x += jump_velocity.x
	if sign(jump_velocity.z) != sign(velocity.z) and jump_velocity.z != 0:
		velocity.z = jump_velocity.z
	else:
		velocity.z += jump_velocity.z
	velocity.y = clampf(velocity.y + jump_velocity.y, jump_velocity.y, INF)


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
	cam_pitch.rotation.x = clampf(cam_pitch.rotation.x, -PI/2, PI/2)
	pass


func handle_friction(delta: float, moving: bool) -> void:
	if is_on_floor():
		var horz_velocity = Vector2(velocity.x, velocity.z)
		if horz_velocity.length() <= min_speed * max_walking_speed and not moving:
			horz_velocity = Vector2.ZERO
		else:
			horz_velocity = lerp(horz_velocity, Vector2.ZERO, 1 - (1 - friction) ** (DELTA_LERP_CONSTANT * delta))
		velocity.x = horz_velocity.x
		velocity.z = horz_velocity.y


func handle_drag(delta: float, moving: bool) -> void:
	if not is_on_floor():
		var horz_velocity = Vector2(velocity.x, velocity.z)
		if horz_velocity.length() <= min_speed * max_walking_speed and not moving:
			horz_velocity = Vector2.ZERO
		else:
			horz_velocity = lerp(horz_velocity, Vector2.ZERO, 1 - (1 - drag) ** (DELTA_LERP_CONSTANT * delta))
		velocity.x = horz_velocity.x
		velocity.z = horz_velocity.y


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		do_camera_movement(Vector2(event.screen_relative.x, event.screen_relative.y * default_cam_y_ratio))
		#Input.warp_mouse(get_viewport().get_visible_rect().size / 2)
		
		get_viewport().set_input_as_handled()
	if event.is_action_pressed("jump"):
		try_jump()


func _handle_reset():
	global_position = Vector3.ZERO


func _on_fov_change(fov: float):
	camera.fov = fov
