extends CharacterBody2D

@export var MAX_SPEED = 500
@export var ACCELERATION = 400
@export var FRICTION = 350
@export var axis = Vector2.ZERO
@export var GRAVITY = 2500
@export var LANDING_ACCELERATION = 300
@onready var JUMP_FORCE = -1000
@onready var JUMP_IMPULSE = -1900
@onready var JUMP_RELEASE_FORCE = -170
@onready var ADDITIONAL_FALL_GRAVITY = 240
@onready var DOUBLE_JUMP_COUNT = 1

@onready var animatedSprite = $AnimatedSprite2D
@onready var remoteTransform2D: = $RemoteTransform2D
@onready var advJumpBufferTimer: = $Timer
@onready var coyoteTimer: = $CoyoteTimer

var double_jump = 1
var buffered_jump = false
var screensize
	
var can_jump = true

func _ready():
	animatedSprite.animation = "Idle"
	screensize = get_viewport_rect().size

func _physics_process(delta):
	# apply_gravity(delta)
	move(delta)

func get_input_axis():
	axis.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	axis.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	set_animation_type(false)	
	return axis.normalized()

func move(delta):
	axis.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	axis.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	set_animation_type(false)
#	if axis.x == 0:
#		velocity.x = lerp(velocity.x, 0.0, FRICTION)
#		apply_friction(delta)
	velocity.y += GRAVITY * delta
	get_input(delta)
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
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

func apply_acceleration(amount,delta):
	velocity.x = move_toward(velocity.x, MAX_SPEED * amount, ACCELERATION * delta)

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
	
#func apply_gravity(delta):
#	velocity.y += GRAVITY * delta
#	velocity.y = min(velocity.y, LANDING_ACCELERATION)

func get_input(delta):
	velocity.x = 0
	var right = Input.is_action_pressed('move_right')
	var left = Input.is_action_pressed('move_left')
	var jump = Input.is_action_just_pressed('ui_select')
	
	if is_on_floor():
		can_jump = true
	elif can_jump == true:
		coyote_time()
	
	if jump and can_jump:
		velocity.y = JUMP_FORCE
		can_jump = false
		reset_double_jump()
	if !is_on_floor():
		apply_double_jump()
	if right:
		velocity.x += MAX_SPEED
		# velocity.x = min(velocity.x + ACCELERATION, MAX_SPEED)
		# apply_acceleration(axis.x, delta)
		print(velocity.x)
	if left:
		velocity.x -= MAX_SPEED
		# velocity.x = max(velocity.x - ACCELERATION, -MAX_SPEED)
		# apply_acceleration(axis.x, delta)
		print(velocity.x)
		
		
func coyote_time():
	coyoteTimer.start()

func apply_jump(delta):
	if is_on_floor() and Input.is_action_just_pressed("ui_select") or buffered_jump:
		velocity.y = JUMP_IMPULSE
		buffered_jump = true
		advJumpBufferTimer.start()

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
