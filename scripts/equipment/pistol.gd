extends Node3D

@onready var anim_player = $Sketchfab_model/Root/Armature/AnimationPlayer
@onready var ray = $RayCast3D

@export var bullet_spread := 2

var basic_bullet = load("res://scenes/equipment/BasicBullet.tscn")
var bullet

enum bulletType {
	REGULAR,
	ICE,
	FIRE
}


func shoot(spread: bool) -> void:
	if anim_player.is_playing(): return # shoot speed based on animation
	anim_player.play("SlideBack")
	bullet = basic_bullet.instantiate()
	bullet.shooter = owner
	bullet.position = ray.global_position
	bullet.transform.basis = ray.global_transform.basis

	if spread:
		bullet.rotation_degrees += Vector3(0,randf_range(-bullet_spread,bullet_spread),randf_range(-bullet_spread,bullet_spread))

	get_tree().current_scene.add_child(bullet)
