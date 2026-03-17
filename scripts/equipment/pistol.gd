extends Node3D

@onready var anim_player = $Sketchfab_model/Root/Armature/AnimationPlayer
@onready var ray = $RayCast3D
@onready var audio_player = $AudioStreamPlayer3D

@export var bullet_spread: float = 2

const _PITCH_SCALE: float = 1.2
const _SLOW_PITCH_SCALE: float = 0.8

var basic_bullet = load("res://scenes/equipment/BasicBullet.tscn")
var bullet

enum bulletType {
	REGULAR,
	ICE,
	FIRE
}

func _ready() -> void:
	GameState.bullet_time_changed.connect(_on_bullet_time_changed)

func shoot(spread: bool) -> void:
	if anim_player.is_playing(): return # shoot speed based on animation
	anim_player.play("SlideBack")
	audio_player.play()
	_spawn_bullet(spread)

func _spawn_bullet(spread: bool) -> void:
	bullet = basic_bullet.instantiate()
	bullet.shooter = owner
	bullet.position = ray.global_position
	bullet.transform.basis = ray.global_transform.basis

	if spread:
		bullet.rotation_degrees += Vector3(0,randf_range(-bullet_spread,bullet_spread),randf_range(-bullet_spread,bullet_spread))

	get_tree().current_scene.add_child(bullet)

func _on_bullet_time_changed(bullet_time: bool) -> void:
	if bullet_time:
		audio_player.pitch_scale = _SLOW_PITCH_SCALE
	else:
		audio_player.pitch_scale = _PITCH_SCALE
