@abstract class_name Character extends CharacterBody3D

@export var base_speed := 6.5
@export var sprint_speed := 9.0
@export var jump_velocity := 6.0
@export var max_health := 10.0
var curr_health : float
@onready var collision := $CollisionShape3D

var anim_state: AnimationNodeStateMachinePlayback
var gun : Node3D
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	curr_health = max_health

func direction_movement_logic(delta: float, direction: Vector3) -> void:
	if is_on_floor():
		if direction: # actively moving
			#anim_state.travel("Walking")
			velocity.x = direction.x * base_speed
			velocity.z = direction.z * base_speed
		else: # slow down
			#anim_state.travel("Idle")
			velocity.x = lerp(velocity.x, direction.x * base_speed, delta * 15.0)
			velocity.z = lerp(velocity.z, direction.z * base_speed, delta * 15.0)
	else: # continue momentum in air even with no input
		velocity.x = lerp(velocity.x, direction.x * base_speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * base_speed, delta * 2.0)
	
	if not is_on_floor():
		#anim_state.travel("Jump_Idle")
		velocity.y -= gravity * delta

@abstract func movement_logic(delta: float) -> void

@abstract func hit(damage: float) -> void

@abstract func die() -> void
