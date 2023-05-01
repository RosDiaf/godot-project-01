extends CharacterBody2D

@export var axis = Vector2.ZERO
@export var MAX_SPEED = 550
@export var ACCELERATION = 1500
@export var FRICTION = 1400
@export var GRAVITY = 3000
@export var LANDING_ACCELERATION = 1000
@onready var JUMP_FORCE = -1000
@onready var JUMP_RELEASE_FORCE = -170
@onready var ADDITIONAL_FALL_GRAVITY = 240
@onready var DOUBLE_JUMP_COUNT = 1

@onready var animatedSprite = $AnimatedSprite2D
@onready var remoteTransform2D: = $RemoteTransform2D
@onready var advJumpBufferTimer: = $JumpBufferTimer
@onready var coyoteTimer: = $CoyoteTimer
@onready var dashTimer: = $DashTimer

var double_jump = 1
var buffered_jump = false
var screensize
var can_jump = true
var dashDirection = Vector2.ZERO
var canDash = true
var dashing = false

func _ready():
	animatedSprite.animation = "Idle"
	screensize = get_viewport_rect().size

func _physics_process(delta):
	# apply_gravity(delta)
	move(delta)

func get_input_axis():
	# axis.x = int(Input.is_action_just_pressed("move_right")) - int(Input.is_action_just_pressed("move_left"))
	axis.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	axis.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	
	set_animation_type(false)
	return axis.normalized()

func move(delta):
	# axis.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	# axis.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	set_animation_type(false)

	axis = get_input_axis()
	if axis == Vector2.ZERO:
		if velocity.length() > (FRICTION * delta):
			apply_friction(delta)
#	elif Input.is_action_just_pressed("dash"):
#		dash()
	else:
		apply_acceleration(delta)
	
	# velocity.y += GRAVITY * delta
	apply_gravity(delta)
	get_input(delta)
	dash()
	move_and_slide()
	

#func move(delta):
#	axis = get_input_axis()
#	if axis == Vector2.ZERO:
#		apply_friction(delta)
#	else:
#		apply_acceleration(axis.x, delta)
#
#	if is_on_floor():
#		reset_double_jump()
#		apply_jump(delta)
#
#	if !is_on_floor():
#		apply_double_jump()
#
#	velocity.y += GRAVITY * delta
#	get_input()
#	move_and_slide()
#	apply_clamp(delta)
			
func apply_friction(delta):
	velocity -= velocity.normalized() * (FRICTION * delta)
	velocity.x = 0;
	# axis.x = lerp(axis.x,0,0.1)
		
func apply_acceleration(delta):
	velocity += (axis * ACCELERATION * delta)
	velocity = velocity.limit_length(MAX_SPEED)

func set_animation_type(jump):
	if axis.x > 0:
		animatedSprite.animation = "Run"
		animatedSprite.flip_h = false
	elif axis.x < 0:
		animatedSprite.animation = "Run"
		animatedSprite.flip_h = true
	elif is_on_floor() and not Input.is_action_just_pressed("ui_select"):
		animatedSprite.animation = "Idle"
	elif is_on_floor() and Input.is_action_just_pressed("ui_select"):
		animatedSprite.animation = "Jump"
	elif Input.is_action_just_pressed("ui_select") and double_jump > 0:
		animatedSprite.animation = "Double_Jump"
	elif Input.is_action_just_pressed("ui_select") and axis.x > 0 and double_jump > 0:  # This condition is never verified
		print(axis.x)
		animatedSprite.animation = "Double_Jump"
	
func apply_gravity(delta):
	velocity.y += GRAVITY * delta
	velocity.y = min(velocity.y, LANDING_ACCELERATION)

func get_input(delta):
	var right = Input.is_action_pressed('move_right')
	var left = Input.is_action_pressed('move_left')
	var jump = Input.is_action_just_pressed('ui_select')
	
	if is_on_floor():
		can_jump = true
	elif can_jump == true:
		coyote_time()
	
	if jump and can_jump:
		apply_jump(delta)
	if !is_on_floor():
		apply_double_jump()
#	if right:
#		velocity.x += MAX_SPEED
#		print(velocity.x)
#	if left:
#		velocity.x -= MAX_SPEED
#		print(velocity.x)
		

func dash():
	if Input.is_action_just_pressed("dash") and canDash:
		velocity = dashDirection.normalized() * 2000
		canDash = false
		dashing = true
		dashTimer.start()
		dashing = false
		canDash = true
	print("dash")

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

func _on_dash_timer_timeout():
	velocity = Vector2(-2000,0)
