@abstract class_name CharacterCapsule extends CharacterBody3D

@export var base_speed := 6.5
@export var sprint_speed := 9.0
@export var jump_velocity := 10.0
@export var max_health := 10.0
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

func _push_away_rigid_bodies(): # CALL BEFORE MOVE_AND_SLIDE()
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			var push_dir = -c.get_normal()
			# How much velocity the object needs to increase to match player velocity in the push direction
			var velocity_diff_in_push_dir = self.velocity.dot(push_dir) - c.get_collider().linear_velocity.dot(push_dir)
			# Only count velocity towards push dir, away from character
			velocity_diff_in_push_dir = max(0., velocity_diff_in_push_dir)
			# Objects with more mass than us should be harder to push. But doesn't really make sense to push faster than we are going
			const MY_APPROX_MASS_KG = 80.0
			var mass_ratio = min(1., MY_APPROX_MASS_KG / c.get_collider().mass)
			# Optional add: Don't push object at all if it's 4x heavier or more
			if mass_ratio < 0.25:
				continue
			# Don't push object from above/below
			#push_dir.y = 0
			# 5.0 is a magic number, adjust to your needs
			var push_force = mass_ratio * 3.
			c.get_collider().apply_impulse(push_dir * velocity_diff_in_push_dir * push_force, c.get_position() - c.get_collider().global_position)

@abstract func movement_logic(delta: float) -> void

@abstract func hit(damage: float) -> void

@abstract func die() -> void
