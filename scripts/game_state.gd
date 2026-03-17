extends Node

const _BASE_TIME_SCALE: float = 1.0
const _SLOW_TIME_SCALE: float = 0.25

signal bullet_time_changed(new_scale: float)

var _bullet_time: bool = false
var bullet_time: bool:
	get: return _bullet_time
	set(value):
		if _bullet_time == value:
			return
		_bullet_time = value
		if _bullet_time:
			Engine.time_scale = _SLOW_TIME_SCALE
		else:
			Engine.time_scale = _BASE_TIME_SCALE
		bullet_time_changed.emit(value)
