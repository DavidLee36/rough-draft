class_name PhysicsHelpers

# Used by character_capsule
static func push_away_rigid_bodies(master: Node3D, slave: KinematicCollision3D):
	var push_dir = -slave.get_normal()
	# How much velocity the object needs to increase to match player velocity in the push direction
	var velocity_diff_in_push_dir = master.velocity.dot(push_dir) - slave.get_collider().linear_velocity.dot(push_dir)
	# Only count velocity towards push dir, away from character
	velocity_diff_in_push_dir = max(0., velocity_diff_in_push_dir)
	# Objects with more mass than us should be harder to push. But doesn't really make sense to push faster than we are going
	var mass_ratio = min(1., master.mass / slave.get_collider().mass)
	# Optional add: Don't push object at all if it's 4x heavier or more
	if mass_ratio < 0.25:
		return
	# Don't push object from above/below
	#push_dir.y = 0
	# 5.0 is a magic number, adjust to your needs
	var push_force = mass_ratio * 2.5
	slave.get_collider().apply_impulse(push_dir * velocity_diff_in_push_dir * push_force, slave.get_position() - slave.get_collider().global_position)
