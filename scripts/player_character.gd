class_name PlayerCharacter
extends CharacterBody3D


func _physics_process(delta: float) -> void:
	print(Input.get_action_strength("move_forward"))
