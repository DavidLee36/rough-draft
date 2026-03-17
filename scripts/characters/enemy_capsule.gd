extends Character

@export var aggro_range := 35.0
@export var shoot_timeout := 1.5

@onready var shoot_timer := $ShootTimer

@onready var player = get_tree().current_scene.find_child("PlayerCapsule")
var player_pos := Vector3.ZERO

func _ready() -> void:
	super()
	gun = $Pistol

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
		if shoot_timer.is_stopped():
			shoot_timer.start(shoot_timeout)
	else:
		shoot_timer.stop()

func _look_at_player() -> void:
	look_at(Vector3(player_pos.x, global_position.y, player_pos.z))
	rotate_y(PI)
	gun.look_at(Vector3(player_pos.x, player_pos.y+1, player_pos.z)) # Player height is 2, so y+1 makes the gun point at the center of the player

func _on_shoot_timer_timeout() -> void:
	gun.shoot(true)

func hit(damage: float) -> void:
	curr_health -= damage
	if curr_health <= 0:
		die()

func die() -> void:
	queue_free()
