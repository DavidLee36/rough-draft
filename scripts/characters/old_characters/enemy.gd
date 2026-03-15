extends Character

@export var aggro_range := 35.0
@export var shoot_timeout := 1.5

@onready var shoot_timer := $ShootTimer

@onready var player = get_tree().current_scene.find_child("Player")
var player_pos := Vector3.ZERO

var aiming := false : set = set_aiming

func _ready() -> void:
	super()
	gun = $Body/Rig_Medium/Skeleton3D/Right_Hand/Pistol

func _physics_process(delta: float) -> void:
	player_pos = player.global_position
	movement_logic(delta)
	aggro_logic()

func movement_logic(delta: float) -> void:
	direction_movement_logic(delta, Vector3.ZERO)
	move_and_slide()

func aggro_logic() -> void:
	_look_at_player() # For now, look at player regardless of range
	if global_position.distance_to(player_pos) <= aggro_range:
		aiming = true
		if shoot_timer.is_stopped():
			shoot_timer.start(shoot_timeout)
	else:
		shoot_timer.stop()
		aiming = false

func _look_at_player() -> void:
	look_at(Vector3(player_pos.x, global_position.y, player_pos.z))
	rotate_y(PI)

func set_aiming(value: bool) -> void:
	if value == aiming: return
	var tween = create_tween()
	tween.tween_method(_play_aim_anim, 1.0 - float(value), float(value), 0.1)
	aiming = value

func _play_aim_anim(value: float) -> void:
	anim_tree.set("parameters/AimBlend/blend_amount", value)

func _on_shoot_timer_timeout() -> void:
	gun.shoot(false)

func hit(damage: float) -> void:
	curr_health -= damage
	if curr_health <= 0:
		die()

func die() -> void:
	queue_free()
