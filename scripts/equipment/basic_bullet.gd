extends Node3D


@export var speed = 400.0

@onready var mesh = $MeshInstance3D
@onready var shape_cast = $ShapeCast3D
@onready var ray = $RayCast3D
@onready var light = $OmniLight3D
@onready var particles = $GPUParticles3D

var shooter : Node3D
var steps = 3
var _hit := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	var collision_obj = check_collision(delta)
	if collision_obj:
		collision_logic(collision_obj)

func check_collision(delta: float) -> Object:
	if _hit: return null
	for i in range(steps): # Update steps time per frame instead of once per frame
		shape_cast.target_position = Vector3((speed/steps) * delta + 1.0, 0, 0)
		shape_cast.force_shapecast_update()
		if shape_cast.is_colliding() and shape_cast.get_collider(0) != shooter:
			_hit = true
			position -= transform.basis.z * (speed/steps) * delta
			return shape_cast.get_collider(0)
		position -= transform.basis.z * (speed/steps) * delta
	return null

func collision_logic(obj: Object) -> void:
	if(obj.is_in_group("characters")):
		obj.hit(1.0)
	bullet_cleanup()

func bullet_cleanup() -> void:
	mesh.visible = false
	light.visible = false
	particles.emitting = true
	#TODO: seperate this animation so we're not dealing with an await
	await get_tree().create_timer(1.0).timeout # let particles play
	queue_free()

func _on_life_time_timer_timeout() -> void:
	queue_free()
