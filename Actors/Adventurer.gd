extends CharacterBody2D

@export var axis = Vector2.ZERO
@export var MAX_SPEED = 550
@export var ACCELERATION = 1500
@export var FRICTION = 1400
@export var GRAVITY = 3000
@export var LANDING_ACCELERATION = 1000
@onready var JUMP_FORCE = -1000
@onready var DOUBLE_JUMP_COUNT = 1
@export_range(0.0, 1.0) var RANGE_FRICTION = 0.5
@export_range(0.0, 1.0) var RANGE_ACCELERATION = 0.25

@onready var animatedSprite = $AnimatedSprite2D
@onready var remoteTransform2D: = $RemoteTransform2D
@onready var advJumpBufferTimer: = $JumpBufferTimer
@onready var coyoteTimer: = $CoyoteTimer
@onready var ghostTimer: = $GhostTimer
@onready var particles: = $GPUParticles2D2
@onready var particlesLanding: = $GPUParticles2D3

@export var jump_height : float # 100
@export var jump_time_to_peak : float # 0.3
@export var jump_time_to_descent : float # 0.3
@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

var screensize
var can_jump = true
var double_jump = 1
var buffered_jump = false

var can_dash = true
var dashable = false
var isdashing = false
var dash_direction = Vector2(1,0)

func _ready():
	animatedSprite.animation = "Idle"
	screensize = get_viewport_rect().size

func _physics_process(delta):
	move(delta)

func get_input_axis():
	axis.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	axis.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	
	set_animation_type(false)
	return axis.normalized()

func move(delta):
	set_animation_type(false)
	axis = get_input_axis()
	if axis == Vector2.ZERO:
		if velocity.length() > (FRICTION * delta):
			apply_friction(delta)
	else:
		apply_acceleration(delta)
	
	dash()
	velocity.y += get_gravity() * delta
	get_input(delta)
	move_and_slide()
	
func apply_friction(delta):
	var dir = Input.get_axis("move_left","move_right")
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * MAX_SPEED, RANGE_ACCELERATION)
	else:
		velocity.x = lerp(velocity.x, 0.0, RANGE_FRICTION)
		
func apply_acceleration(delta):
	velocity += (axis * ACCELERATION * delta)
	velocity = velocity.limit_length(MAX_SPEED)

func set_animation_type(jump):
	if axis.x > 0:
		animatedSprite.animation = "Run"
		animatedSprite.flip_h = false
		particles.emitting = true
	elif axis.x < 0:
		animatedSprite.animation = "Run"
		animatedSprite.flip_h = true
		particles.emitting = true
	elif is_on_floor() and not Input.is_action_just_pressed("ui_select"):
		animatedSprite.animation = "Idle"
		particles.emitting = false
		particlesLanding.emitting = true
	elif is_on_floor() and Input.is_action_just_pressed("ui_select"):
		animatedSprite.animation = "Jump"
		particles.emitting = true
		particlesLanding.emitting = false
	elif Input.is_action_just_pressed("ui_select") and double_jump > 0:
		animatedSprite.animation = "Double_Jump"

	
func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func get_input(delta):
	var jump = Input.is_action_just_pressed('ui_select')
	
	if is_on_floor():
		can_jump = true
	elif can_jump == true:
		coyote_time()
	
	if jump and can_jump:
		apply_jump(delta)
	if !is_on_floor():
		apply_double_jump()


func dash():
	if is_on_floor():
		dashable = true
		
	if Input.is_action_pressed("move_left"):
		dash_direction = Vector2(-1,0)

	if Input.is_action_pressed("move_right"):
		dash_direction = Vector2(1,0)
		
	if can_dash and Input.is_action_pressed("dash") and dashable and (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")):
		can_dash = false;
		velocity = dash_direction.normalized() * 10000
		dashable = false
		isdashing = true
		await get_tree().create_timer(0.2).timeout
		isdashing = false
		can_dash = true

func coyote_time():
	coyoteTimer.start()

func apply_jump(delta):
	velocity.y = JUMP_FORCE
	advJumpBufferTimer.start()	
	buffered_jump = true
	can_jump = false
	reset_double_jump()

func apply_double_jump():
	if Input.is_action_just_pressed("ui_select") and double_jump > 0:
		velocity.y = JUMP_FORCE
		double_jump -= 1

func reset_double_jump():
	double_jump = DOUBLE_JUMP_COUNT

func connect_camera(camera):
	var camera_path = camera.get_path()
	remoteTransform2D.remote_path = camera_path
	
func apply_clamp(delta):
	if position.x <= -10:
		position.x = 0
		
func _on_visible_on_screen_enabler_2d_screen_exited():
	print("Exit Screen!")

func _on_adv_jump_buffer_timer_timeout():
	buffered_jump = false
	
func _on_coyote_timer_timeout():
	can_jump = false

func _on_ghost_timer_timeout():
	pass
#	if velocity.x != 0:
#		var this_ghost = preload("res://Actors/Adventurer.tscn").instantiate();
#		get_parent().add_child(this_ghost);
#		this_ghost.position = position
		# print(this_ghost.texture)
		# this_ghost.texture = $AnimatedSprite2D.frame.get_frame($AnimatedSprite2D.animation, $AnimatedSprite2D.frame)
		# this_ghost.flip_h = $AnimatedSprite2D.flip_h
