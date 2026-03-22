@abstract class_name CharacterCapsule extends CharacterBody3D

@export var base_speed := 6.5
@export var sprint_speed := 9.0
@export var jump_velocity := 10.0
@export var max_health := 10.0
var mass: float = 80

var curr_health : float

@onready var collision_capsule := $CollisionShape3D

var gun : Node3D
const GRAVITY := 20

func _ready() -> void:
	curr_health = max_health

func direction_movement_logic(delta: float, direction: Vector3) -> void:
	if is_on_floor():
		if direction: # actively moving
			velocity.x = direction.x * base_speed
			velocity.z = direction.z * base_speed
		else: # slow down
			velocity.x = lerp(velocity.x, direction.x * base_speed, delta * 15.0)
			velocity.z = lerp(velocity.z, direction.z * base_speed, delta * 15.0)
	else: # continue momentum in air even with no input
		velocity.x = lerp(velocity.x, direction.x * base_speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * base_speed, delta * 2.0)
	
func fall(delta: float):
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

func _rigid_body_collision(): # CALL BEFORE MOVE_AND_SLIDE()
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			PhysicsHelpers.push_away_rigid_bodies(self, c)

@abstract func movement_logic(delta: float) -> void

@abstract func hit(damage: float) -> void

@abstract func die() -> void
