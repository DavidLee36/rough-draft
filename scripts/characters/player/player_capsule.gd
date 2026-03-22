extends CharacterCapsule

@export var mouse_sensitivity := 0.001
@export var jetpack_velocity: float = 10
@export var jetpack_velocity_cap: float = 10

@onready var camera: Camera3D = $Camera3D
@onready var restrict_jetpack_timer: Timer = $RestrictJetpackTimer

var _mouse_delta := Vector2.ZERO

var aiming := false

func _ready() -> void:
	super()
	gun = $Camera3D/Pistol
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_mouse_delta += event.relative
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("mouse_capture"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	movement_logic(delta)
	aiming_logic()
	shooting_logic()
	if Input.is_action_pressed("bullet_time"):
		Engine.time_scale = 0.25
	else:
		Engine.time_scale = 1.0

func movement_logic(delta: float) -> void:
	panning_logic()

	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(-input_dir.x, 0, -input_dir.y)).normalized()
	direction_movement_logic(delta, direction)
	
	jump_jetpack_logic(delta)
	_rigid_body_collision()
	move_and_slide()

# Handle camera mouse look
func panning_logic() -> void:
	var slow_sens = 1.0 if Engine.time_scale == 1.0 else 3.0 # Slow down sens when in slow mo
	rotate_y(-_mouse_delta.x * (mouse_sensitivity / slow_sens))
	camera.rotation.x -= _mouse_delta.y * (mouse_sensitivity / slow_sens)
	camera.rotation.x = clamp(camera.rotation.x, -PI / 2, PI / 2)
	_mouse_delta = Vector2.ZERO

# Handle vertical movement logic (jumping, falling, jetpack)
func jump_jetpack_logic(delta) -> void:
	if is_on_floor() and Input.is_action_just_pressed("jump"): # user jumped
		velocity.y = jump_velocity
		restrict_jetpack_timer.start()
	if Input.is_action_pressed("jump") and restrict_jetpack_timer.is_stopped(): # jetpack
		velocity.y += jetpack_velocity * delta
		velocity.y = clampf(velocity.y, -INF, jetpack_velocity_cap)
		return
	fall(delta)

func shooting_logic() -> void:
	if Input.is_action_just_pressed("shoot"):
		gun.shoot(!aiming)

func aiming_logic() -> void:
	aiming = Input.is_action_pressed("aim")
	camera.ads_logic(aiming)

func hit(damage: float) -> void:
	curr_health -= damage
	if curr_health <= 0:
		die()

func die() -> void:
	print(self)
