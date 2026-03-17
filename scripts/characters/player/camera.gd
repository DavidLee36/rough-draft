extends Camera3D


@onready var gun: Node3D = $Pistol

var gun_hip_placement := Vector3(0.53, -0.37, -0.85)
var gun_hip_rotation := Vector3(-1, 2, 0)
var hip_fov := 75
var gun_ads_placement := Vector3(0, -0.228, -0.714)
var gun_ads_rotation := Vector3(-2.2, 0, 0)
var ads_fov := 45
var ads_speed := 0.15

var _tween: Tween

func ads_logic(aiming: bool) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween().set_parallel(true)
	_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	if not aiming:
		_tween.tween_property(self, "fov", hip_fov, ads_speed)
		_tween.tween_property(gun, "position", gun_hip_placement, ads_speed)
		_tween.tween_property(gun, "rotation_degrees", gun_hip_rotation, ads_speed)
	else:
		_tween.tween_property(self, "fov", ads_fov, ads_speed)
		_tween.tween_property(gun, "position", gun_ads_placement, ads_speed)
		_tween.tween_property(gun, "rotation_degrees", gun_ads_rotation, ads_speed)
